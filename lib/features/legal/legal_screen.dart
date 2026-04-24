import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/app_localizations.dart';

/// Generic long-form text surface used by Privacy Policy and Terms of
/// Service.
class LegalScreen extends StatelessWidget {
  const LegalScreen({
    super.key,
    required this.title,
    required this.sections,
    required this.lastUpdated,
  });

  final String title;
  final List<LegalSection> sections;
  final String lastUpdated;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _TopBar(onBack: () => context.pop()),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          sliver: SliverList.list(
            children: [
              Text(title, style: AppTypography.displayMd),
              const SizedBox(height: AppSpacing.sm),
              Text(
                lastUpdated,
                style: AppTypography.label.copyWith(
                  color: context.palette.textTertiary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              for (final s in sections) ...[
                Text(s.heading, style: AppTypography.title),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  s.body,
                  style: AppTypography.bodyLg.copyWith(
                    color: context.palette.textSecondary,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class LegalSection {
  const LegalSection(this.heading, this.body);
  final String heading;
  final String body;
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        0,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Material(
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
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Placeholder content. Replace with lawyer-reviewed copy before submission.
// ---------------------------------------------------------------------------

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final l = L10n.of(context);
    return LegalScreen(
      title: l.legalPrivacyTitle,
      lastUpdated: l.legalLastUpdated(_legalUpdatedDate(locale)),
      sections: privacySectionsFor(locale),
    );
  }
}

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final l = L10n.of(context);
    return LegalScreen(
      title: l.legalTermsTitle,
      lastUpdated: l.legalLastUpdated(_legalUpdatedDate(locale)),
      sections: termsSectionsFor(locale),
    );
  }
}

List<LegalSection> privacySectionsFor(Locale? locale) {
  if (locale?.languageCode == 'zh') return _privacySectionsZh;
  return _privacySectionsEn;
}

List<LegalSection> termsSectionsFor(Locale? locale) {
  if (locale?.languageCode == 'zh') return _termsSectionsZh;
  return _termsSectionsEn;
}

String _legalUpdatedDate(Locale? locale) {
  if (locale?.languageCode == 'zh') return '2026-04-20';
  return 'April 20 2026';
}

const _privacySectionsEn = <LegalSection>[
  LegalSection(
    'What we collect',
    'Serenity stores your progress (streak, total minutes, completed sessions) '
        'on your device. When you sign in, your preferences and progress sync '
        'to your Serenity account so they carry across devices. We do not sell '
        'or rent your data.',
  ),
  LegalSection(
    'Analytics',
    'We collect anonymised usage analytics (which screens you visit, which '
        'sessions you play, whether features crash) to improve the product. '
        'No personal content is transmitted.',
  ),
  LegalSection(
    'Health data',
    'If you enable HealthKit integration on iOS, we write your session length '
        'to the Mindful Minutes category. We never read other Health data.',
  ),
  LegalSection(
    'Children',
    'Serenity is not directed at children under 13. We do not knowingly '
        'collect information from children under 13.',
  ),
  LegalSection(
    'Contact',
    'Questions: privacy@serenity.app',
  ),
  LegalSection(
    'Placeholder notice',
    'This is draft copy for development. Before submitting to the App Store, '
        'have this reviewed by counsel and replace entirely.',
  ),
];

const _privacySectionsZh = <LegalSection>[
  LegalSection(
    '我们收集什么信息',
    'Serenity 会在你的设备上保存练习进度，包括连续天数、总分钟数和完成的课程次数。'
        '当你登录后，这些偏好和进度会同步到你的 Serenity 账户，以便在不同设备间延续。'
        '我们不会出售、出租或转让你的数据。',
  ),
  LegalSection(
    '分析数据',
    '我们会收集匿名使用分析，例如你访问了哪些页面、播放了哪些课程，以及功能是否发生崩溃，'
        '以便改进产品。个人内容不会被传输。',
  ),
  LegalSection(
    '健康数据',
    '如果你在 iOS 上启用 HealthKit 集成，我们会把课程时长写入“正念分钟”类别。'
        '除这一项外，我们不会读取你的其他健康数据。',
  ),
  LegalSection(
    '儿童',
    'Serenity 并非面向 13 岁以下儿童。我们不会有意收集 13 岁以下儿童的信息。',
  ),
  LegalSection(
    '联系方式',
    '如有问题，请联系：privacy@serenity.app',
  ),
  LegalSection(
    '占位说明',
    '当前文案用于开发阶段。在提交 App Store 之前，请由法律顾问审阅并整体替换。',
  ),
];

const _termsSectionsEn = <LegalSection>[
  LegalSection(
    'Not medical advice',
    'Serenity is a wellness and meditation product. It is not a substitute '
        'for professional medical or mental-health care. If you are '
        'experiencing a crisis, please contact a qualified provider.',
  ),
  LegalSection(
    'Subscription',
    'Premium access auto-renews monthly or yearly at the price shown in '
        'your jurisdiction. Cancel any time from the App Store subscription '
        'settings. A 14-day free trial is available to new subscribers.',
  ),
  LegalSection(
    'Acceptable use',
    'Do not redistribute session audio, reverse-engineer the app, or use it '
        'to deliver services to others without permission.',
  ),
  LegalSection(
    'Liability',
    'Serenity is provided "as is" without warranty. To the fullest extent '
        'permitted by law, we disclaim liability for indirect or consequential '
        'damages.',
  ),
  LegalSection(
    'Placeholder notice',
    'Draft copy for development. Replace with lawyer-reviewed terms before '
        'submission.',
  ),
];

const _termsSectionsZh = <LegalSection>[
  LegalSection(
    '非医疗建议',
    'Serenity 是一款健康与冥想产品，不能替代专业医疗或心理健康服务。'
        '如果你正在经历危机，请尽快联系合格的专业机构或服务提供者。',
  ),
  LegalSection(
    '订阅',
    '高级会员会按你所在地区显示的价格按月或按年自动续费。'
        '你可以随时在 App Store 的订阅设置中取消。14 天免费试用仅向新订阅用户提供。',
  ),
  LegalSection(
    '可接受使用',
    '未经许可，请勿重新分发课程音频、逆向工程本应用，或使用本应用向他人提供服务。',
  ),
  LegalSection(
    '责任限制',
    'Serenity 按“现状”提供，不附带任何明示或暗示保证。'
        '在法律允许的最大范围内，我们不对间接损失或后果性损害承担责任。',
  ),
  LegalSection(
    '占位说明',
    '当前文案用于开发阶段。在提交前，请替换为经法律顾问审阅的正式条款。',
  ),
];
