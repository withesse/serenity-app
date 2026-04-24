import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/aurora_background.dart';
import '../../core/widgets/ghost_button.dart';
import '../../core/widgets/pill_button.dart';
import '../../core/widgets/star_field.dart';
import '../../data/auth_store.dart';
import '../../l10n/app_localizations.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _signUp = false;

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    return AuroraBackground(
      child: Stack(
        children: [
          const Positioned.fill(child: StarField()),
          SafeArea(
            child: Padding(
              padding: AppSpacing.screenHorizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: _BackButton(onBack: () => context.go('/onboarding')),
                  ),
                  const Spacer(flex: 2),
                  Text(
                    _signUp ? l.authSignUpTitle : l.authSignInTitle,
                    style: AppTypography.displayLg,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _signUp
                        ? l.authSignUpSubtitle
                        : l.authSignInSubtitle,
                    style: AppTypography.bodyLg.copyWith(
                      color: context.palette.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  _Field(
                    icon: LucideIcons.mail,
                    hint: l.authEmailHint,
                    keyboard: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _Field(
                    icon: LucideIcons.lock,
                    hint: l.authPasswordHint,
                    obscure: true,
                  ),
                  if (!_signUp) ...[
                    const SizedBox(height: AppSpacing.md),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: context.palette.textSecondary,
                        ),
                        onPressed: () {},
                        child: Text(l.authForgotPassword),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  PillButton(
                    label: _signUp ? l.authCreateAccount : l.authSignIn,
                    onPressed: () => context.go('/home'),
                  ),
                  if (Platform.isIOS || Platform.isMacOS) ...[
                    const SizedBox(height: AppSpacing.md),
                    _AppleSignInButton(
                      onSuccess: () => context.go('/home'),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  GhostButton(
                    label: l.authContinueAsGuest,
                    onPressed: () async {
                      await ref.read(authProvider.notifier).signInAsGuest();
                      if (context.mounted) context.go('/home');
                    },
                  ),
                  const Spacer(flex: 3),
                  _ToggleRow(
                    isSignUp: _signUp,
                    onToggle: () => setState(() => _signUp = !_signUp),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.palette.surfaceGlass,
      shape: CircleBorder(
        side: BorderSide(color: context.palette.surfaceBorder),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onBack,
        child: const SizedBox(
          width: 44,
          height: 44,
          child: Icon(LucideIcons.chevronLeft, size: 22),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.icon,
    required this.hint,
    this.obscure = false,
    this.keyboard,
  });

  final IconData icon;
  final String hint;
  final bool obscure;
  final TextInputType? keyboard;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: context.palette.surfaceGlass,
        border: Border.all(color: context.palette.surfaceBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, size: 18, color: context.palette.textTertiary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              obscureText: obscure,
              keyboardType: keyboard,
              cursorColor: AppColors.brandVioletLight,
              style: AppTypography.bodyLg,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: AppTypography.bodyLg
                    .copyWith(color: context.palette.textTertiary),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppleSignInButton extends ConsumerWidget {
  const _AppleSignInButton({required this.onSuccess});
  final VoidCallback onSuccess;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busy =
        ref.watch(authProvider.select((s) => s.busy));
    final isDark = context.palette.isDark;
    return SignInWithAppleButton(
      style: isDark
          ? SignInWithAppleButtonStyle.white
          : SignInWithAppleButtonStyle.black,
      height: 56,
      borderRadius: const BorderRadius.all(Radius.circular(999)),
      onPressed: busy
          ? () {}
          : () async {
              try {
                await ref.read(authProvider.notifier).signInWithApple();
                if (context.mounted) onSuccess();
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(L10n.of(context).authAppleSignInError),
                    ),
                  );
                }
              }
            },
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({required this.isSignUp, required this.onToggle});
  final bool isSignUp;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isSignUp ? l.authHaveAccountPrompt : l.authNewPrompt,
          style: AppTypography.bodyMd,
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: onToggle,
          child: Text(
            isSignUp ? l.authSignIn : l.authSignUp,
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.brandVioletLight,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
