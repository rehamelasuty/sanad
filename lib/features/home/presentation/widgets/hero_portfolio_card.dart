import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/portfolio_summary.dart';

class HeroPortfolioCard extends StatelessWidget {
  const HeroPortfolioCard({super.key, required this.summary});

  final PortfolioSummary summary;

  @override
  Widget build(BuildContext context) {
    final isPositive = summary.changeTodayPercent >= 0;
    final sign = isPositive ? '▲ +' : '▼ ';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 22.w),
      padding: EdgeInsets.all(22.r),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: AppRadius.mdAll,
        boxShadow: AppShadows.heroCard,
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -60,
            left: -60,
            child: _DecoCircle(size: 220, opacity: 0.07),
          ),
          Positioned(
            bottom: -40,
            right: -20,
            child: _DecoCircle(size: 160, opacity: 0.04),
          ),
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'إجمالي المحفظة',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white.withValues(alpha: 0.65),
                ),
              ),
              SizedBox(height: 6.h),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'ر.س',
                      style: AppTextStyles.heroPrice.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    TextSpan(
                      text:
                          ' ${_formatInt(summary.totalValue.truncate())}',
                      style: AppTextStyles.heroPrice,
                    ),
                    TextSpan(
                      text:
                          '.${_cents(summary.totalValue)}',
                      style: AppTextStyles.heroPrice.copyWith(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  _GlassPill(
                    label:
                        '$sign${summary.changeTodayPercent.toStringAsFixed(2)}%',
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    '+${_formatNum(summary.changeToday)} ر.س اليوم',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18.h),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                ),
                padding: EdgeInsets.only(top: 14.h),
                child: Row(
                  children: [
                    _HeroStat(
                      label: 'أسهم أمريكية',
                      value: _formatInt(summary.usStocksValue.truncate()),
                    ),
                    _HeroStat(
                      label: 'السوق السعودي',
                      value: _formatInt(summary.saudiStocksValue.truncate()),
                      divider: true,
                    ),
                    _HeroStat(
                      label: 'نقدي',
                      value: _formatInt(summary.cashValue.truncate()),
                      divider: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatInt(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  String _formatNum(double v) => _formatInt(v.truncate());

  String _cents(double v) => (v - v.truncate()).toStringAsFixed(2).substring(2);
}

class _GlassPill extends StatelessWidget {
  const _GlassPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.badgeSm.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.label,
    required this.value,
    this.divider = false,
  });

  final String label;
  final String value;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            fontSize: 10.sp,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          value,
          style: AppTextStyles.monoSm.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
      ],
    );

    if (divider) {
      // Must return Expanded so the outer Row treats this as a flex child —
      // returning a bare Row here would make it a non-flex child, and the
      // inner Expanded would be laid out with maxWidth:infinity, causing the
      // outer Row's free-space calculation to overflow to -infinity.
      return Expanded(
        child: Row(
          children: [
            Container(
              width: 1,
              height: 32.h,
              color: Colors.white.withValues(alpha: 0.12),
              margin: EdgeInsets.symmetric(horizontal: 14.w),
            ),
            Expanded(child: column),
          ],
        ),
      );
    }
    return Expanded(child: column);
  }
}

class _DecoCircle extends StatelessWidget {
  const _DecoCircle({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.r,
      height: size.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white.withValues(alpha: opacity),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
