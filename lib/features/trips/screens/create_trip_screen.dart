import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_assets.dart';
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
import '../../../models/trip_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/trip_provider.dart';

class CreateTripScreen extends ConsumerStatefulWidget {
  const CreateTripScreen({super.key});

  @override
  ConsumerState<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends ConsumerState<CreateTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _destinationController = TextEditingController();
  final _startingCityController = TextEditingController();
  final _capacityController = TextEditingController(text: '6');
  final _descriptionController = TextEditingController();
  final _meetingPointController = TextEditingController();
  final _budgetNoteController = TextEditingController();

  String _selectedTripType = 'Adventure';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;
  final List<String> _destinationPhotos = [];

  @override
  void initState() {
    super.initState();
    // Default starting dates
    _startDate = DateTime.now().add(const Duration(days: 7));
    _endDate = DateTime.now().add(const Duration(days: 12));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _destinationController.dispose();
    _startingCityController.dispose();
    _capacityController.dispose();
    _descriptionController.dispose();
    _meetingPointController.dispose();
    _budgetNoteController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange() async {
    final now = DateTime.now();
    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : DateTimeRange(start: now.add(const Duration(days: 7)), end: now.add(const Duration(days: 12))),
      helpText: 'Select Trip Dates',
      cancelText: 'Cancel',
      confirmText: 'Set Dates',
    );

    if (pickedRange != null) {
      setState(() {
        _startDate = pickedRange.start;
        _endDate = pickedRange.end;
      });
    }
  }

  void _showAddPhotoDialog() {
    final urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.add_photo_alternate_rounded, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Text('Destination Photos'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Share scenic spot photos to give travelers an overview of your destination itinerary.',
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: urlController,
                      decoration: InputDecoration(
                        labelText: 'Image Web URL',
                        hintText: 'https://...',
                        prefixIcon: const Icon(Icons.link_rounded),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.add_circle, color: AppColors.primary),
                          tooltip: 'Add URL',
                          onPressed: () {
                            final url = urlController.text.trim();
                            if (url.isNotEmpty && (url.startsWith('http://') || url.startsWith('https://'))) {
                              setState(() {
                                if (!_destinationPhotos.contains(url)) {
                                  _destinationPhotos.add(url);
                                }
                              });
                              urlController.clear();
                              setDialogState(() {});
                            }
                          },
                        ),
                      ),
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Popular Destination Presets (Tap to toggle):',
                      style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: AppAssets.destinationImages.entries.take(12).map((entry) {
                        final isAdded = _destinationPhotos.contains(entry.value);
                        return FilterChip(
                          avatar: isAdded
                              ? const Icon(Icons.check, size: 14, color: Colors.white)
                              : const Icon(Icons.photo_outlined, size: 14),
                          label: Text(entry.key, style: const TextStyle(fontSize: 11)),
                          selected: isAdded,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isAdded ? Colors.white : null,
                            fontWeight: isAdded ? FontWeight.w700 : FontWeight.normal,
                          ),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                if (!_destinationPhotos.contains(entry.value)) {
                                  _destinationPhotos.add(entry.value);
                                }
                              } else {
                                _destinationPhotos.remove(entry.value);
                              }
                            });
                            setDialogState(() {});
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _handleCreateTrip() async {
    if (!_formKey.currentState!.validate()) return;

    final dateError = Validators.validateTripDates(_startDate, _endDate);
    if (dateError != null) {
      AppDialogs.showSnackBar(context, message: dateError, isError: true);
      return;
    }

    final user = ref.read(currentUserProfileProvider).value;
    if (user == null) {
      AppDialogs.showSnackBar(context, message: 'User session not found.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final tripRepo = ref.read(tripRepositoryProvider);
      final destination = _destinationController.text.trim();
      final title = _titleController.text.trim().isEmpty
          ? '$destination ${_selectedTripType.toLowerCase().contains("trip") ? _selectedTripType : "$_selectedTripType Trip"}'
          : _titleController.text.trim();

      final newTrip = TripModel(
        id: '',
        title: title,
        destination: destination,
        startingLocation: _startingCityController.text.trim(),
        tripType: _selectedTripType,
        startDate: _startDate!,
        endDate: _endDate!,
        maxMembers: int.parse(_capacityController.text.trim()),
        currentMemberCount: 1, // Host is member #1
        ageGroup: user.ageGroup, // STRICTLY derived from host's profile
        description: _descriptionController.text.trim(),
        meetingPointDetails: _meetingPointController.text.trim().isEmpty
            ? null
            : _meetingPointController.text.trim(),
        budgetEstimateNote: _budgetNoteController.text.trim().isEmpty
            ? null
            : _budgetNoteController.text.trim(),
        hostId: user.id,
        hostName: user.fullName,
        hostPhotoUrl: user.photoUrl,
        hostAge: user.age,
        hostCity: user.city,
        status: TripStatus.open,
        memberIds: [user.id],
        imageUrl: AppAssets.getImageUrlForDestination(destination),
        destinationPhotos: user.age <= 50 ? List.unmodifiable(_destinationPhotos) : const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final tripId = await tripRepo.createTrip(newTrip);

      if (mounted) {
        AppDialogs.showSnackBar(
          context,
          message: 'Trip created successfully!',
          isSuccess: true,
        );
        Navigator.of(context).pop(tripId);
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProfileProvider).value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Host a New Trip'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space20, vertical: AppDimensions.space16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Age Group Policy Banner
                AppCard(
                  color: user.ageGroup.accentColor.withValues(alpha: 0.08),
                  borderColor: user.ageGroup.accentColor.withValues(alpha: 0.3),
                  padding: const EdgeInsets.all(AppDimensions.space12),
                  child: Row(
                    children: [
                      Icon(user.ageGroup.icon, color: user.ageGroup.accentColor, size: 24),
                      const SizedBox(width: AppDimensions.space12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Age Group: ${user.ageGroup.displayName} (${user.ageGroup.personaTitle})',
                              style: AppTypography.titleSmall.copyWith(
                                color: user.ageGroup.accentColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'This trip will be published to the ${user.ageGroup.displayName} community automatically.',
                              style: AppTypography.bodySmall.copyWith(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.space24),

                // Destination
                AppTextField(
                  label: 'Destination',
                  hintText: 'e.g. Kashmir, Tirupati, Manali, Ladakh',
                  controller: _destinationController,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.location_on_rounded, size: 20),
                  validator: (v) => Validators.validateRequired(v, 'Destination'),
                ),

                const SizedBox(height: 8),

                // Destination Quick Chips
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: AppConstants.popularDestinations.take(6).map((dest) {
                    return ActionChip(
                      label: Text(dest, style: const TextStyle(fontSize: 11)),
                      onPressed: () {
                        _destinationController.text = dest;
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: AppDimensions.space20),

                // Starting City
                AppTextField(
                  label: 'Starting From (Origin City)',
                  hintText: 'e.g. Chennai, Bengaluru, Delhi NCR',
                  controller: _startingCityController,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.flight_takeoff_rounded, size: 20),
                  validator: (v) => Validators.validateRequired(v, 'Starting City'),
                ),

                const SizedBox(height: AppDimensions.space20),

                // Trip Type Selector
                Text(
                  'Trip Type',
                  style: AppTypography.titleSmall.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimensions.space8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedTripType,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.category_outlined, size: 20),
                  ),
                  items: AppConstants.tripTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedTripType = val);
                  },
                ),

                const SizedBox(height: AppDimensions.space20),

                // Dates Picker Field
                Text(
                  'Travel Dates',
                  style: AppTypography.titleSmall.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimensions.space6),
                InkWell(
                  onTap: _selectDateRange,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : Colors.white,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      border: Border.all(
                        color: _startDate != null ? AppColors.primary : AppColors.borderLight,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 20),
                        const SizedBox(width: AppDimensions.space12),
                        Expanded(
                          child: Text(
                            _startDate != null && _endDate != null
                                ? '${DateFormatter.formatTripDates(_startDate!, _endDate!)}  (${DateFormatter.formatDuration(_startDate!, _endDate!)})'
                                : 'Select trip dates',
                            style: AppTypography.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
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

                const SizedBox(height: AppDimensions.space20),

                // Maximum Members Capacity
                AppTextField(
                  label: 'Maximum Group Capacity (including Host)',
                  hintText: 'e.g. 6 (between 2 and 30)',
                  controller: _capacityController,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.group_outlined, size: 20),
                  validator: Validators.validateCapacity,
                ),

                const SizedBox(height: AppDimensions.space20),

                // Optional Custom Title
                AppTextField(
                  label: 'Trip Title (Optional)',
                  hintText: 'e.g. Kashmir Autumn Colors & Trekking',
                  controller: _titleController,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.title_rounded, size: 20),
                ),

                const SizedBox(height: AppDimensions.space20),

                // Description
                AppTextField(
                  label: 'Trip Description & Plan',
                  hintText: 'Share the itinerary plan, trekking difficulty, stay arrangements, pace of travel...',
                  controller: _descriptionController,
                  maxLines: 4,
                  maxLength: AppConstants.maxTripDescriptionLength,
                  validator: (v) => Validators.validateRequired(v, 'Description'),
                ),

                const SizedBox(height: AppDimensions.space20),

                // Meeting Point Details
                AppTextField(
                  label: 'Meeting Point / Assembly Details (Optional)',
                  hintText: 'e.g. Srinagar Airport arrival gate at 11:00 AM on Day 1',
                  controller: _meetingPointController,
                  maxLines: 2,
                  prefixIcon: const Icon(Icons.meeting_room_outlined, size: 20),
                ),

                const SizedBox(height: AppDimensions.space20),

                // Budget Estimate Note
                AppTextField(
                  label: 'Estimated Cost Note (Optional)',
                  hintText: 'e.g. Approx ₹12,000 per head (Food, Homestays & Cabs split equally)',
                  controller: _budgetNoteController,
                  prefixIcon: const Icon(Icons.currency_rupee_rounded, size: 20),
                ),

                // Destination Overview Photos (Applicable only for age <= 50)
                if (user.age <= 50) ...[
                  const SizedBox(height: AppDimensions.space24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.photo_library_rounded, size: 20, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Destination Overview Photos',
                            style: AppTypography.titleSmall.copyWith(
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: _showAddPhotoDialog,
                        icon: const Icon(Icons.add_photo_alternate_rounded, size: 18),
                        label: const Text('Add Photos'),
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add photos of scenic spots, sights, and stays to give fellow travelers a visual overview of where you are going.',
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space10),
                  if (_destinationPhotos.isEmpty)
                    InkWell(
                      onTap: _showAddPhotoDialog,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                          border: Border.all(
                            color: isDark ? AppColors.borderDark : AppColors.borderLight,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_a_photo_outlined, size: 22, color: AppColors.primary),
                            const SizedBox(width: 10),
                            Text(
                              'Add Destination Photos (Optional)',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 110,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _destinationPhotos.length + 1,
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          if (index == _destinationPhotos.length) {
                            return InkWell(
                              onTap: _showAddPhotoDialog,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                              child: Container(
                                width: 100,
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_rounded, color: AppColors.primary, size: 28),
                                    SizedBox(height: 4),
                                    Text(
                                      'Add More',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          final photoUrl = _destinationPhotos[index];
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                                child: CachedNetworkImage(
                                  imageUrl: photoUrl,
                                  width: 130,
                                  height: 110,
                                  fit: BoxFit.cover,
                                  placeholder: (_, _) => Container(
                                    width: 130,
                                    height: 110,
                                    color: isDark ? AppColors.cardDark : Colors.grey.shade200,
                                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                  ),
                                  errorWidget: (_, _, _) => Container(
                                    width: 130,
                                    height: 110,
                                    color: isDark ? AppColors.cardDark : Colors.grey.shade200,
                                    child: const Icon(Icons.broken_image, color: Colors.grey),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _destinationPhotos.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close_rounded, size: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                ],

                const SizedBox(height: AppDimensions.space32),

                AppButton(
                  text: 'Publish Trip to $_selectedTripType Community',
                  onPressed: _handleCreateTrip,
                  isLoading: _isLoading,
                  icon: Icons.publish_rounded,
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
