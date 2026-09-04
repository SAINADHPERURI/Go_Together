import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/age_group.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/dialogs.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../providers/auth_provider.dart';

class OnboardingProfileScreen extends ConsumerStatefulWidget {
  const OnboardingProfileScreen({super.key});

  @override
  ConsumerState<OnboardingProfileScreen> createState() => _OnboardingProfileScreenState();
}

class _OnboardingProfileScreenState extends ConsumerState<OnboardingProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _bioController = TextEditingController();

  DateTime? _selectedDob;
  int? _calculatedAge;
  AgeGroup? _calculatedAgeGroup;

  final List<String> _selectedLanguages = ['English'];
  final List<String> _selectedInterests = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final eighteenYearsAgo = DateTime(now.year - 18, now.month, now.day);
    final initialDate = _selectedDob ?? DateTime(now.year - 24, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(eighteenYearsAgo) ? eighteenYearsAgo : initialDate,
      firstDate: DateTime(now.year - 100),
      lastDate: eighteenYearsAgo,
      helpText: 'Select your Date of Birth',
      cancelText: 'Cancel',
      confirmText: 'Confirm Date',
    );

    if (picked != null) {
      setState(() {
        _selectedDob = picked;
        _calculatedAge = AgeGroup.calculateAge(picked);
        _calculatedAgeGroup = AgeGroup.fromDateOfBirth(picked);
      });
    }
  }

  Future<void> _handleCompleteProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDob == null) {
      AppDialogs.showSnackBar(
        context,
        message: 'Please select your Date of Birth to determine your age group.',
        isError: true,
      );
      return;
    }

    if (_selectedInterests.isEmpty) {
      AppDialogs.showSnackBar(
        context,
        message: 'Please select at least one travel interest.',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(authNotifierProvider.notifier).completeProfileOnboarding(
            fullName: _nameController.text.trim(),
            dateOfBirth: _selectedDob!,
            city: _cityController.text.trim(),
            bio: _bioController.text.trim(),
            preferredLanguages: _selectedLanguages,
            travelInterests: _selectedInterests,
          );
      // Navigation is reactive
    } catch (e) {
      if (mounted) {
        AppDialogs.showSnackBar(
          context,
          message: e.toString(),
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign Out',
            onPressed: () => ref.read(authNotifierProvider.notifier).signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space20, vertical: AppDimensions.space16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  'Tell us about yourself',
                  style: AppTypography.headlineMedium.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppDimensions.space6),
                Text(
                  'Your date of birth determines your travel community so you match with like-minded companions.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),

                const SizedBox(height: AppDimensions.space24),

                // Full Name
                AppTextField(
                  label: 'Full Name',
                  hintText: 'e.g. Aditi Sharma',
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                  validator: Validators.validateName,
                ),

                const SizedBox(height: AppDimensions.space20),

                // Date of Birth & Age Group Determination
                Text(
                  'Date of Birth',
                  style: AppTypography.titleSmall.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimensions.space6),

                InkWell(
                  onTap: _pickDateOfBirth,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : Colors.white,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      border: Border.all(
                        color: _selectedDob != null ? AppColors.primary : AppColors.borderLight,
                        width: _selectedDob != null ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_month_rounded,
                          color: _selectedDob != null ? AppColors.primary : AppColors.textMutedLight,
                          size: 22,
                        ),
                        const SizedBox(width: AppDimensions.space12),
                        Expanded(
                          child: Text(
                            _selectedDob != null
                                ? '${DateFormatter.formatDob(_selectedDob!)}  (${_calculatedAge!} years old)'
                                : 'Select your Date of Birth',
                            style: AppTypography.bodyLarge.copyWith(
                              color: _selectedDob != null
                                  ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                                  : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                              fontWeight: _selectedDob != null ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                        Text(
                          'Change',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Age Group Dynamic Preview Card
                if (_calculatedAgeGroup != null) ...[
                  const SizedBox(height: AppDimensions.space16),
                  AppCard(
                    color: _calculatedAgeGroup!.accentColor.withValues(alpha: 0.08),
                    borderColor: _calculatedAgeGroup!.accentColor.withValues(alpha: 0.4),
                    padding: const EdgeInsets.all(AppDimensions.space16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppDimensions.space12),
                          decoration: BoxDecoration(
                            color: _calculatedAgeGroup!.accentColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _calculatedAgeGroup!.icon,
                            color: _calculatedAgeGroup!.accentColor,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    _calculatedAgeGroup!.displayName,
                                    style: AppTypography.titleMedium.copyWith(
                                      color: _calculatedAgeGroup!.accentColor,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _calculatedAgeGroup!.accentColor,
                                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                                    ),
                                    child: Text(
                                      _calculatedAgeGroup!.personaTitle,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _calculatedAgeGroup!.subtitle,
                                style: AppTypography.bodySmall.copyWith(
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
                ],

                const SizedBox(height: AppDimensions.space20),

                // City / Location
                AppTextField(
                  label: 'Your Current City / Base Location',
                  hintText: 'e.g. Bengaluru, Hyderabad, Mumbai',
                  controller: _cityController,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
                  validator: (v) => Validators.validateRequired(v, 'City'),
                ),

                const SizedBox(height: AppDimensions.space20),

                // Preferred Languages
                Text(
                  'Preferred Languages for Travel',
                  style: AppTypography.titleSmall.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimensions.space8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AppConstants.supportedLanguages.map((lang) {
                    final isSelected = _selectedLanguages.contains(lang);
                    return FilterChip(
                      label: Text(lang),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedLanguages.add(lang);
                          } else {
                            if (_selectedLanguages.length > 1) {
                              _selectedLanguages.remove(lang);
                            }
                          }
                        });
                      },
                      selectedColor: AppColors.primaryContainer,
                      checkmarkColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppColors.primaryDark
                            : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: AppDimensions.space20),

                // Travel Interests
                Text(
                  'Travel Interests & Style',
                  style: AppTypography.titleSmall.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimensions.space8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AppConstants.travelInterests.map((interest) {
                    final isSelected = _selectedInterests.contains(interest);
                    return FilterChip(
                      label: Text(interest),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedInterests.add(interest);
                          } else {
                            _selectedInterests.remove(interest);
                          }
                        });
                      },
                      selectedColor: AppColors.secondaryContainer,
                      checkmarkColor: AppColors.secondary,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppColors.secondary
                            : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: AppDimensions.space20),

                // Short Bio
                AppTextField(
                  label: 'Short Bio (Optional)',
                  hintText: 'Share a few words about your travel style, previous treks or journeys...',
                  controller: _bioController,
                  maxLines: 3,
                  maxLength: AppConstants.maxBioLength,
                ),

                const SizedBox(height: AppDimensions.space32),

                AppButton(
                  text: 'Finish & Explore Trips',
                  onPressed: _handleCompleteProfile,
                  isLoading: _isLoading,
                  icon: Icons.check_circle_rounded,
                ),

                const SizedBox(height: AppDimensions.space24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
