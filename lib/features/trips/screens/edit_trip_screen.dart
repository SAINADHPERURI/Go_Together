import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/dialogs.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../models/trip_model.dart';
import '../../../providers/trip_provider.dart';

class EditTripScreen extends ConsumerStatefulWidget {
  final TripModel trip;

  const EditTripScreen({
    super.key,
    required this.trip,
  });

  @override
  ConsumerState<EditTripScreen> createState() => _EditTripScreenState();
}

class _EditTripScreenState extends ConsumerState<EditTripScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _meetingPointController;
  late final TextEditingController _budgetNoteController;
  late final TextEditingController _capacityController;
  late TripStatus _selectedStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.trip.title);
    _descriptionController = TextEditingController(text: widget.trip.description);
    _meetingPointController = TextEditingController(text: widget.trip.meetingPointDetails ?? '');
    _budgetNoteController = TextEditingController(text: widget.trip.budgetEstimateNote ?? '');
    _capacityController = TextEditingController(text: widget.trip.maxMembers.toString());
    _selectedStatus = widget.trip.status;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _meetingPointController.dispose();
    _budgetNoteController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final newCapacity = int.tryParse(_capacityController.text.trim()) ?? widget.trip.maxMembers;
    if (newCapacity < widget.trip.currentMemberCount) {
      AppDialogs.showSnackBar(
        context,
        message: 'Capacity cannot be less than confirmed members count (${widget.trip.currentMemberCount}).',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final tripRepo = ref.read(tripRepositoryProvider);
      final updatedTrip = widget.trip.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        meetingPointDetails: _meetingPointController.text.trim().isEmpty ? null : _meetingPointController.text.trim(),
        budgetEstimateNote: _budgetNoteController.text.trim().isEmpty ? null : _budgetNoteController.text.trim(),
        maxMembers: newCapacity,
        status: _selectedStatus,
      );

      await tripRepo.updateTrip(updatedTrip);

      if (mounted) {
        AppDialogs.showSnackBar(context, message: 'Trip updated successfully!', isSuccess: true);
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        AppDialogs.showSnackBar(context, message: e.toString(), isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Trip'),
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
                  label: 'Trip Title',
                  controller: _titleController,
                  validator: (v) => Validators.validateRequired(v, 'Title'),
                ),
                const SizedBox(height: AppDimensions.space20),

                AppTextField(
                  label: 'Maximum Member Capacity',
                  controller: _capacityController,
                  keyboardType: TextInputType.number,
                  validator: Validators.validateCapacity,
                ),
                const SizedBox(height: AppDimensions.space20),

                // Status Dropdown
                DropdownButtonFormField<TripStatus>(
                  initialValue: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Trip Status',
                    prefixIcon: Icon(Icons.flag_outlined, size: 20),
                  ),
                  items: const [
                    DropdownMenuItem(value: TripStatus.open, child: Text('Open for Requests')),
                    DropdownMenuItem(value: TripStatus.full, child: Text('Full (No More Requests)')),
                    DropdownMenuItem(value: TripStatus.closed, child: Text('Closed / Registration Ended')),
                    DropdownMenuItem(value: TripStatus.completed, child: Text('Completed')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedStatus = val);
                  },
                ),
                const SizedBox(height: AppDimensions.space20),

                AppTextField(
                  label: 'Description & Plan',
                  controller: _descriptionController,
                  maxLines: 4,
                  maxLength: AppConstants.maxTripDescriptionLength,
                  validator: (v) => Validators.validateRequired(v, 'Description'),
                ),
                const SizedBox(height: AppDimensions.space20),

                AppTextField(
                  label: 'Meeting Point (Optional)',
                  controller: _meetingPointController,
                  maxLines: 2,
                ),
                const SizedBox(height: AppDimensions.space20),

                AppTextField(
                  label: 'Estimated Budget Split Note (Optional)',
                  controller: _budgetNoteController,
                ),
                const SizedBox(height: AppDimensions.space32),

                AppButton(
                  text: 'Save Changes',
                  onPressed: _handleSave,
                  isLoading: _isLoading,
                  icon: Icons.save_outlined,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
