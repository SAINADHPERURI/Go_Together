import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/dialogs.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final UserModel user;

  const EditProfileScreen({
    super.key,
    required this.user,
  });

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _cityController;
  late final TextEditingController _bioController;

  late List<String> _selectedLanguages;
  late List<String> _selectedInterests;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.fullName);
    _cityController = TextEditingController(text: widget.user.city);
    _bioController = TextEditingController(text: widget.user.bio);
    _selectedLanguages = List<String>.from(widget.user.preferredLanguages);
    _selectedInterests = List<String>.from(widget.user.travelInterests);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedUser = widget.user.copyWith(
        fullName: _nameController.text.trim(),
        city: _cityController.text.trim(),
        bio: _bioController.text.trim(),
        preferredLanguages: _selectedLanguages,
        travelInterests: _selectedInterests,
      );

      await ref.read(authNotifierProvider.notifier).updateProfile(updatedUser);

      if (mounted) {
        AppDialogs.showSnackBar(
          context,
          message: 'Profile updated successfully!',
          isSuccess: true,
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        AppDialogs.showSnackBar(
          context,
          message: e.toString(),
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.space20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  label: 'Full Name',
                  controller: _nameController,
                  validator: Validators.validateName,
                ),
                const SizedBox(height: AppDimensions.space20),

                AppTextField(
                  label: 'Current City',
                  controller: _cityController,
                  validator: (v) => Validators.validateRequired(v, 'City'),
                ),
                const SizedBox(height: AppDimensions.space20),

                AppTextField(
                  label: 'Short Bio',
                  controller: _bioController,
                  maxLines: 3,
                  maxLength: AppConstants.maxBioLength,
                ),
                const SizedBox(height: AppDimensions.space20),

                // Preferred Languages
                Text(
                  'Preferred Languages for Travel',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 8),
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
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppDimensions.space20),

                // Travel Interests
                Text(
                  'Travel Interests',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 8),
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
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppDimensions.space32),

                AppButton(
                  text: 'Save Profile Changes',
                  onPressed: _handleSave,
                  isLoading: _isLoading,
                  icon: Icons.check_circle_outline_rounded,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
