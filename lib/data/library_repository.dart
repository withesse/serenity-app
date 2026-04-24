import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/library/library_data.dart';

/// Indirection in front of the hardcoded [librarySessions] list. Kept simple
/// and synchronous so UI code doesn't need FutureBuilders for data that's
/// currently bundled; when content moves to a CMS, swap in an async impl
/// and wrap the single read site with a FutureProvider. The abstraction
/// also lets tests inject a fixed list without touching global state.
abstract class LibraryRepository {
  List<LibrarySession> all();
  LibrarySession? findById(String id);
  List<LibrarySession> byCategory(LibraryCategory category);
  List<LibrarySession> related(LibrarySession session, {int max = 3});
}

class StaticLibraryRepository implements LibraryRepository {
  const StaticLibraryRepository();

  @override
  List<LibrarySession> all() => librarySessions;

  @override
  LibrarySession? findById(String id) => findSession(id);

  @override
  List<LibrarySession> byCategory(LibraryCategory category) =>
      category == LibraryCategory.all
          ? librarySessions
          : librarySessions
              .where((s) => s.category == category)
              .toList(growable: false);

  @override
  List<LibrarySession> related(LibrarySession session, {int max = 3}) =>
      librarySessions
          .where((s) => s.category == session.category && s.id != session.id)
          .take(max)
          .toList(growable: false);
}

final libraryRepositoryProvider =
    Provider<LibraryRepository>((_) => const StaticLibraryRepository());
