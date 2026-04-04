import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/dca_plan.dart';
import '../cubit/dca_cubit.dart';
import '../cubit/dca_state.dart';

// ─── Stock options for creating a plan ─────────────────────────────────────────
const _kStocks = [
  ('AAPL', 'Apple Inc.', true),
  ('2222', 'أرامكو السعودية', true),
  ('MSFT', 'Microsoft', false),
  ('NVDA', 'NVIDIA', true),
  ('META', 'Meta Platforms', false),
  ('1120', 'مصرف الراجحي', true),
];

class DcaScreen extends StatefulWidget {
  const DcaScreen({super.key});

  @override
  State<DcaScreen> createState() => _DcaScreenState();
}

class _DcaScreenState extends State<DcaScreen> {
  // ── Form state ────────────────────────────────────────────────────────────
  String _selectedSymbol = 'AAPL';
  String _selectedStockName = 'Apple Inc.';
  DcaFrequency _frequency = DcaFrequency.weekly;
  double _amount = 500;

  void _onAmountChanged(double delta) {
    setState(() {
      _amount = (_amount + delta).clamp(100, 10000);
    });
  }

  Future<void> _createPlan() async {
    final plan = DcaPlan(
      id: 'DCA-${DateTime.now().millisecondsSinceEpoch}',
      symbol: _selectedSymbol,
      stockName: _selectedStockName,
      amountPerCycle: _amount,
      frequency: _frequency,
      isActive: true,
      createdAt: DateTime.now(),
    );
    await context.read<DcaCubit>().createPlan(plan);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تفعيل الاستثمار الدوري بنجاح ✅',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.white)),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Scaffold(
      backgroundColor: cs.bgPage,
      body: BlocConsumer<DcaCubit, DcaState>(
        listener: (context, state) {
          if (state is DcaError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final plans = state is DcaLoaded ? state.plans : <DcaPlan>[];
          final isCreating =
              state is DcaLoaded ? state.isCreating : false;

          return SafeArea(
            child: CustomScrollView(
              slivers: [
                _DcaAppBar(cs: cs),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 12.h),
                      // ── Hero card ───────────────────────────────────
                      _HeroCard(cs: cs),
                      SizedBox(height: 20.h),

                      // ── Active plans section ────────────────────────
                      if (plans.isNotEmpty) ...[
                        _SectionHeader(
                          title: 'خططك النشطة (${plans.length})',
                          cs: cs,
                        ),
                        SizedBox(height: 8.h),
                        ...plans.map(
                          (p) => _PlanCard(
                            plan: p,
                            cs: cs,
                            onToggle: (active) =>
                                context.read<DcaCubit>().togglePlan(
                                      p.id,
                                      active: active,
                                    ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                      ],

                      // ── Create new plan ─────────────────────────────
                      _SectionHeader(title: 'إنشاء خطة جديدة', cs: cs),
                      SizedBox(height: 8.h),
                      _StockPicker(
                        selected: _selectedSymbol,
                        cs: cs,
                        onPick: (symbol, name) =>
                            setState(() {
                              _selectedSymbol = symbol;
                              _selectedStockName = name;
                            }),
                      ),
                      SizedBox(height: 14.h),
                      _SectionHeader(title: 'تكرار الاستثمار', cs: cs),
                      SizedBox(height: 8.h),
                      _FrequencyPicker(
                        selected: _frequency,
                        cs: cs,
                        onSelect: (f) => setState(() => _frequency = f),
                      ),
                      SizedBox(height: 14.h),
                      _AmountCard(
                        amount: _amount,
                        frequency: _frequency,
                        cs: cs,
                        onAdd: _onAmountChanged,
                      ),
                      SizedBox(height: 14.h),
                      _SummaryCard(
                        symbol: _selectedSymbol,
                        amount: _amount,
                        frequency: _frequency,
                        cs: cs,
                      ),
                      SizedBox(height: 20.h),
                      _ActivateButton(
                        isCreating: isCreating,
                        onPressed: _createPlan,
                        cs: cs,
                      ),
                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── App Bar ─────────────────────────────────────────────────────────────────
class _DcaAppBar extends StatelessWidget {
  const _DcaAppBar({required this.cs});
  final AppColorSet cs;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: false,
      floating: true,
      backgroundColor: cs.bgApp,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => context.pop(),
        child: Container(
          margin: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(11.r),
            border: Border.all(color: cs.border),
            boxShadow: AppShadows.sm,
          ),
          child: Icon(Icons.arrow_back_ios_new_rounded,
              size: 16.r, color: cs.text1),
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('الاستثمار الدوري (DCA)',
              style: AppTextStyles.labelLg.copyWith(color: cs.text1)),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppColors.goldLite,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.2)),
            ),
            child: Text('جديد',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.gold, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      centerTitle: false,
    );
  }
}

// ─── Hero card ────────────────────────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.cs});
  final AppColorSet cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 22.w),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: AppShadows.lg,
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            left: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.gold.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('📈  الاستثمار الذكي التلقائي',
                  style: AppTextStyles.caption.copyWith(
                      color: AppColors.white.withValues(alpha: 0.5))),
              SizedBox(height: 8.h),
              Text('استثمر تلقائياً في أوقات محددة',
                  style: AppTextStyles.h3
                      .copyWith(color: AppColors.white)),
              SizedBox(height: 6.h),
              Text(
                'قلل من تأثير تقلبات السوق بالشراء الدوري المنتظم',
                style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.white.withValues(alpha: 0.5),
                    height: 1.6),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.cs});
  final String title;
  final AppColorSet cs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 22.w),
      child: Text(title,
          style: AppTextStyles.labelLg.copyWith(color: cs.text1)),
    );
  }
}

// ─── Active plan card ─────────────────────────────────────────────────────────
class _PlanCard extends StatelessWidget {
  const _PlanCard(
      {required this.plan, required this.cs, required this.onToggle});

  final DcaPlan plan;
  final AppColorSet cs;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(22.w, 0, 22.w, 10.h),
      padding: EdgeInsets.all(15.r),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: cs.border),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        children: [
          // Symbol badge
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: AppColors.greenLite,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: cs.border),
            ),
            alignment: Alignment.center,
            child: Text(plan.symbol,
                style: AppTextStyles.caption.copyWith(
                    color: AppColors.green, fontWeight: FontWeight.w700)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plan.stockName,
                    style: AppTextStyles.labelMd
                        .copyWith(color: cs.text1)),
                SizedBox(height: 3.h),
                Text(
                  '${plan.amountPerCycle.toStringAsFixed(0)} ر.س · ${plan.frequency.label}',
                  style:
                      AppTextStyles.caption.copyWith(color: cs.text3),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Switch.adaptive(
                value: plan.isActive,
                onChanged: onToggle,
                activeColor: AppColors.navy,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              if (plan.nextRunAt != null)
                Text(
                  'التالي: ${_formatDate(plan.nextRunAt!)}',
                  style: AppTextStyles.caption.copyWith(
                      color: cs.text3,
                      fontSize: 9),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      '', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    return '${d.day} ${months[d.month]}';
  }
}

// ─── Stock picker ─────────────────────────────────────────────────────────────
class _StockPicker extends StatelessWidget {
  const _StockPicker(
      {required this.selected, required this.cs, required this.onPick});
  final String selected;
  final AppColorSet cs;
  final void Function(String symbol, String name) onPick;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 22.w),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: cs.border),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('السهم المستهدف',
              style: AppTextStyles.caption
                  .copyWith(color: cs.text3, fontWeight: FontWeight.w700)),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _kStocks.map((s) {
              final (sym, name, sharia) = s;
              final isSelected = sym == selected;
              return GestureDetector(
                onTap: () => onPick(sym, name),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: EdgeInsets.symmetric(
                      horizontal: 12.w, vertical: 7.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.navy.withValues(alpha: 0.08)
                        : cs.bgPage,
                    borderRadius: BorderRadius.circular(22.r),
                    border: Border.all(
                      color: isSelected ? AppColors.navy : cs.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(sym,
                          style: AppTextStyles.caption.copyWith(
                              color: isSelected
                                  ? AppColors.navy
                                  : cs.text2,
                              fontWeight: FontWeight.w700)),
                      if (sharia) ...[
                        SizedBox(width: 4.w),
                        Text('☽',
                            style: TextStyle(
                                fontSize: 10.sp,
                                color: AppColors.green)),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Frequency picker ─────────────────────────────────────────────────────────
class _FrequencyPicker extends StatelessWidget {
  const _FrequencyPicker(
      {required this.selected, required this.cs, required this.onSelect});
  final DcaFrequency selected;
  final AppColorSet cs;
  final ValueChanged<DcaFrequency> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 22.w),
      child: Row(
        children: DcaFrequency.values.map((f) {
          final isOn = f == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: EdgeInsets.only(
                    left: f != DcaFrequency.daily ? 8.w : 0),
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: isOn
                      ? AppColors.navy.withValues(alpha: 0.06)
                      : cs.surface,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: isOn ? AppColors.navy : cs.border,
                    width: isOn ? 1.5 : 1,
                  ),
                  boxShadow: AppShadows.sm,
                ),
                alignment: Alignment.center,
                child: Text(
                  f.label,
                  style: AppTextStyles.labelMd.copyWith(
                    color: isOn ? AppColors.navy : cs.text2,
                    fontWeight:
                        isOn ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Amount card ──────────────────────────────────────────────────────────────
class _AmountCard extends StatelessWidget {
  const _AmountCard({
    required this.amount,
    required this.frequency,
    required this.cs,
    required this.onAdd,
  });
  final double amount;
  final DcaFrequency frequency;
  final AppColorSet cs;
  final ValueChanged<double> onAdd;

  @override
  Widget build(BuildContext context) {
    final progress = ((amount - 100) / (10000 - 100)).clamp(0.0, 1.0);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 22.w),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: cs.border),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('المبلغ في كل ${frequency.label}',
              style: AppTextStyles.caption
                  .copyWith(color: cs.text3, fontWeight: FontWeight.w600)),
          SizedBox(height: 6.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(amount.toStringAsFixed(0),
                  style: AppTextStyles.portValue
                      .copyWith(color: cs.text1)),
              SizedBox(width: 6.w),
              Text('ر.س',
                  style: AppTextStyles.bodySm.copyWith(color: cs.text3)),
            ],
          ),
          SizedBox(height: 11.h),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(3.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5.h,
              backgroundColor: cs.border,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.navy),
            ),
          ),
          SizedBox(height: 6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('100 ر.س',
                  style:
                      AppTextStyles.caption.copyWith(color: cs.text3)),
              Text('10,000 ر.س',
                  style:
                      AppTextStyles.caption.copyWith(color: cs.text3)),
            ],
          ),
          SizedBox(height: 11.h),
          // Quick add buttons
          Row(
            children: [
              _QuickAdd(label: '+100', delta: 100, cs: cs, onTap: onAdd),
              SizedBox(width: 8.w),
              _QuickAdd(label: '+500', delta: 500, cs: cs, onTap: onAdd),
              SizedBox(width: 8.w),
              _QuickAdd(label: '+1,000', delta: 1000, cs: cs, onTap: onAdd),
              SizedBox(width: 8.w),
              Expanded(
                child: GestureDetector(
                  onTap: () => onAdd(10000 - amount),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    decoration: BoxDecoration(
                      color: AppColors.navy.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(9.r),
                      border: Border.all(
                          color: AppColors.navy.withValues(alpha: 0.12)),
                    ),
                    alignment: Alignment.center,
                    child: Text('الكل',
                        style: AppTextStyles.caption.copyWith(
                            color: AppColors.navy,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAdd extends StatelessWidget {
  const _QuickAdd(
      {required this.label,
      required this.delta,
      required this.cs,
      required this.onTap});
  final String label;
  final double delta;
  final AppColorSet cs;
  final ValueChanged<double> onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(delta),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: cs.bgPage,
            borderRadius: BorderRadius.circular(9.r),
            border: Border.all(color: cs.border),
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: AppTextStyles.caption
                  .copyWith(color: cs.text2, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

// ─── Summary card ─────────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.symbol,
    required this.amount,
    required this.frequency,
    required this.cs,
  });
  final String symbol;
  final double amount;
  final DcaFrequency frequency;
  final AppColorSet cs;

  @override
  Widget build(BuildContext context) {
    final monthly = switch (frequency) {
      DcaFrequency.daily => amount * 30,
      DcaFrequency.weekly => amount * 4,
      DcaFrequency.monthly => amount,
    };
    final dayLabel = switch (frequency) {
      DcaFrequency.daily => 'كل يوم',
      DcaFrequency.weekly => 'كل أحد',
      DcaFrequency.monthly => 'أول كل شهر',
    };

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 22.w),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.greenLite,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
            color: AppColors.green.withValues(alpha: 0.15),
            width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('📊  ملخص الخطة',
              style: AppTextStyles.labelMd
                  .copyWith(color: AppColors.green)),
          SizedBox(height: 9.h),
          _Row('السهم', symbol, cs),
          const _HDivider(),
          _Row('استثمار ${frequency.label}',
              '${amount.toStringAsFixed(0)} ر.س', cs),
          const _HDivider(),
          _Row('اليوم', dayLabel, cs),
          const _HDivider(),
          _Row(
            'شهرياً تقريباً',
            '${monthly.toStringAsFixed(0)} ر.س',
            cs,
            valueColor: AppColors.green,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, this.cs, {this.valueColor});
  final String label;
  final String value;
  final AppColorSet cs;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTextStyles.bodySm.copyWith(color: cs.text2)),
          Text(value,
              style: AppTextStyles.labelMd.copyWith(
                  color: valueColor ?? cs.text1)),
        ],
      ),
    );
  }
}

class _HDivider extends StatelessWidget {
  const _HDivider();

  @override
  Widget build(BuildContext context) =>
      Divider(color: AppColors.green.withValues(alpha: 0.12), height: 1);
}

// ─── Activate button ──────────────────────────────────────────────────────────
class _ActivateButton extends StatelessWidget {
  const _ActivateButton(
      {required this.isCreating, required this.onPressed, required this.cs});
  final bool isCreating;
  final VoidCallback onPressed;
  final AppColorSet cs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 22.w),
      child: GestureDetector(
        onTap: isCreating ? null : onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 15.h),
          decoration: BoxDecoration(
            color: AppColors.navy,
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: AppShadows.navyGlow,
          ),
          alignment: Alignment.center,
          child: isCreating
              ? SizedBox(
                  width: 20.r,
                  height: 20.r,
                  child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white),
                )
              : Text(
                  'تفعيل الاستثمار التلقائي',
                  style: AppTextStyles.button
                      .copyWith(color: AppColors.white),
                ),
        ),
      ),
    );
  }
}
