import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_text_styles.dart';

class InvestmentsFundsScreen extends StatefulWidget {
  const InvestmentsFundsScreen({super.key});

  @override
  State<InvestmentsFundsScreen> createState() =>
      _InvestmentsFundsScreenState();
}

class _InvestmentsFundsScreenState extends State<InvestmentsFundsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('﷼ 8,800.00', style: AppTextStyles.portValue),
                      Text('إجمالي الصناديق',
                          style: AppTextStyles.labelSm),
                    ],
                  ),
                  Text('الصناديق', style: AppTextStyles.h3),
                ],
              ),
            ),

            // ── Sub-tabs ──────────────────────────────────
            Container(
              color: AppColors.white,
              child: TabBar(
                controller: _tab,
                labelStyle: AppTextStyles.labelLg,
                unselectedLabelStyle: AppTextStyles.bodyMd,
                labelColor: AppColors.navy,
                unselectedLabelColor: AppColors.text3,
                indicatorColor: AppColors.navy,
                indicatorWeight: 2.5,
                indicatorSize: TabBarIndicatorSize.label,
                tabs: const [
                  Tab(text: 'صناديقي'),
                  Tab(text: 'استكشف'),
                ],
              ),
            ),

            // ── Content ───────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  _MyFundsList(funds: _myFunds),
                  _ExploreFundsList(funds: _exploreFunds),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Data models ───────────────────────────────────────────────────────────────

class _Fund {
  const _Fund({
    required this.name,
    required this.manager,
    required this.value,
    required this.returnRate,
    required this.units,
    required this.color,
    required this.type,
  });

  final String name;
  final String manager;
  final double value;
  final double returnRate;
  final double units;
  final Color color;
  final String type;
}

const _myFunds = <_Fund>[
  _Fund(
    name: 'صندوق الأهلي للأسهم السعودية',
    manager: 'بنك الأهلي',
    value: 5600,
    returnRate: 4.29,
    units: 100,
    color: Color(0xFFC9922A),
    type: 'أسهم',
  ),
  _Fund(
    name: 'صندوق ألفا للتقنية',
    manager: 'شركة ألفا للاستثمار',
    value: 3200,
    returnRate: -2.44,
    units: 50,
    color: Color(0xFF1B4FA8),
    type: 'تقنية',
  ),
];

const _exploreFunds = <_Fund>[
  _Fund(
    name: 'صندوق الرياض للدخل',
    manager: 'مصرف الرياض',
    value: 0,
    returnRate: 5.10,
    units: 0,
    color: Color(0xFF1A7C5E),
    type: 'دخل ثابت',
  ),
  _Fund(
    name: 'صندوق إنجاز للنمو',
    manager: 'شركة إنجاز المالية',
    value: 0,
    returnRate: 7.80,
    units: 0,
    color: Color(0xFF5E348B),
    type: 'نمو',
  ),
  _Fund(
    name: 'صندوق سعودي شامل',
    manager: 'الشركة العربية للاستثمار',
    value: 0,
    returnRate: 3.65,
    units: 0,
    color: Color(0xFFC9322A),
    type: 'متنوع',
  ),
];

// ── Widgets ───────────────────────────────────────────────────────────────────

class _MyFundsList extends StatelessWidget {
  const _MyFundsList({required this.funds});

  final List<_Fund> funds;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: funds.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (_, i) => _FundCard(fund: funds[i], owned: true),
    );
  }
}

class _ExploreFundsList extends StatelessWidget {
  const _ExploreFundsList({required this.funds});

  final List<_Fund> funds;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: funds.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (_, i) => _FundCard(fund: funds[i], owned: false),
    );
  }
}

class _FundCard extends StatelessWidget {
  const _FundCard({required this.fund, required this.owned});

  final _Fund fund;
  final bool owned;

  static final _fmt = NumberFormat('#,##0.##');

  @override
  Widget build(BuildContext context) {
    final isPositive = fund.returnRate >= 0;
    final returnColor = isPositive ? AppColors.green : AppColors.red;
    final returnSign = isPositive ? '+' : '';

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
          // Action
          if (!owned)
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: AppRadius.smAll,
              ),
              child: Text(
                'استثمر',
                style: AppTextStyles.labelLg
                    .copyWith(color: AppColors.white),
              ),
            ),

          if (!owned) SizedBox(width: 10.w),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(fund.name,
                    style: AppTextStyles.bodyLg,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                SizedBox(height: 2.h),
                Text(fund.manager, style: AppTextStyles.labelSm),
                SizedBox(height: 6.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (owned) ...[
                      Text(
                        '﷼ ${_fmt.format(fund.value)}',
                        style: AppTextStyles.priceSm,
                      ),
                      SizedBox(width: 12.w),
                    ],
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: returnColor.withValues(alpha: 0.1),
                        borderRadius: AppRadius.xsAll,
                      ),
                      child: Text(
                        '$returnSign${fund.returnRate.toStringAsFixed(2)}%',
                        style: AppTextStyles.badgeSm
                            .copyWith(color: returnColor),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: AppColors.bgPage,
                        borderRadius: AppRadius.xsAll,
                      ),
                      child: Text(fund.type,
                          style: AppTextStyles.badgeSm
                              .copyWith(color: AppColors.text2)),
                    ),
                  ],
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
              color: fund.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                  color: fund.color.withValues(alpha: 0.4)),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.layers_rounded,
                color: fund.color, size: 18.sp),
          ),
        ],
      ),
    );
  }
}
