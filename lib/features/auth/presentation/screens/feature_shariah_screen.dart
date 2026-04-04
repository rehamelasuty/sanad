import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Full-screen onboarding card — Shariah-compliant investing feature highlight.
class FeatureShariahScreen extends StatelessWidget {
  const FeatureShariahScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Stack(
          children: [
            // Close button
            Positioned(
              top: 12.h,
              right: 20.w,
              child: GestureDetector(
                onTap: () => context.go(AppRoutes.markets),
                child: Container(
                  width: 36.r,
                  height: 36.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: AppColors.white,
                    size: 18.r,
                  ),
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 60.h),

                // ── Feature copy ──────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 28.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon badge – gold star on a warm overlay
                      Container(
                        width: 52.r,
                        height: 52.r,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14.r),
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                          border: Border.all(
                            color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '✦',
                            style: TextStyle(
                              fontSize: 22.sp,
                              color: const Color(0xFFD4AF37),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 18.h),
                      Text(
                        'Shariah-Compliant\nInvestments',
                        style: AppTextStyles.h1.copyWith(
                          color: AppColors.white,
                          fontSize: 30.sp,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Browse Shariah-compliant stocks and view company purification statistics',
                        style: AppTextStyles.bodyLg.copyWith(
                          color: Colors.white.withValues(alpha: 0.6),
                          height: 1.65,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // ── Phone mockup ──────────────────────────
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 28.w),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(28.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 32,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: const _MockupShariahPreview(),
                  ),
                ),

                SizedBox(height: 24.h),

                // ── CTA ───────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 28.w),
                  child: _FeatureCta(
                    label: 'Explore Shariah Stocks',
                    onTap: () => context.go(AppRoutes.markets),
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Embedded mockup ─────────────────────────────────────────────────────────

class _MockupShariahPreview extends StatelessWidget {
  const _MockupShariahPreview();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Mini stock header
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
          child: Row(
            children: [
              Container(
                width: 32.r,
                height: 32.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.greenLite,
                ),
                child: Center(
                  child: Text(
                    '☽',
                    style: TextStyle(fontSize: 14.sp, color: AppColors.green),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Shariah Compliant',
                      style: AppTextStyles.labelMd
                          .copyWith(color: const Color(0xFF0A0A0A))),
                  Text('Stocks',
                      style: AppTextStyles.caption
                          .copyWith(color: const Color(0xFF999999))),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),

        // Sparkline chart mock
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: CustomPaint(
            size: Size(double.infinity, 70.h),
            painter: _SparklinePainter(),
          ),
        ),
        SizedBox(height: 10.h),

        // Sharia compliance chips
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _ShariaChip(
                label: '☽ Shariah Compliant',
                bg: AppColors.greenLite,
                fg: AppColors.green,
              ),
              _ShariaChip(
                label: '♻ Purification 0.50%',
                bg: const Color(0xFFFFF3E0),
                fg: const Color(0xFFE65100),
              ),
              _ShariaChip(
                label: '⚡ Debt Ratio 22%',
                bg: const Color(0xFFF3E5F5),
                fg: const Color(0xFF6A1B9A),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        Divider(height: 1, color: const Color(0x140F1923)),
        SizedBox(height: 6.h),

        // Stock rows
        _MockupShariaRow(ticker: 'MSFT', price: '\$412.20', change: '+1.2%', positive: true),
        _MockupShariaRow(ticker: 'AAPL', price: '\$194.35', change: '-0.4%', positive: false),
        _MockupShariaRow(ticker: '2222', price: '﷼ 28.60', change: '+0.7%', positive: true),
        SizedBox(height: 8.h),
      ],
    );
  }
}

class _ShariaChip extends StatelessWidget {
  const _ShariaChip({required this.label, required this.bg, required this.fg});
  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(label,
          style: AppTextStyles.caption
              .copyWith(color: fg, fontWeight: FontWeight.w600, fontSize: 10.sp)),
    );
  }
}

class _MockupShariaRow extends StatelessWidget {
  const _MockupShariaRow({
    required this.ticker,
    required this.price,
    required this.change,
    required this.positive,
  });
  final String ticker;
  final String price;
  final String change;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          Container(
            width: 32.r,
            height: 32.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFEEEEEE),
            ),
            child: Center(
              child: Text(
                ticker.length > 3 ? ticker.substring(0, 3) : ticker,
                style: TextStyle(
                  fontSize: 7.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF555555),
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Row(
              children: [
                Text(ticker,
                    style: AppTextStyles.labelMd
                        .copyWith(color: const Color(0xFF0A0A0A))),
                SizedBox(width: 6.w),
                // Compliance badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.greenLite,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text('☽',
                      style: TextStyle(fontSize: 8.sp, color: AppColors.green)),
                ),
              ],
            ),
          ),
          Text(price,
              style: AppTextStyles.monoSm.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0A0A0A),
              )),
          SizedBox(width: 8.w),
          Text(change,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: positive ? AppColors.green : AppColors.red,
              )),
        ],
      ),
    );
  }
}

// ── Simple sparkline painter ─────────────────────────────────────────────────

class _SparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const points = [0.5, 0.4, 0.55, 0.35, 0.45, 0.3, 0.25, 0.4, 0.2, 0.15];
    final paint = Paint()
      ..color = AppColors.green
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final path = Path();
    for (int i = 0; i < points.length; i++) {
      final x = size.width * (i / (points.length - 1));
      final y = size.height * points[i];
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);

    // Fill below sparkline
    final fillPath = Path()..addPath(path, Offset.zero);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.green.withValues(alpha: 0.25),
          AppColors.green.withValues(alpha: 0.0),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── CTA ──────────────────────────────────────────────────────────────────────

class _FeatureCta extends StatelessWidget {
  const _FeatureCta({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 15.h),
        decoration: BoxDecoration(
          color: AppColors.green,
          borderRadius: BorderRadius.circular(28.r),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.button.copyWith(color: AppColors.white),
        ),
      ),
    );
  }
}
