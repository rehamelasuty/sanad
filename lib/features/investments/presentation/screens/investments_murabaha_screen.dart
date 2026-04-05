import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_text_styles.dart';

class InvestmentsMurabahaScreen extends StatelessWidget {
  const InvestmentsMurabahaScreen({super.key});

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Total invested label
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('﷼ 150,000.00',
                          style: AppTextStyles.portValue),
                      Text('إجمالي المرابحات',
                          style: AppTextStyles.labelSm),
                    ],
                  ),
                  Text('المرابحات', style: AppTextStyles.h3),
                ],
              ),
            ),

            SizedBox(height: 12.h),

            // ── Summary card ──────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: const _MurabahaSummaryCard(),
            ),

            SizedBox(height: 16.h),

            // ── Section title ─────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('خططك الحالية', style: AppTextStyles.sectionTitle),
                ],
              ),
            ),

            SizedBox(height: 8.h),

            // ── Plans list ────────────────────────────────
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: _plans.length,
                separatorBuilder: (_, __) => SizedBox(height: 10.h),
                itemBuilder: (_, i) => _MurabahaPlanCard(plan: _plans[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stub data ─────────────────────────────────────────────────────────────────

class _MurabahaPlan {
  const _MurabahaPlan({
    required this.id,
    required this.term,
    required this.principal,
    required this.profit,
    required this.annualRate,
    required this.maturityDate,
    required this.status,
    required this.color,
  });

  final String id;
  final String term;
  final double principal;
  final double profit;
  final double annualRate;
  final String maturityDate;
  final String status;
  final Color color;
}

const _plans = <_MurabahaPlan>[
  _MurabahaPlan(
    id: 'MUR-2026-001',
    term: '3 أشهر',
    principal: 50000,
    profit: 1875,
    annualRate: 3.75,
    maturityDate: '30 يونيو 2026',
    status: 'نشط',
    color: AppColors.green,
  ),
  _MurabahaPlan(
    id: 'MUR-2026-002',
    term: '12 شهراً',
    principal: 100000,
    profit: 5500,
    annualRate: 5.50,
    maturityDate: '31 مارس 2027',
    status: 'نشط',
    color: AppColors.gold,
  ),
];

// ── Widgets ───────────────────────────────────────────────────────────────────

class _MurabahaSummaryCard extends StatelessWidget {
  const _MurabahaSummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: AppRadius.mdAll,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem(
            label: 'إجمالي الأرباح',
            value: '﷼ 7,375',
            valueColor: AppColors.greenMid,
          ),
          _Divider(),
          _SummaryItem(
            label: 'متوسط العائد',
            value: '4.62%',
            valueColor: AppColors.gold2,
          ),
          _Divider(),
          _SummaryItem(
            label: 'الخطط النشطة',
            value: '2',
            valueColor: AppColors.white,
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.h3.copyWith(color: valueColor),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: AppTextStyles.labelSm
              .copyWith(color: AppColors.text4),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36.h,
      width: 1,
      color: AppColors.white.withValues(alpha: 0.15),
    );
  }
}

class _MurabahaPlanCard extends StatelessWidget {
  const _MurabahaPlanCard({required this.plan});

  final _MurabahaPlan plan;

  static final _fmt = NumberFormat('#,##0.##');

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ── Top row ───────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Status badge
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: plan.color.withValues(alpha: 0.1),
                  borderRadius: AppRadius.fullAll,
                ),
                child: Text(
                  plan.status,
                  style: AppTextStyles.badgeSm
                      .copyWith(color: plan.color),
                ),
              ),

              // Name + term
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'مرابحة ${plan.term}',
                    style: AppTextStyles.bodyLg,
                  ),
                  Text(plan.id, style: AppTextStyles.monoSm),
                ],
              ),
            ],
          ),

          SizedBox(height: 10.h),
          Divider(color: AppColors.border, height: 1),
          SizedBox(height: 10.h),

          // ── Values row ────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ValueCell(
                label: 'معدل العائد',
                value: '${plan.annualRate}%',
                valueColor: AppColors.green,
                align: CrossAxisAlignment.start,
              ),
              _ValueCell(
                label: 'الأرباح المتوقعة',
                value: '﷼ ${_fmt.format(plan.profit)}',
                valueColor: AppColors.green,
                align: CrossAxisAlignment.center,
              ),
              _ValueCell(
                label: 'المبلغ المستثمر',
                value: '﷼ ${_fmt.format(plan.principal)}',
                align: CrossAxisAlignment.end,
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // ── Maturity ──────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 12.sp, color: AppColors.text3),
              SizedBox(width: 4.w),
              Text(
                'تاريخ الاستحقاق: ${plan.maturityDate}',
                style: AppTextStyles.labelSm,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ValueCell extends StatelessWidget {
  const _ValueCell({
    required this.label,
    required this.value,
    this.valueColor,
    required this.align,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final CrossAxisAlignment align;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(label, style: AppTextStyles.labelSm),
        SizedBox(height: 3.h),
        Text(
          value,
          style: AppTextStyles.priceSm
              .copyWith(color: valueColor ?? AppColors.text1),
        ),
      ],
    );
  }
}
