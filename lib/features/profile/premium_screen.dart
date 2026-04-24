import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/pill_button.dart';
import '../../data/iap_store.dart';
import '../../l10n/app_localizations.dart';

class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  int _selectedPlan = 1; // 0 monthly, 1 yearly

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    final iap = ref.watch(iapProvider);
    final monthly = iap.byId(kSerenityMonthlyId);
    final yearly = iap.byId(kSerenityYearlyId);
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _CloseBar(onClose: () => context.pop()),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          sliver: SliverList.list(
            children: [
              const _HeroBadge(),
              const SizedBox(height: AppSpacing.xl),
              Text(
                l.premiumHeroTitle,
                style: AppTypography.displayLg.copyWith(height: 1.15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l.premiumHeroSubtitle,
                style: AppTypography.bodyLg.copyWith(
                  color: context.palette.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              const _BenefitList(),
              const SizedBox(height: AppSpacing.xl),
              _PlanCard(
                title: l.premiumPlanMonthly,
                price: monthly?.price ?? '\$9.99',
                period: l.premiumPlanMonthlyPeriod,
                selected: _selectedPlan == 0,
                onTap: () => setState(() => _selectedPlan = 0),
              ),
              const SizedBox(height: AppSpacing.sm),
              _PlanCard(
                title: l.premiumPlanYearly,
                price: yearly?.price ?? '\$59.99',
                period: l.premiumPlanYearlyPeriod,
                badge: l.premiumPlanYearlyBadge,
                selected: _selectedPlan == 1,
                onTap: () => setState(() => _selectedPlan = 1),
              ),
              const SizedBox(height: AppSpacing.xl),
              PillButton(
                label: iap.purchasing ? '…' : l.premiumCta,
                onPressed: iap.purchasing
                    ? null
                    : () async {
                        final p = _selectedPlan == 0 ? monthly : yearly;
                        if (p == null) return; // store hasn't resolved yet
                        await ref.read(iapProvider.notifier).purchase(p);
                      },
              ),
              if (iap.error != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  iap.error!,
                  textAlign: TextAlign.center,
                  style: AppTypography.label
                      .copyWith(color: AppColors.error),
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: TextButton(
                  onPressed: () =>
                      ref.read(iapProvider.notifier).restore(),
                  child: const Text('Restore purchases'),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l.premiumDisclaimer,
                style: AppTypography.label.copyWith(
                  color: context.palette.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CloseBar extends StatelessWidget {
  const _CloseBar({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Material(
            color: context.palette.surfaceGlass,
            shape: CircleBorder(
              side: BorderSide(color: context.palette.surfaceBorder),
            ),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onClose,
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(LucideIcons.x, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBadge extends StatefulWidget {
  const _HeroBadge();

  @override
  State<_HeroBadge> createState() => _HeroBadgeState();
}

class _HeroBadgeState extends State<_HeroBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return Center(
      child: SizedBox(
        width: 180,
        height: 180,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer rotating aurora halo.
            if (!reduceMotion)
              AnimatedBuilder(
                animation: _controller,
                builder: (_, _) => Transform.rotate(
                  angle: _controller.value * 6.283,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [
                          AppColors.brandGold,
                          AppColors.auroraEnd,
                          AppColors.auroraMid,
                          AppColors.brandViolet,
                          AppColors.brandGold,
                        ],
                      ),
                    ),
                  ),
                ),
              )
            else
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.brandGold, AppColors.auroraMid],
                  ),
                ),
              ),
            // Dark ring inset — leaves the halo readable as a rim.
            Container(
              width: 148,
              height: 148,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.palette.bgDeep.withValues(alpha: 0.7),
              ),
            ),
            // Core badge.
            Container(
              width: 112,
              height: 112,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.brandGold,
                    AppColors.auroraMid,
                    AppColors.brandViolet,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.glowGold,
                    blurRadius: 64,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                LucideIcons.crown,
                size: 52,
                color: context.palette.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitList extends StatelessWidget {
  const _BenefitList();

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    final items = [
      (l.premiumBenefit1, LucideIcons.library),
      (l.premiumBenefit2, LucideIcons.moon),
      (l.premiumBenefit3, LucideIcons.waves),
      (l.premiumBenefit4, LucideIcons.sparkles),
      (l.premiumBenefit5, LucideIcons.download),
    ];
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      glow: GlassGlow.gold,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _Benefit(label: items[i].$1, icon: items[i].$2),
            if (i < items.length - 1)
              const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.brandGold.withValues(alpha: 0.2),
            border: Border.all(color: AppColors.brandGold.withValues(alpha: 0.5)),
          ),
          child: Icon(icon, size: 16, color: AppColors.brandGold),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(label, style: AppTypography.bodyLg),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.period,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final String title;
  final String price;
  final String period;
  final String? badge;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      elevated: selected,
      glow: selected ? GlassGlow.soft : GlassGlow.none,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          _RadioDot(selected: selected),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: AppTypography.title),
                    if (badge != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: AppRadius.smR,
                          color: AppColors.brandGold.withValues(alpha: 0.22),
                          border: Border.all(color: AppColors.brandGold),
                        ),
                        child: Text(
                          badge!,
                          style: AppTypography.label.copyWith(
                            color: AppColors.brandGold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(period, style: AppTypography.bodyMd),
              ],
            ),
          ),
          Text(
            price,
            style: AppTypography.headline.copyWith(fontSize: 22),
          ),
        ],
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected
              ? AppColors.brandVioletLight
              : context.palette.surfaceBorderStrong,
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.brandVioletLight,
                  boxShadow: [
                    BoxShadow(
                      color: context.palette.brandShadowSoft,
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
