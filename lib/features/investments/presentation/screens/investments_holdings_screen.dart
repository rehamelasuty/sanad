import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_text_styles.dart';

// ── Stub data models ──────────────────────────────────────────────────────────

class _Holding {
  const _Holding({
    required this.name,
    required this.code,
    required this.quantity,
    required this.marketValue,
    required this.totalPnl,
    required this.pnlPercent,
    required this.logoColor,
    this.logoLabel,
  });

  final String name;
  final String code;
  final double quantity;
  final double marketValue;
  final double totalPnl;
  final double pnlPercent;
  final Color logoColor;
  final String? logoLabel; // short text inside circle (e.g. "STC")
}

const _saudiHoldings = <_Holding>[
  _Holding(
    name: 'شركة مجموعة تداول السعودية القابضة',
    code: '2357',
    quantity: 2,
    marketValue: 474.62,
    totalPnl: 1.56,
    pnlPercent: 1.09,
    logoColor: Color(0xFF1B4FA8),
  ),
  _Holding(
    name: 'شركة الاتصالات السعودية',
    code: '3422',
    quantity: 2,
    marketValue: 2900,
    totalPnl: 1.56,
    pnlPercent: 1.09,
    logoColor: Color(0xFF5E348B),
    logoLabel: 'STC',
  ),
  _Holding(
    name: 'مجموعة سيرا القابضة',
    code: '4675',
    quantity: 2,
    marketValue: 1250,
    totalPnl: -0.84,
    pnlPercent: -0.52,
    logoColor: Color(0xFFC9323C),
  ),
  _Holding(
    name: 'شركة أرامكو السعودية',
    code: '2222',
    quantity: 10,
    marketValue: 8750,
    totalPnl: 312.0,
    pnlPercent: 3.70,
    logoColor: Color(0xFF1A7C5E),
    logoLabel: 'أرامكو',
  ),
];

const _usHoldings = <_Holding>[
  _Holding(
    name: 'Apple Inc.',
    code: 'AAPL',
    quantity: 5,
    marketValue: 9250,
    totalPnl: 320.5,
    pnlPercent: 3.59,
    logoColor: Color(0xFF555555),
    logoLabel: 'AAPL',
  ),
  _Holding(
    name: 'Microsoft Corp.',
    code: 'MSFT',
    quantity: 3,
    marketValue: 12450,
    totalPnl: -145.0,
    pnlPercent: -1.15,
    logoColor: Color(0xFF1B4FA8),
    logoLabel: 'MSFT',
  ),
];

const _fundHoldings = <_Holding>[
  _Holding(
    name: 'صندوق الأهلي للأسهم السعودية',
    code: 'AHLA',
    quantity: 100,
    marketValue: 5600,
    totalPnl: 230,
    pnlPercent: 4.29,
    logoColor: Color(0xFFC9922A),
    logoLabel: 'أهلي',
  ),
  _Holding(
    name: 'صندوق ألفا للتقنية',
    code: 'ALFA',
    quantity: 50,
    marketValue: 3200,
    totalPnl: -80,
    pnlPercent: -2.44,
    logoColor: Color(0xFF1B4FA8),
    logoLabel: 'ألفا',
  ),
];

const _murabahaHoldings = <_Holding>[
  _Holding(
    name: 'مرابحة قصيرة الأجل – 3 أشهر',
    code: 'MUR-01',
    quantity: 1,
    marketValue: 50000,
    totalPnl: 1875,
    pnlPercent: 3.75,
    logoColor: Color(0xFF1A7C5E),
    logoLabel: '3M',
  ),
  _Holding(
    name: 'مرابحة متوسطة الأجل – 12 شهراً',
    code: 'MUR-02',
    quantity: 1,
    marketValue: 100000,
    totalPnl: 5500,
    pnlPercent: 5.50,
    logoColor: Color(0xFFC9922A),
    logoLabel: '12M',
  ),
];

// ── Main Screen ───────────────────────────────────────────────────────────────

class InvestmentsHoldingsScreen extends StatefulWidget {
  const InvestmentsHoldingsScreen({super.key});

  @override
  State<InvestmentsHoldingsScreen> createState() =>
      _InvestmentsHoldingsScreenState();
}

class _InvestmentsHoldingsScreenState
    extends State<InvestmentsHoldingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _mainTab;

  static const _tabLabels = ['الأسهم', 'الصناديق', 'المرابحات'];

  static const _totalPortfolioValue = 2900250.00;

  @override
  void initState() {
    super.initState();
    _mainTab = TabController(length: _tabLabels.length, vsync: this);
  }

  @override
  void dispose() {
    _mainTab.dispose();
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
            // ── Header ────────────────────────────────────
            _HoldingsHeader(
              totalValue: _totalPortfolioValue,
              onBack: () =>
                  context.canPop() ? context.pop() : context.go('/'),
            ),

            // ── Category tabs (Stocks / Funds / Murabaha) ─
            _CategoryTabBar(
              controller: _mainTab,
              labels: _tabLabels,
            ),

            // ── Tab content ───────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _mainTab,
                children: const [
                  _StocksTabContent(),
                  _SimpleHoldingsList(holdings: _fundHoldings),
                  _SimpleHoldingsList(holdings: _murabahaHoldings),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _HoldingsHeader extends StatelessWidget {
  const _HoldingsHeader({
    required this.totalValue,
    required this.onBack,
  });

  final double totalValue;
  final VoidCallback onBack;

  static final _fmt = NumberFormat('#,##0.00');

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Value (displayed on the leading / right side in RTL)
          Text(
            '﷼ ${_fmt.format(totalValue)}',
            style: AppTextStyles.portValue,
          ),

          // Title + back arrow
          GestureDetector(
            onTap: onBack,
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'قيمة استثماراتك',
                  style: AppTextStyles.h4,
                ),
                SizedBox(width: 6.w),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13.sp,
                  color: AppColors.text2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Custom chip tab bar ───────────────────────────────────────────────────────

class _CategoryTabBar extends StatefulWidget {
  const _CategoryTabBar({
    required this.controller,
    required this.labels,
  });

  final TabController controller;
  final List<String> labels;

  @override
  State<_CategoryTabBar> createState() => _CategoryTabBarState();
}

class _CategoryTabBarState extends State<_CategoryTabBar> {
  int _selected = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTabChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTabChange);
    super.dispose();
  }

  void _onTabChange() {
    if (!widget.controller.indexIsChanging &&
        _selected != widget.controller.index) {
      setState(() => _selected = widget.controller.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: List.generate(widget.labels.length, (i) {
          // Reverse order so rightmost tab is index 0 (Arabic RTL)
          final idx = widget.labels.length - 1 - i;
          final selected = _selected == idx;

          return Padding(
            padding: EdgeInsets.only(left: i < widget.labels.length - 1 ? 8.w : 0),
            child: _ChipTab(
              label: widget.labels[idx],
              selected: selected,
              onTap: () {
                widget.controller.animateTo(idx);
                setState(() => _selected = idx);
              },
            ),
          );
        }),
      ),
    );
  }
}

class _ChipTab extends StatelessWidget {
  const _ChipTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 7.h),
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
      ),
    );
  }
}

// ── Stocks tab (with Saudi / US sub-tabs) ─────────────────────────────────────

class _StocksTabContent extends StatefulWidget {
  const _StocksTabContent();

  @override
  State<_StocksTabContent> createState() => _StocksTabContentState();
}

class _StocksTabContentState extends State<_StocksTabContent>
    with SingleTickerProviderStateMixin {
  late final TabController _marketTab;

  @override
  void initState() {
    super.initState();
    _marketTab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _marketTab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Market sub-tab bar ─────────────────────────
        _MarketTabBar(controller: _marketTab),

        // ── Holdings list ──────────────────────────────
        Expanded(
          child: TabBarView(
            controller: _marketTab,
            children: const [
              _SimpleHoldingsList(holdings: _saudiHoldings),
              _SimpleHoldingsList(holdings: _usHoldings),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Market underline tab bar ──────────────────────────────────────────────────

class _MarketTabBar extends StatelessWidget {
  const _MarketTabBar({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: TabBar(
        controller: controller,
        labelStyle: AppTextStyles.labelLg,
        unselectedLabelStyle: AppTextStyles.bodyMd,
        labelColor: AppColors.navy,
        unselectedLabelColor: AppColors.text3,
        indicatorColor: AppColors.navy,
        indicatorWeight: 2.5,
        indicatorSize: TabBarIndicatorSize.label,
        tabs: const [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🇸🇦', style: TextStyle(fontSize: 16)),
                SizedBox(width: 6),
                Text('السوق السعودي'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🇺🇸', style: TextStyle(fontSize: 16)),
                SizedBox(width: 6),
                Text('السوق الأمريكي'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Holdings list ─────────────────────────────────────────────────────────────

class _SimpleHoldingsList extends StatelessWidget {
  const _SimpleHoldingsList({required this.holdings});

  final List<_Holding> holdings;

  @override
  Widget build(BuildContext context) {
    if (holdings.isEmpty) {
      return Center(
        child: Text(
          'لا توجد بيانات',
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.text3),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: holdings.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (_, i) => _HoldingCard(holding: holdings[i]),
    );
  }
}

// ── Individual holding card ───────────────────────────────────────────────────

class _HoldingCard extends StatelessWidget {
  const _HoldingCard({required this.holding});

  final _Holding holding;

  static final _priceFmt = NumberFormat('#,##0.##');
  static final _pctFmt = NumberFormat('0.00');

  @override
  Widget build(BuildContext context) {
    final isPnlPositive = holding.totalPnl >= 0;
    final pnlColor = isPnlPositive ? AppColors.green : AppColors.red;
    final pnlSign = isPnlPositive ? '+' : '';

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
          // ── Top row: name + logo ──────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo circle
              _LogoCircle(
                color: holding.logoColor,
                label: holding.logoLabel,
              ),

              // Name + code
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 10.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        holding.name,
                        style: AppTextStyles.bodyLg,
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        holding.code,
                        style: AppTextStyles.monoSm,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),
          Divider(color: AppColors.border, height: 1),
          SizedBox(height: 10.h),

          // ── Data row: qty | market value | pnl ───────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // P&L (left side = start side in RTL → shown on left)
              _DataCell(
                label: 'إجمالي ربح/خسارة',
                value:
                    '$pnlSign${_priceFmt.format(holding.totalPnl)} ($pnlSign${_pctFmt.format(holding.pnlPercent)}%)',
                valueColor: pnlColor,
                align: CrossAxisAlignment.start,
              ),

              // Market value
              _DataCell(
                label: 'القيمة السوقية',
                value: '﷼ ${_priceFmt.format(holding.marketValue)}',
                align: CrossAxisAlignment.center,
              ),

              // Quantity
              _DataCell(
                label: 'الكمية',
                value: holding.quantity.toStringAsFixed(2),
                align: CrossAxisAlignment.end,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LogoCircle extends StatelessWidget {
  const _LogoCircle({required this.color, this.label});

  final Color color;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      alignment: Alignment.center,
      child: label != null
          ? Text(
              label!,
              style: TextStyle(
                fontSize: 9.sp,
                fontWeight: FontWeight.w700,
                color: color,
              ),
              textAlign: TextAlign.center,
            )
          : Icon(Icons.trending_up_rounded, color: color, size: 18.sp),
    );
  }
}

class _DataCell extends StatelessWidget {
  const _DataCell({
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
          style: AppTextStyles.priceSm.copyWith(
            color: valueColor ?? AppColors.text1,
          ),
        ),
      ],
    );
  }
}
