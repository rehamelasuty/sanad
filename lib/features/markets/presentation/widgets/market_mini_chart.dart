import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Inline mini chart for the TASI index.
class MarketMiniChart extends StatelessWidget {
  const MarketMiniChart({super.key});

  static const _points = [45, 40, 42, 30, 28, 25, 20, 22, 14, 16, 8];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 22.w),
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.smAll,
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'تداول TASI — اليوم',
                  style: AppTextStyles.labelLg,
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.greenLite,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    '▲ +0.82%',
                    style: AppTextStyles.badgeSm
                        .copyWith(color: AppColors.green),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            SizedBox(
              height: 60.h,
              child: CustomPaint(
                size: Size(double.infinity, 60.h),
                painter: _ChartPainter(
                  points: _points.map((e) => e.toDouble()).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  const _ChartPainter({required this.points});

  final List<double> points;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final min = points.reduce((a, b) => a < b ? a : b);
    final max = points.reduce((a, b) => a > b ? a : b);
    final range = max - min == 0 ? 1.0 : max - min;

    List<Offset> offsets = [];
    for (var i = 0; i < points.length; i++) {
      final x = (i / (points.length - 1)) * size.width;
      final y = size.height - ((points[i] - min) / range) * size.height;
      offsets.add(Offset(x, y));
    }

    // Fill
    final fillPath = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (final o in offsets.skip(1)) {
      fillPath.lineTo(o.dx, o.dy);
    }
    fillPath
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.navy.withValues(alpha: 0.12),
            AppColors.navy.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Line
    final linePath = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (final o in offsets.skip(1)) {
      linePath.lineTo(o.dx, o.dy);
    }

    canvas.drawPath(
      linePath,
      Paint()
        ..color = AppColors.navy
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Dot at end
    final last = offsets.last;
    canvas.drawCircle(last, 3.5, Paint()..color = AppColors.navy);
    canvas.drawCircle(
      last,
      7,
      Paint()..color = AppColors.navy.withValues(alpha: 0.12),
    );
  }

  @override
  bool shouldRepaint(_ChartPainter old) => old.points != points;
}
