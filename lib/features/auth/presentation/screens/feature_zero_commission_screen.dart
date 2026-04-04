import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Full-screen onboarding card — Zero Commission feature highlight.
class FeatureZeroCommissionScreen extends StatelessWidget {
  const FeatureZeroCommissionScreen({super.key});

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
                      // Icon badge
                      Container(
                        width: 52.r,
                        height: 52.r,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14.r),
                          color: AppColors.green.withValues(alpha: 0.15),
                          border: Border.all(
                            color: AppColors.green.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Center(
                          child: Text('%',
                              style: AppTextStyles.h2
                                  .copyWith(color: AppColors.green)),
                        ),
                      ),
                      SizedBox(height: 18.h),
                      Text(
                        'Zero-Commission',
                        style: AppTextStyles.h1.copyWith(
                          color: AppColors.white,
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w900,
                          height: 1.15,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'First Saudi trading platform without commission',
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
                    child: const _MockupStocksPreview(),
                  ),
                ),

                SizedBox(height: 24.h),

                // ── CTA ───────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 28.w),
                  child: _FeatureCta(
                    label: 'Start Investing Free',
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

class _MockupStocksPreview extends StatelessWidget {
  const _MockupStocksPreview();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Mini header
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Stocks',
                  style: AppTextStyles.h3
                      .copyWith(color: const Color(0xFF0A0A0A))),
              Row(
                children: [
                  _MiniIconBtn('🔍'),
                  SizedBox(width: 6.w),
                  _MiniIconBtn('🔔'),
                  SizedBox(width: 6.w),
                  _MiniIconBtn('👤'),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        // Market tabs
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              _MockupTab(label: '🇸🇦 Saudi Market', active: true),
              SizedBox(width: 16.w),
              _MockupTab(label: '🇺🇸 US Market'),
            ],
          ),
        ),
        Divider(height: 1, color: const Color(0x140F1923)),
        SizedBox(height: 6.h),
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
          child: Text('Popular',
              style: AppTextStyles.labelMd
                  .copyWith(color: const Color(0xFF0A0A0A))),
        ),
        SizedBox(height: 8.h),
        // Popular cards
        SizedBox(
          height: 88.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            children: const [
              _PopCard(ticker: 'YQEN', price: '﷼ 2,900', change: '+0.06%', positive: true),
              _PopCard(ticker: 'SRR', price: '﷼ 191.31', change: '+48.75%', positive: true),
              _PopCard(ticker: 'AMLK', price: '﷼ 142.71', change: '-0.02%', positive: false),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        // Stock rows
        _MockupStockRow(ticker: 'NSJ', price: '﷼ 315.42', change: '+0.02%', positive: true),
        _MockupStockRow(ticker: 'MHR', price: '﷼ 222.18', change: '+0.01%', positive: true),
        // Commission highlight row
        Container(
          margin: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 12.h),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColors.greenLite,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            children: [
              const Text('✓', style: TextStyle(color: AppColors.green, fontWeight: FontWeight.w700)),
              SizedBox(width: 8.w),
              Text('Zero Commission on all trades',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.green,
                    fontWeight: FontWeight.w600,
                  )),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniIconBtn extends StatelessWidget {
  const _MiniIconBtn(this.icon);
  final String icon;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28.r,
      height: 28.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFF5F5F5),
      ),
      child: Center(child: Text(icon, style: TextStyle(fontSize: 12.sp))),
    );
  }
}

class _MockupTab extends StatelessWidget {
  const _MockupTab({required this.label, this.active = false});
  final String label;
  final bool active;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          color: active ? const Color(0xFF0A0A0A) : const Color(0xFF999999),
        ),
      ),
    );
  }
}

class _PopCard extends StatelessWidget {
  const _PopCard({
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
    return Container(
      width: 110.w,
      margin: EdgeInsets.only(right: 8.w),
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28.r,
            height: 28.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white,
              border: Border.all(color: const Color(0x140F1923)),
            ),
            child: Center(
              child: Text(ticker.substring(0, 1),
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF555555),
                  )),
            ),
          ),
          SizedBox(height: 6.h),
          Text(ticker,
              style: AppTextStyles.caption
                  .copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF0A0A0A))),
          Text(price,
              style: AppTextStyles.mutedCaption
                  .copyWith(fontSize: 11.sp, color: const Color(0xFF0A0A0A))),
          Text(change,
              style: AppTextStyles.caption.copyWith(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: positive ? AppColors.green : AppColors.red,
              )),
        ],
      ),
    );
  }
}

class _MockupStockRow extends StatelessWidget {
  const _MockupStockRow({
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
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
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
              child: Text(ticker,
                  style: TextStyle(
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF555555),
                  )),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(ticker,
                style: AppTextStyles.labelMd
                    .copyWith(color: const Color(0xFF0A0A0A))),
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
