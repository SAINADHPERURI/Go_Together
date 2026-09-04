import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../models/chat_message_model.dart';
import '../../profile/screens/view_member_profile_screen.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isMe;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // System Message (e.g. joined group, left group, announcement)
    if (message.isSystem) {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.dividerLight.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          ),
          child: Text(
            message.text,
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
            ),
          ),
        ),
      );
    }

    // Standard User Chat Bubble
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            GestureDetector(
              onTap: () {
                if (message.senderId != 'system') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ViewMemberProfileScreen(userId: message.senderId),
                    ),
                  );
                }
              },
              child: AppAvatar(
                imageUrl: message.senderPhotoUrl,
                name: message.senderName,
                size: 30,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe
                    ? AppColors.primary
                    : (isDark ? AppColors.cardDark : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppDimensions.radiusLg),
                  topRight: const Radius.circular(AppDimensions.radiusLg),
                  bottomLeft: Radius.circular(isMe ? AppDimensions.radiusLg : 2),
                  bottomRight: Radius.circular(isMe ? 2 : AppDimensions.radiusLg),
                ),
                border: isMe
                    ? null
                    : Border.all(
                        color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                      ),
                boxShadow: isDark ? [] : AppDimensions.shadowSm,
              ),
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (!isMe) ...[
                    Text(
                      message.senderName,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primaryLight,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    message.text,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isMe
                          ? Colors.white
                          : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormatter.formatChatMessageTime(message.createdAt),
                    style: TextStyle(
                      fontSize: 10,
                      color: isMe
                          ? Colors.white70
                          : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
