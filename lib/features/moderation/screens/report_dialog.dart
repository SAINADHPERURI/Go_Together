import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/dialogs.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../models/moderation_model.dart';
import '../../../providers/moderation_provider.dart';

class ReportDialog extends ConsumerStatefulWidget {
  final String reporterId;
  final String? reportedUserId;
  final String? reportedTripId;

  const ReportDialog({
    super.key,
    required this.reporterId,
    this.reportedUserId,
    this.reportedTripId,
  });

  static Future<void> show(
    BuildContext context, {
    required String reporterId,
    String? reportedUserId,
    String? reportedTripId,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => ReportDialog(
        reporterId: reporterId,
        reportedUserId: reportedUserId,
        reportedTripId: reportedTripId,
      ),
    );
  }

  @override
  ConsumerState<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends ConsumerState<ReportDialog> {
  final _detailsController = TextEditingController();
  String _selectedReason = 'Inappropriate behavior or harassment';
  bool _isLoading = false;

  final List<String> _reasons = [
    'Inappropriate behavior or harassment',
    'Suspicious or spam trip post',
    'Requesting financial advance / fraud',
    'Misleading age group or profile details',
    'Offensive language in chat',
    'Other concern',
  ];

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    setState(() => _isLoading = true);

    try {
      final modRepo = ref.read(moderationRepositoryProvider);
      final report = ReportModel(
        id: '',
        reporterId: widget.reporterId,
        reportedUserId: widget.reportedUserId,
        reportedTripId: widget.reportedTripId,
        reason: _selectedReason,
        details: _detailsController.text.trim(),
        createdAt: DateTime.now(),
      );

      await modRepo.submitReport(report);

      if (mounted) {
        Navigator.of(context).pop();
        AppDialogs.showSnackBar(
          context,
          message: 'Thank you. Your report has been submitted to community moderators.',
          isSuccess: true,
        );
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
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusLg)),
      title: Text(
        widget.reportedUserId != null ? 'Report Traveler' : 'Report Trip',
        style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select the reason for reporting:',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: 8),
            // ignore: deprecated_member_use
            ..._reasons.map((reason) {
              // ignore: deprecated_member_use
              return RadioListTile<String>(
                title: Text(reason, style: const TextStyle(fontSize: 13)),
                value: reason,
                // ignore: deprecated_member_use
                groupValue: _selectedReason,
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
                // ignore: deprecated_member_use
                onChanged: (val) {
                  if (val != null) setState(() => _selectedReason = val);
                },
              );
            }),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Additional Details (Optional)',
              hintText: 'Describe what happened...',
              controller: _detailsController,
              maxLines: 3,
              maxLength: 300,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitReport,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Submit Report'),
        ),
      ],
    );
  }
}
