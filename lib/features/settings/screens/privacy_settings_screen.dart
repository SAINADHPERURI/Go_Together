import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';

class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Data Policy'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.space20),
        children: [
          Text(
            'GoTogether Privacy Commitment',
            style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'GoTogether is designed with privacy-first principles. We facilitate authentic human travel connections without selling or exposing personal contact information.',
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),

          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPolicyItem(
                  icon: Icons.no_accounts_outlined,
                  title: 'No Mandatory Phone or Contact Sharing',
                  description:
                      'Your phone number, email address, and exact home address are never displayed publicly on trip cards or traveler profiles.',
                ),
                const Divider(height: 24),
                _buildPolicyItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'Voluntary In-App Coordination',
                  description:
                      'All trip coordination happens inside protected group chats accessible only after the host approves your join request.',
                ),
                const Divider(height: 24),
                _buildPolicyItem(
                  icon: Icons.payments_outlined,
                  title: 'Zero Payment Processing',
                  description:
                      'GoTogether does not process booking transactions, collect bank credentials, or hold funds. All group expenses are settled independently by travelers.',
                ),
                const Divider(height: 24),
                _buildPolicyItem(
                  icon: Icons.delete_outline_rounded,
                  title: 'Account Deletion & Data Rights',
                  description:
                      'You have the permanent right to delete your account and all associated profile records at any time directly in Settings.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTypography.bodySmall.copyWith(height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
