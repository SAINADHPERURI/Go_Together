import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';

class SafetyGuidelinesScreen extends StatelessWidget {
  const SafetyGuidelinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Safety Guidelines'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.space20),
        children: [
          Text(
            'Safe Travel with GoTogether',
            style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Because GoTogether connects travelers for shared journeys, following these core safety practices ensures a secure and positive group experience.',
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
                _buildGuideline(
                  step: '1',
                  title: 'Coordinate Thoroughly in Group Chat',
                  description:
                      'Use the in-app group chat to align on expectations, physical fitness required for treks, packing essentials, transport arrangements, and meeting points before departure.',
                ),
                const Divider(height: 24),
                _buildGuideline(
                  step: '2',
                  title: 'Meet in Well-Lit Public Assembly Points',
                  description:
                      'For departure and initial meetups, choose designated public hubs such as airport arrival terminals, central railway stations, or prominent landmark cafes.',
                ),
                const Divider(height: 24),
                _buildGuideline(
                  step: '3',
                  title: 'Independent Financial Handling',
                  description:
                      'Do not transfer lump sums to unverified individuals. Pay hotel properties, permits, vehicle rentals, and shared meals directly on spot or through recognized split services.',
                ),
                const Divider(height: 24),
                _buildGuideline(
                  step: '4',
                  title: 'Share Itinerary with Family',
                  description:
                      'Always inform family members or close contacts of your trip destination, group members, expected dates, and accommodation points.',
                ),
                const Divider(height: 24),
                _buildGuideline(
                  step: '5',
                  title: 'Zero Tolerance for Misconduct',
                  description:
                      'Harassment, abusive messaging, discrimination, or fraud result in immediate account suspension. Use the in-app Report button whenever needed.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideline({
    required String step,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
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
