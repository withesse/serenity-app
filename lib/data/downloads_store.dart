import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'analytics.dart';

/// Tracks offline-download state per session. The audio asset itself is
/// currently bundled (one placeholder mp3), so this layer is a stub that
/// mimics download progress with a timer — but the state machine and
/// persistence match what a real background-downloader would expose,
/// so the UI can be built against the final shape now and swapped to
/// `flutter_downloader` / just_audio's cache layer later without UI churn.
enum DownloadStatus { none, queued, downloading, completed, failed }

final _noDownloadEntries = <String, DownloadEntry>{};

DownloadEntry _noDownloadEntry(String sessionId) {
  return _noDownloadEntries.putIfAbsent(
    sessionId,
    () => DownloadEntry(
      sessionId: sessionId,
      status: DownloadStatus.none,
      progress: 0,
    ),
  );
}

@immutable
class DownloadEntry {
  const DownloadEntry({
    required this.sessionId,
    required this.status,
    required this.progress,
    this.sizeBytes,
  });

  final String sessionId;
  final DownloadStatus status;
  final double progress; // 0.0 … 1.0
  final int? sizeBytes;

  bool get isDone => status == DownloadStatus.completed;
  bool get isActive =>
      status == DownloadStatus.queued || status == DownloadStatus.downloading;

  DownloadEntry copyWith({
    DownloadStatus? status,
    double? progress,
    int? sizeBytes,
  }) =>
      DownloadEntry(
        sessionId: sessionId,
        status: status ?? this.status,
        progress: progress ?? this.progress,
        sizeBytes: sizeBytes ?? this.sizeBytes,
      );

  Map<String, dynamic> toMap() => {
        'sessionId': sessionId,
        'status': status.name,
        'progress': progress,
        if (sizeBytes != null) 'sizeBytes': sizeBytes,
      };

  static DownloadEntry? fromMap(dynamic raw) {
    if (raw is! Map) return null;
    final id = raw['sessionId'];
    final statusName = raw['status'];
    if (id is! String || statusName is! String) return null;
    return DownloadEntry(
      sessionId: id,
      status: DownloadStatus.values.firstWhere(
        (s) => s.name == statusName,
        orElse: () => DownloadStatus.none,
      ),
      progress: (raw['progress'] as num?)?.toDouble() ?? 0.0,
      sizeBytes: raw['sizeBytes'] as int?,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DownloadEntry &&
        sessionId == other.sessionId &&
        status == other.status &&
        progress == other.progress &&
        sizeBytes == other.sizeBytes;
  }

  @override
  int get hashCode => Object.hash(sessionId, status, progress, sizeBytes);
}

class DownloadsController extends Notifier<Map<String, DownloadEntry>> {
  static const _boxName = 'settings';
  static const _key = 'downloads.list';
  static const _legacyKey = 'downloads';

  Box<dynamic> get _box => Hive.box<dynamic>(_boxName);
  final _active = <String, Timer>{};

  @override
  Map<String, DownloadEntry> build() {
    ref.onDispose(() {
      for (final t in _active.values) {
        t.cancel();
      }
      _active.clear();
    });
    // One-shot migration from the pre-namespace key. Always delete the
    // legacy slot once observed, otherwise a copy-then-crash could leave
    // both slots live and wipeAll below would miss the legacy leftover.
    if (_box.containsKey(_legacyKey)) {
      if (!_box.containsKey(_key)) {
        _box.put(_key, _box.get(_legacyKey));
      }
      _box.delete(_legacyKey);
    }
    final raw = _box.get(_key) as List?;
    if (raw == null) return const {};
    final entries = raw
        .map(DownloadEntry.fromMap)
        .whereType<DownloadEntry>()
        .where((e) => e.status == DownloadStatus.completed)
        // Only restore completed entries; anything that was in-flight when
        // the app was killed is safer to treat as "not started" than to
        // resume automatically without user intent.
        .toList(growable: false);
    return {for (final e in entries) e.sessionId: e};
  }

  DownloadEntry statusOf(String sessionId) =>
      state[sessionId] ?? _noDownloadEntry(sessionId);

  /// Kick off a simulated download. Real impl would register a background
  /// task with `flutter_downloader` or just_audio's cache-source, then
  /// tick this same state as bytes come in.
  Future<void> start(String sessionId) async {
    final current = state[sessionId];
    if (current != null && current.isActive) return;
    if (current?.isDone == true) return;

    _update(
      DownloadEntry(
        sessionId: sessionId,
        status: DownloadStatus.downloading,
        progress: 0,
      ),
    );

    await ref.read(analyticsProvider).track(
      'download_started',
      {'sessionId': sessionId},
    );

    // Stub: 30 ticks over 3 seconds. Jitter each tick so the progress bar
    // moves in an organic way instead of perfectly linear (reads as fake).
    final rng = Random();
    var elapsed = 0;
    final previousTimer = _active[sessionId];
    previousTimer?.cancel();
    if (previousTimer != null && identical(_active[sessionId], previousTimer)) {
      _active.remove(sessionId);
    }

    late final Timer tickTimer;
    tickTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) {
        if (!identical(_active[sessionId], tickTimer)) return;

        elapsed += 1;
        final base = (elapsed / 30).clamp(0, 1).toDouble();
        final jitter = rng.nextDouble() * 0.02;
        final next = (base + jitter).clamp(0, 1).toDouble();
        _update(statusOf(sessionId).copyWith(progress: next));
        if (elapsed >= 30) {
          tickTimer.cancel();
          unawaited(_complete(sessionId, tickTimer));
        }
      },
    );
    _active[sessionId] = tickTimer;
  }

  Future<void> cancel(String sessionId) async {
    final timer = _active[sessionId];
    timer?.cancel();
    if (timer != null && identical(_active[sessionId], timer)) {
      _active.remove(sessionId);
    }
    final next = Map<String, DownloadEntry>.from(state);
    next.remove(sessionId);
    state = next;
    await _persist();
    await ref.read(analyticsProvider).track(
      'download_cancelled',
      {'sessionId': sessionId},
    );
  }

  Future<void> remove(String sessionId) => cancel(sessionId);

  Future<void> wipeAll() async {
    for (final timer in _active.values) {
      timer.cancel();
    }
    _active.clear();
    await _box.deleteAll([_key, _legacyKey]);
    state = const {};
  }

  void _update(DownloadEntry entry) {
    final next = Map<String, DownloadEntry>.from(state);
    next[entry.sessionId] = entry;
    state = next;
  }

  Future<void> _complete(String sessionId, Timer tickTimer) async {
    if (!identical(_active[sessionId], tickTimer)) return;

    _active.remove(sessionId);
    _update(
      DownloadEntry(
        sessionId: sessionId,
        status: DownloadStatus.completed,
        progress: 1,
        // Plausible size for a 10-minute narration at 64 kbps mono.
        sizeBytes: 4_800_000,
      ),
    );
    await _persist();
    await ref.read(analyticsProvider).track(
      'download_completed',
      {'sessionId': sessionId},
    );
  }

  Future<void> _persist() async {
    // Only save completed entries — in-flight state is ephemeral.
    final completed =
        state.values.where((e) => e.status == DownloadStatus.completed);
    await _box.put(_key, completed.map((e) => e.toMap()).toList());
  }
}

final downloadsProvider =
    NotifierProvider<DownloadsController, Map<String, DownloadEntry>>(
  DownloadsController.new,
);

/// Convenience for a single session — returns the entry even when nothing
/// has been saved yet, so UI code doesn't need to null-check.
final downloadEntryProvider =
    Provider.family<DownloadEntry, String>((ref, sessionId) {
  final entry = ref.watch(downloadsProvider.select((m) => m[sessionId]));
  return entry ?? _noDownloadEntry(sessionId);
});
