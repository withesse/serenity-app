import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'error_sink.dart';

/// Signed-in user identity. Lives in Hive so the user stays signed in across
/// launches. A real backend would swap [_signInAppleLocal] for an HTTPS call
/// that exchanges the Apple credential for a session token and user record.
@immutable
class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.displayName,
  });

  final String id;
  final String email;
  final String displayName;
}

@immutable
class AuthState {
  const AuthState({required this.user, required this.busy});
  final AuthUser? user;
  final bool busy;

  bool get isSignedIn => user != null;

  AuthState copyWith({AuthUser? user, bool? busy, bool clearUser = false}) =>
      AuthState(
        user: clearUser ? null : (user ?? this.user),
        busy: busy ?? this.busy,
      );
}

class AuthController extends Notifier<AuthState> {
  static const _boxName = 'settings';

  Box<dynamic> get _box => Hive.box<dynamic>(_boxName);

  @override
  AuthState build() {
    final id = _box.get('auth.id') as String?;
    final email = _box.get('auth.email') as String?;
    final name = _box.get('auth.name') as String?;
    if (id != null && email != null && name != null) {
      return AuthState(
        user: AuthUser(id: id, email: email, displayName: name),
        busy: false,
      );
    }
    return const AuthState(user: null, busy: false);
  }

  /// Starts the Apple Sign In flow. On iOS this opens the system sheet; on
  /// other platforms it's a no-op that surfaces an error so the caller can
  /// fall back to email sign-in (not yet implemented here).
  Future<void> signInWithApple() async {
    if (!Platform.isIOS && !Platform.isMacOS) {
      throw UnsupportedError('Apple Sign In is only available on Apple OS.');
    }
    state = state.copyWith(busy: true);
    try {
      final cred = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      // In a real app the credential.identityToken would be POSTed to our
      // backend, which validates with Apple and returns a session + user.
      // For now we just persist whatever Apple gave us.
      final displayName = [
        cred.givenName,
        cred.familyName,
      ].whereType<String>().join(' ').trim();
      final user = AuthUser(
        id: cred.userIdentifier ?? cred.authorizationCode,
        email: cred.email ?? 'apple-user@${cred.userIdentifier}.local',
        displayName: displayName.isEmpty ? 'Apple user' : displayName,
      );
      await _persist(user);
      state = AuthState(user: user, busy: false);
    } catch (e, st) {
      reportError(ref, e, st, context: 'apple_sign_in');
      state = state.copyWith(busy: false);
      rethrow;
    }
  }

  /// Guest "sign in" — no network, just a local record. Used by the
  /// "Continue as guest" button on the auth screen.
  Future<void> signInAsGuest() async {
    final user = AuthUser(
      id: 'guest-${DateTime.now().millisecondsSinceEpoch}',
      email: 'guest@serenity.local',
      displayName: 'Guest',
    );
    await _persist(user);
    state = AuthState(user: user, busy: false);
  }

  Future<void> signOut() async {
    await _box.delete('auth.id');
    await _box.delete('auth.email');
    await _box.delete('auth.name');
    state = const AuthState(user: null, busy: false);
  }

  Future<void> _persist(AuthUser u) async {
    await _box.put('auth.id', u.id);
    await _box.put('auth.email', u.email);
    await _box.put('auth.name', u.displayName);
  }
}

final authProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
