import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_typography.dart';

/// Reusable Google Sign-In button adhering to Google Brand Guidelines
class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String text;

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.text = 'Sign in with Google',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                else ...[
                  const GoogleIcon(size: 22),
                  const SizedBox(width: 12),
                  Text(
                    text,
                    style: AppTypography.titleSmall.copyWith(
                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Official Multi-Color Google "G" logo vector icon
class GoogleIcon extends StatelessWidget {
  final double size;

  const GoogleIcon({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Center coordinates
    final center = Offset(w / 2, h / 2);
    final radius = w / 2;

    // Blue section (Right bar & upper right)
    paint.color = const Color(0xFF4285F4);
    final bluePath = Path()
      ..moveTo(center.dx, center.dy - radius * 0.2)
      ..lineTo(w, center.dy - radius * 0.2)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        -0.2,
        1.1,
        false,
      )
      ..lineTo(center.dx, center.dy + radius * 0.2)
      ..close();
    canvas.drawPath(bluePath, paint);

    // Green section (Bottom)
    paint.color = const Color(0xFF34A853);
    final greenPath = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(w * 0.82, h * 0.85)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        0.9,
        1.4,
        false,
      )
      ..close();
    canvas.drawPath(greenPath, paint);

    // Yellow section (Bottom left)
    paint.color = const Color(0xFFFBBC05);
    final yellowPath = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(w * 0.15, h * 0.78)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        2.3,
        1.0,
        false,
      )
      ..close();
    canvas.drawPath(yellowPath, paint);

    // Red section (Top left)
    paint.color = const Color(0xFFEA4335);
    final redPath = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(w * 0.18, h * 0.25)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        3.3,
        1.4,
        false,
      )
      ..close();
    canvas.drawPath(redPath, paint);

    // Inner cutout to create the 'G'
    final innerCutoutPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.58, innerCutoutPaint);

    // Center crossbar for G
    final crossbarPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(center.dx - radius * 0.05, center.dy - radius * 0.2, radius * 1.05, radius * 0.4),
        const Radius.circular(2),
      ),
      crossbarPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
