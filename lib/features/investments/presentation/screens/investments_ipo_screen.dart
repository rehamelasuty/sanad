import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_text_styles.dart';

class InvestmentsIpoScreen extends StatelessWidget {
  const InvestmentsIpoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── AppBar ────────────────────────────────────
            Container(
              color: AppColors.white,
              padding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('الاكتتابات', style: AppTextStyles.h3),
                ],
              ),
            ),

            // ── Filter chips row ──────────────────────────
            Container(
              color: AppColors.white,
              padding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _FilterChip(label: 'المفتوحة', selected: true),
                  SizedBox(width: 8.w),
                  _FilterChip(label: 'القادمة', selected: false),
                  SizedBox(width: 8.w),
                  _FilterChip(label: 'المغلقة', selected: false),
                ],
              ),
            ),

            SizedBox(height: 12.h),

            // ── IPO list ──────────────────────────────────
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: _ipoItems.length,
                separatorBuilder: (_, __) => SizedBox(height: 10.h),
                itemBuilder: (_, i) => _IpoCard(item: _ipoItems[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stub data ─────────────────────────────────────────────────────────────────

class _IpoItem {
  const _IpoItem({
    required this.name,
    required this.symbol,
    required this.offerPrice,
    required this.subscriptionEnd,
    required this.logoColor,
    required this.sector,
  });

  final String name;
  final String symbol;
  final double offerPrice;
  final String subscriptionEnd;
  final Color logoColor;
  final String sector;
}

const _ipoItems = <_IpoItem>[
  _IpoItem(
    name: 'شركة الراجحي للتأمين',
    symbol: 'RJHI',
    offerPrice: 35.0,
    subscriptionEnd: '15 أبريل 2026',
    logoColor: Color(0xFF1A7C5E),
    sector: 'تأمين',
  ),
  _IpoItem(
    name: 'مجموعة عبداللطيف جميل',
    symbol: 'ALJ',
    offerPrice: 120.0,
    subscriptionEnd: '22 أبريل 2026',
    logoColor: Color(0xFF1B4FA8),
    sector: 'خدمات',
  ),
  _IpoItem(
    name: 'شركة نيوم للطاقة',
    symbol: 'NEOM',
    offerPrice: 18.5,
    subscriptionEnd: '30 أبريل 2026',
    logoColor: Color(0xFF0D1B2E),
    sector: 'طاقة',
  ),
];

// ── Widgets ───────────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: selected ? AppColors.navy : Colors.transparent,
        borderRadius: AppRadius.fullAll,
        border: Border.all(
          color: selected ? AppColors.navy : AppColors.border2,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelLg.copyWith(
          color: selected ? AppColors.white : AppColors.text2,
        ),
      ),
    );
  }
}

class _IpoCard extends StatelessWidget {
  const _IpoCard({required this.item});

  final _IpoItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Action button
          Container(
            padding:
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: AppRadius.smAll,
            ),
            child: Text(
              'اكتتب',
              style: AppTextStyles.labelLg
                  .copyWith(color: AppColors.white),
            ),
          ),

          SizedBox(width: 12.w),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(item.name, style: AppTextStyles.bodyLg,
                    textAlign: TextAlign.right),
                SizedBox(height: 4.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'ينتهي ${item.subscriptionEnd}',
                      style: AppTextStyles.labelSm,
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: AppColors.goldLite,
                        borderRadius: AppRadius.xsAll,
                      ),
                      child: Text(item.sector,
                          style: AppTextStyles.badgeSm
                              .copyWith(color: AppColors.gold)),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  'سعر الطرح: ﷼ ${item.offerPrice}',
                  style: AppTextStyles.priceSm,
                ),
              ],
            ),
          ),

          SizedBox(width: 10.w),

          // Logo
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: item.logoColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                  color: item.logoColor.withValues(alpha: 0.4)),
            ),
            alignment: Alignment.center,
            child: Text(
              item.symbol.substring(0, item.symbol.length.clamp(0, 3)),
              style: TextStyle(
                fontSize: 8.sp,
                fontWeight: FontWeight.w700,
                color: item.logoColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
