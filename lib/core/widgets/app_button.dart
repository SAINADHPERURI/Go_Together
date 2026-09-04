import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_typography.dart';

enum AppButtonVariant {
  primary,
  secondary,
  outline,
  destructive,
  ghost,
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double? height;
  final bool isFullWidth;
  final bool isSeniorAccessible;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height,
    this.isFullWidth = true,
    this.isSeniorAccessible = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height ??
        (isSeniorAccessible
            ? AppDimensions.buttonHeightSenior
            : AppDimensions.buttonHeight);

    Color bg;
    Color fg;
    BorderSide? border;

    switch (variant) {
      case AppButtonVariant.primary:
        bg = AppColors.primary;
        fg = Colors.white;
        border = BorderSide.none;
        break;
      case AppButtonVariant.secondary:
        bg = AppColors.secondary;
        fg = Colors.white;
        border = BorderSide.none;
        break;
      case AppButtonVariant.outline:
        bg = Colors.transparent;
        fg = AppColors.primary;
        border = BorderSide(
          color: AppColors.primary,
          width: isSeniorAccessible ? 2.0 : 1.5,
        );
        break;
      case AppButtonVariant.destructive:
        bg = AppColors.error;
        fg = Colors.white;
        border = BorderSide.none;
        break;
      case AppButtonVariant.ghost:
        bg = Colors.transparent;
        fg = AppColors.textSecondaryLight;
        border = BorderSide.none;
        break;
    }

    final buttonContent = isLoading
        ? SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: isSeniorAccessible ? 22 : 18, color: fg),
                const SizedBox(width: AppDimensions.space8),
              ],
              Text(
                text,
                style: (isSeniorAccessible
                        ? AppTypography.labelLarge.copyWith(fontSize: 17, fontWeight: FontWeight.w700)
                        : AppTypography.labelLarge)
                    .copyWith(color: fg),
              ),
            ],
          );

    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: effectiveHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            side: border,
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space20),
        ),
        child: buttonContent,
      ),
    );
  }
}
