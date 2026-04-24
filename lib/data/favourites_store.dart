import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'analytics.dart';

/// Persisted set of favourited session IDs. A session ID can be anything —
/// we don't validate here, so both library sessions ("midnight-harbour")
/// and breathing techniques ("box") can share this box.
class FavouritesController extends Notifier<Set<String>> {
  static const _boxName = 'settings';
  static const _key = 'favourites.ids';
  static const _legacyKey = 'favourites';

  Box<dynamic> get _box => Hive.box<dynamic>(_boxName);

  @override
  Set<String> build() {
    // One-shot migration from the pre-namespace key. Delete the legacy
    // slot unconditionally once observed — a copy-then-crash could
    // otherwise leave both slots live and wipe would miss the legacy.
    if (_box.containsKey(_legacyKey)) {
      if (!_box.containsKey(_key)) {
        _box.put(_key, _box.get(_legacyKey));
      }
      _box.delete(_legacyKey);
    }
    final raw = _box.get(_key) as List?;
    return raw == null ? {} : raw.cast<String>().toSet();
  }

  Future<void> toggle(String id) async {
    final next = {...state};
    final added = next.add(id);
    if (!added) next.remove(id);
    await _box.put(_key, next.toList());
    state = next;
    await ref.read(analyticsProvider).track(
      AnalyticsEvents.sessionFavourited,
      {'sessionId': id, 'added': added},
    );
  }

  bool contains(String id) => state.contains(id);

  Future<void> wipeAll() async {
    await _box.deleteAll([_key, _legacyKey]);
    state = {};
  }
}

final favouritesProvider =
    NotifierProvider<FavouritesController, Set<String>>(
  FavouritesController.new,
);
