import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/dialogs.dart';
import '../../../core/widgets/app_card.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../moderation/screens/blocked_users_screen.dart';
import 'privacy_settings_screen.dart';
import 'safety_guidelines_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _handleSignOut(BuildContext context, WidgetRef ref) async {
    final confirm = await AppDialogs.showConfirmDialog(
      context,
      title: 'Sign Out?',
      message: 'Are you sure you want to sign out of your GoTogether account?',
      confirmLabel: 'Sign Out',
    );

    if (confirm == true) {
      await ref.read(authNotifierProvider.notifier).signOut();
      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  Future<void> _handleDeleteAccount(BuildContext context, WidgetRef ref) async {
    final confirm = await AppDialogs.showConfirmDialog(
      context,
      title: 'Delete Account Permanently?',
      message: 'This will permanently remove your account, profile, and all trip requests from GoTogether. This action cannot be undone.',
      confirmLabel: 'Delete My Account',
      isDestructive: true,
    );

    if (confirm == true) {
      try {
        await ref.read(authNotifierProvider.notifier).deleteAccount();
        if (context.mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } catch (e) {
        if (context.mounted) {
          AppDialogs.showSnackBar(context, message: e.toString(), isError: true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeSettingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Preferences'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space20, vertical: AppDimensions.space16),
        children: [
          // Section: Accessibility & Display
          Text(
            'Accessibility & Appearance',
            style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),

          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                // Senior Accessible Mode Switch
                SwitchListTile(
                  title: Text(
                    'Senior & High-Contrast Mode',
                    style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Increases typography size, touch targets, and contrast for easy reading.',
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  value: themeState.isSeniorAccessibleMode,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) {
                    ref.read(themeSettingsProvider.notifier).toggleSeniorMode(val);
                  },
                ),
                const Divider(height: 1),

                // Dark Mode Switch
                SwitchListTile(
                  title: Text(
                    'Dark Mode',
                    style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Switch between light and dark theme aesthetics.',
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  value: themeState.themeMode == ThemeMode.dark,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) {
                    ref.read(themeSettingsProvider.notifier).setThemeMode(
                          val ? ThemeMode.dark : ThemeMode.light,
                        );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.space24),

          // Section: Safety & Privacy
          Text(
            'Safety & Community',
            style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),

          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.shield_outlined, color: AppColors.primary),
                  title: const Text('Community Safety Guidelines'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SafetyGuidelinesScreen()),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.block_rounded, color: AppColors.error),
                  title: const Text('Blocked Travelers'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const BlockedUsersScreen()),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.primary),
                  title: const Text('Privacy & Data Policy'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PrivacySettingsScreen()),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.space24),

          // Section: Account Actions
          Text(
            'Account',
            style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),

          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: AppColors.textSecondaryLight),
                  title: const Text('Sign Out'),
                  onTap: () => _handleSignOut(context, ref),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_forever_rounded, color: AppColors.error),
                  title: const Text('Delete Account', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
                  onTap: () => _handleDeleteAccount(context, ref),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.space32),

          Center(
            child: Text(
              'GoTogether Mobile App • v1.0.0 (CSE Final Year Project)',
              style: AppTypography.bodySmall.copyWith(
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                fontSize: 11,
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.space32),
        ],
      ),
    );
  }
}
