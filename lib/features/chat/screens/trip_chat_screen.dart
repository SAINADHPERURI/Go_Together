import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/dialogs.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_state.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../models/trip_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/chat_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input_bar.dart';
import 'trip_members_screen.dart';

class TripChatScreen extends ConsumerStatefulWidget {
  final TripModel trip;

  const TripChatScreen({
    super.key,
    required this.trip,
  });

  @override
  ConsumerState<TripChatScreen> createState() => _TripChatScreenState();
}

class _TripChatScreenState extends ConsumerState<TripChatScreen> {
  Future<void> _sendMessage(String text) async {
    final user = ref.read(currentUserProfileProvider).value;
    if (user == null) return;

    try {
      final chatRepo = ref.read(chatRepositoryProvider);
      await chatRepo.sendMessage(
        tripId: widget.trip.id,
        senderId: user.id,
        senderName: user.fullName,
        senderPhotoUrl: user.photoUrl,
        text: text,
      );
    } catch (e) {
      if (mounted) {
        AppDialogs.showSnackBar(
          context,
          message: 'Failed to send message: $e',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(tripChatMessagesStreamProvider(widget.trip.id));
    final currentUser = ref.watch(currentUserProfileProvider).value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TripMembersScreen(trip: widget.trip),
              ),
            );
          },
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.group_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.trip.destination,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${widget.trip.currentMemberCount} travelers • Tap for members',
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: 11,
                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outline_rounded),
            tooltip: 'View Members',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TripMembersScreen(trip: widget.trip),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Safety Notice Bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: isDark ? AppColors.surfaceDark : AppColors.primaryContainer.withValues(alpha: 0.4),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Coordinate travel safely. Never send advance booking payments to unverified parties.',
                    style: AppTypography.bodySmall.copyWith(
                      fontSize: 11,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Real-time Chat List
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'Welcome to the Group Chat!',
                    description:
                        'Say hello to your fellow travelers and start coordinating your travel plans, routes, and packing checklist.',
                  );
                }

                return ListView.builder(
                  reverse: true, // Latest messages at bottom
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.space16,
                    vertical: AppDimensions.space12,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = currentUser != null && message.senderId == currentUser.id;

                    return ChatBubble(
                      message: message,
                      isMe: isMe,
                    );
                  },
                );
              },
              loading: () => const AppLoading(message: 'Connecting to group chat...'),
              error: (err, _) => AppErrorState(message: err.toString()),
            ),
          ),

          // Message Input Bar
          ChatInputBar(
            onSendMessage: _sendMessage,
          ),
        ],
      ),
    );
  }
}
