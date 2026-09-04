import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/dialogs.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_state.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../providers/moderation_provider.dart';

class BlockedUsersScreen extends ConsumerWidget {
  const BlockedUsersScreen({super.key});

  Future<void> _handleUnblock(BuildContext context, WidgetRef ref, String blockId, String? name) async {
    final confirm = await AppDialogs.showConfirmDialog(
      context,
      title: 'Unblock Traveler?',
      message: 'Unblock ${name ?? "this traveler"}? They will be able to see your public trips and send requests again.',
      confirmLabel: 'Unblock',
    );

    if (confirm != true) return;

    try {
      final modRepo = ref.read(moderationRepositoryProvider);
      await modRepo.unblockUser(blockId);
      if (context.mounted) {
        AppDialogs.showSnackBar(context, message: 'Traveler unblocked.');
      }
    } catch (e) {
      if (context.mounted) {
        AppDialogs.showSnackBar(context, message: e.toString(), isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blockedAsync = ref.watch(blockedUsersStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blocked Travelers'),
      ),
      body: blockedAsync.when(
        data: (blockedList) {
          if (blockedList.isEmpty) {
            return AppEmptyState(
              icon: Icons.shield_outlined,
              title: 'No Blocked Travelers',
              description: 'You haven\'t blocked anyone. You can block any member from their profile.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppDimensions.space16),
            itemCount: blockedList.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.space8),
            itemBuilder: (context, index) {
              final block = blockedList[index];
              return AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.block_rounded, color: AppColors.error, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        block.blockedUserName ?? 'Blocked Traveler',
                        style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _handleUnblock(context, ref, block.id, block.blockedUserName),
                      child: const Text('Unblock'),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const AppLoading(message: 'Loading blocked list...'),
        error: (e, _) => AppErrorState(message: e.toString()),
      ),
    );
  }
}
