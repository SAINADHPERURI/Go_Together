import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final double fontSize;
  final bool isHorizontal;

  const AppLogo({
    super.key,
    this.size = 48,
    this.showText = true,
    this.fontSize = 24,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final logoIcon = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppColors.logoGradient,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: size * 0.35,
            offset: Offset(0, size * 0.15),
          ),
        ],
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ambient inner glow
            Container(
              width: size * 0.65,
              height: size * 0.65,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            // Custom travel connection glyph
            Icon(
              Icons.all_inclusive_rounded,
              color: Colors.white,
              size: size * 0.58,
            ),
            Positioned(
              top: size * 0.22,
              right: size * 0.22,
              child: Container(
                width: size * 0.16,
                height: size * 0.16,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (!showText) return logoIcon;

    final brandText = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: isHorizontal ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
          child: Text(
            'GoTogether',
            style: AppTypography.displaySmall.copyWith(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.8,
            ),
          ),
        ),
        Text(
          'Age-Matched Travel Communities',
          style: AppTypography.labelSmall.copyWith(
            fontSize: (fontSize * 0.42).clamp(10.0, 13.0),
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );

    if (isHorizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          logoIcon,
          const SizedBox(width: 14),
          brandText,
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        logoIcon,
        const SizedBox(height: 16),
        brandText,
      ],
    );
  }
}
