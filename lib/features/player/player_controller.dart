import 'dart:async';
import 'dart:ui' show Locale;

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../../data/analytics.dart';
import '../../data/error_sink.dart';
import '../../data/health_service.dart';
import '../../data/progress_store.dart';
import '../../data/siri_bridge.dart';
import '../library/library_data.dart';
import 'widgets/scene_picker.dart';

/// Real audio-backed player state.
///
/// Wraps a single shared [AudioPlayer] instance. The currently-bundled asset
/// (`assets/audio/meditation_placeholder.mp3`) is a 10-minute silence track so
/// the full audio pipeline exercises without needing licensed content. As
/// per-session narration assets land, prefer those and fall back to the
/// placeholder if a bundled file is still missing.
const _placeholderAudioAsset = 'assets/audio/meditation_placeholder.mp3';

String _audioAssetFor(String sessionId, Locale? locale) {
  final code = locale?.languageCode;
  if (code == 'en' || code == 'zh') {
    return 'assets/audio/$sessionId.$code.mp3';
  }
  return 'assets/audio/$sessionId.mp3';
}

@visibleForTesting
String audioAssetFor(String sessionId, Locale? locale) =>
    _audioAssetFor(sessionId, locale);

const _durationMatchEpsilon = Duration(seconds: 2);
const _categorySentinel = Object();

Duration _resolvedPlaybackDuration(
  Duration sessionDuration,
  Duration? loadedAssetDuration, {
  Duration epsilon = _durationMatchEpsilon,
}) {
  if (loadedAssetDuration == null || loadedAssetDuration == Duration.zero) {
    return sessionDuration;
  }
  if (sessionDuration == Duration.zero) return loadedAssetDuration;

  final delta = loadedAssetDuration - sessionDuration;
  final drift = delta.isNegative ? -delta : delta;
  return drift <= epsilon ? loadedAssetDuration : sessionDuration;
}

@visibleForTesting
Duration resolvedPlaybackDuration(
  Duration sessionDuration,
  Duration? loadedAssetDuration, {
  Duration epsilon = _durationMatchEpsilon,
}) => _resolvedPlaybackDuration(
  sessionDuration,
  loadedAssetDuration,
  epsilon: epsilon,
);

@immutable
class PlayerState {
  const PlayerState({
    required this.sessionId,
    required this.title,
    required this.subtitle,
    required this.narrator,
    required this.duration,
    this.category,
    this.position = Duration.zero,
    this.isPlaying = false,
    this.speed = 1.0,
    this.loading = false,
    this.scene = BackgroundScene.off,
  });

  final String sessionId;
  final String title;
  final String subtitle;
  final String narrator;
  final Duration duration;
  final LibraryCategory? category;
  final Duration position;
  final bool isPlaying;
  final double speed;
  final bool loading;
  final BackgroundScene scene;

  double get progress => duration.inMilliseconds == 0
      ? 0
      : (position.inMilliseconds / duration.inMilliseconds).clamp(0, 1);

  PlayerState copyWith({
    Object? category = _categorySentinel,
    Duration? position,
    Duration? duration,
    bool? isPlaying,
    double? speed,
    bool? loading,
    BackgroundScene? scene,
  }) =>
      PlayerState(
        sessionId: sessionId,
        title: title,
        subtitle: subtitle,
        narrator: narrator,
        duration: duration ?? this.duration,
        category: identical(category, _categorySentinel)
            ? this.category
            : category as LibraryCategory?,
        position: position ?? this.position,
        isPlaying: isPlaying ?? this.isPlaying,
        speed: speed ?? this.speed,
        loading: loading ?? this.loading,
        scene: scene ?? this.scene,
      );
}

class PlayerController extends Notifier<PlayerState> {
  final _audio = AudioPlayer();
  final _subs = <StreamSubscription<dynamic>>[];
  int _lastTrackedMinute = 0;
  Duration _sessionDuration = Duration.zero;
  Duration? _loadedAssetDuration;
  // Key for the last successful loadSession call. playerProvider is
  // app-global and survives route pops, so "same sessionId" alone is
  // not enough to skip reload — if the user changed language or came
  // back with a different locale, the MediaItem / title / asset path
  // need to refresh.
  String? _lastLoadKey;

  @override
  PlayerState build() {
    ref.onDispose(() async {
      for (final s in _subs) {
        await s.cancel();
      }
      await _audio.dispose();
    });

    _subs
      ..add(_audio.positionStream.listen((p) {
        state = state.copyWith(position: p);
        _trackMinutesListened();
      }))
      ..add(_audio.durationStream.listen((d) {
        if (d != null) {
          _loadedAssetDuration = d;
          state = state.copyWith(
            duration: _resolvedPlaybackDuration(_sessionDuration, d),
          );
        }
      }))
      ..add(_audio.playerStateStream.listen((ps) {
        state = state.copyWith(
          isPlaying: ps.playing,
          loading: ps.processingState == ProcessingState.loading ||
              ps.processingState == ProcessingState.buffering,
        );
        if (ps.processingState == ProcessingState.completed) {
          // When the session's declared duration is longer than the
          // loaded asset (the placeholder-fallback case), the audio
          // naturally ends before state.duration. Snap the UI position
          // to the full session duration so the countdown doesn't
          // freeze at e.g. "2:00 remaining" — the listener is done
          // either way and the mood-check-in should open on 0:00.
          if (state.position < state.duration) {
            state = state.copyWith(position: state.duration);
          }
          _recordCompletion();
        }
      }));

    // Configure the audio session once up front. The actual asset load is
    // driven by PlayerScreen.initState calling loadSession(sessionId) —
    // there is no default track anymore, so no warm-up load is scheduled
    // here.
    Future.microtask(_configureAudioSession);

    return const PlayerState(
      sessionId: '',
      title: '',
      subtitle: '',
      narrator: '',
      duration: Duration.zero,
      category: null,
      loading: true,
    );
  }

  /// Tell iOS/Android that this is a spoken-word meditation track so the
  /// OS mixes us appropriately. just_audio's default
  /// `handleInterruptions = true` owns pause/resume for session interruptions;
  /// we only provide the spoken-word session profile here and add a separate
  /// "becoming noisy" listener so unplugging headphones pauses politely.
  Future<void> _configureAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(
        const AudioSessionConfiguration.speech(),
      );
      // When headphones unplug, pause politely.
      _subs.add(session.becomingNoisyEventStream.listen((_) => _audio.pause()));
    } catch (e, st) {
      reportError(ref, e, st, context: 'audio_session_configure');
    }
  }

  /// Swap to a different library session. Updates the MediaItem so the
  /// lock-screen reflects the right title/narrator, and re-seeks to zero.
  /// Prefer a locale-tagged bundled asset, then fall back to the placeholder.
  Future<void> loadSession(String id, {Locale? locale}) async {
    final loadKey = '$id@${locale?.languageCode ?? ''}';
    if (_lastLoadKey == loadKey && !state.loading) return;
    final session = findSession(id);
    if (session == null) return;
    if (state.sessionId != session.id) {
      _lastTrackedMinute = 0;
    }
    _sessionDuration = session.duration;
    _loadedAssetDuration = null;
    final t = session.localized(locale);
    state = PlayerState(
      sessionId: session.id,
      title: t.title,
      subtitle: t.tagline,
      narrator: t.narrator,
      duration: _resolvedPlaybackDuration(
        _sessionDuration,
        _loadedAssetDuration,
      ),
      category: session.category,
      loading: true,
      scene: state.scene,
      speed: state.speed,
    );
    try {
      await _setAudioAssetWithFallback(
        preferredAsset: _audioAssetFor(session.id, locale),
        tag: MediaItem(
          id: session.id,
          title: t.title,
          artist: t.narrator,
          album: t.tagline,
        ),
      );
      _lastLoadKey = loadKey;
    } catch (e, st) {
      reportError(ref, e, st, context: 'audio_load', data: {'sessionId': id});
    }
    // Donate so "Hey Siri, <title>" and the Shortcuts app both learn this
    // session exists. Silent on Android and on iOS builds without the Swift
    // side registered.
    unawaited(SiriBridge.donate(sessionId: session.id, title: t.title));
  }

  Future<void> _setAudioAssetWithFallback({
    required String preferredAsset,
    required MediaItem tag,
  }) async {
    // Suppress ONLY the "asset missing" case — that's the expected path
    // while real per-session audio isn't bundled yet. Anything else
    // (decoder bugs, null derefs, platform channel faults…) goes through
    // reportError so Sentry/etc still see it.
    if (preferredAsset != _placeholderAudioAsset) {
      try {
        await _audio.setAudioSource(
          AudioSource.asset(preferredAsset, tag: tag),
        );
        return;
      } catch (e, st) {
        final message = e.toString();
        final isAssetMissing = message.contains('Unable to load asset') ||
            message.contains('The asset does not exist');
        if (!isAssetMissing) {
          reportError(ref, e, st,
              context: 'audio_load_preferred',
              data: {'asset': preferredAsset});
        } else {
          debugPrint(
            'audio asset missing, falling back to placeholder: '
            '$preferredAsset',
          );
        }
      }
    }

    await _audio.setAudioSource(
      AudioSource.asset(_placeholderAudioAsset, tag: tag),
    );
  }

  Future<void> togglePlay() async {
    if (_audio.playing) {
      await _audio.pause();
    } else {
      final wasAtStart = state.position == Duration.zero ||
          _audio.processingState == ProcessingState.completed;
      if (_audio.processingState == ProcessingState.completed) {
        await _audio.seek(Duration.zero);
      }
      await _audio.play();
      if (wasAtStart) {
        await ref.read(analyticsProvider).track(
          AnalyticsEvents.sessionStarted,
          {'sessionId': state.sessionId},
        );
      }
    }
  }

  Future<void> skip(Duration delta) async {
    final next = state.position + delta;
    final clamped = next < Duration.zero
        ? Duration.zero
        : (next > state.duration ? state.duration : next);
    await _audio.seek(clamped);
  }

  Future<void> seekTo(Duration position) => _audio.seek(position);

  Future<void> cycleSpeed() async {
    const speeds = [0.75, 1.0, 1.25, 1.5];
    final idx = speeds.indexOf(state.speed);
    final next = speeds[(idx + 1) % speeds.length];
    await _audio.setSpeed(next);
    state = state.copyWith(speed: next);
  }

  /// Update the background-scene preference. A real impl would also start
  /// mixing a loop of the selected sound over the voice track.
  void setScene(BackgroundScene scene) {
    state = state.copyWith(scene: scene);
  }

  /// Record a minute of meditation every 60 seconds of playback so the Home
  /// streak + Progress counters update as the user listens.
  void _trackMinutesListened() {
    final minute = state.position.inMinutes;
    if (minute > _lastTrackedMinute) {
      _lastTrackedMinute = minute;
      // Fire-and-forget — don't block the UI thread.
      ref.read(progressProvider.notifier).recordSession(1);
    }
  }

  void _recordCompletion() {
    final minutes = state.duration.inMinutes;
    _lastTrackedMinute = 0;
    // Fire-and-forget HealthKit write. No-op on Android. Errors flow to
    // the shared crash reporter via reportError, not debugPrint.
    unawaited(
      HealthService.logMindfulMinutes(minutes).catchError((
        Object e,
        StackTrace st,
      ) {
        reportError(ref, e, st, context: 'healthkit_write',
            data: {'minutes': minutes});
        return false;
      }),
    );
    unawaited(ref.read(analyticsProvider).track(
      AnalyticsEvents.sessionCompleted,
      {'sessionId': state.sessionId, 'minutes': minutes},
    ));
  }
}

final playerProvider =
    NotifierProvider<PlayerController, PlayerState>(PlayerController.new);
