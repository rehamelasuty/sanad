import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/price_alert.dart';
import '../cubit/price_alerts_cubit.dart';
import '../cubit/price_alerts_state.dart';

// ─── Stock options ────────────────────────────────────────────────────────────
const _kStocks = [
  ('AAPL', 'Apple Inc.', 189.50),
  ('2222', 'أرامكو السعودية', 28.90),
  ('MSFT', 'Microsoft', 415.20),
  ('NVDA', 'NVIDIA', 875.60),
  ('1120', 'مصرف الراجحي', 96.50),
  ('1010', 'سابك', 77.30),
];

class PriceAlertsScreen extends StatefulWidget {
  const PriceAlertsScreen({super.key});

  @override
  State<PriceAlertsScreen> createState() => _PriceAlertsScreenState();
}

class _PriceAlertsScreenState extends State<PriceAlertsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PriceAlertsCubit>().loadAlerts();
  }

  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<PriceAlertsCubit>(),
        child: const _AddAlertSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Scaffold(
      backgroundColor: cs.bgPage,
      body: BlocConsumer<PriceAlertsCubit, PriceAlertsState>(
        listener: (context, state) {
          if (state is PriceAlertsError) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: CustomScrollView(
              slivers: [
                _AlertsAppBar(cs: cs, onAdd: _showAddSheet),
                if (state is PriceAlertsLoading)
                  const SliverFillRemaining(
                      child: Center(
                          child: CircularProgressIndicator(
                              color: AppColors.navy)))
                else if (state is PriceAlertsLoaded) ...[
                  if (state.alerts.isNotEmpty)
                    SliverToBoxAdapter(
                        child: _StatsRow(state: state, cs: cs)),
                  SliverToBoxAdapter(child: SizedBox(height: 12.h)),
                  if (state.alerts.isEmpty)
                    SliverFillRemaining(
                        child: _EmptyState(cs: cs, onAdd: _showAddSheet))
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) {
                          final alert = state.alerts[i];
                          return _AlertCard(
                            alert: alert,
                            cs: cs,
                            onToggle: (active) =>
                                context
                                    .read<PriceAlertsCubit>()
                                    .toggleAlert(alert.id, active: active),
                            onDelete: () =>
                                context
                                    .read<PriceAlertsCubit>()
                                    .deleteAlert(alert.id),
                          );
                        },
                        childCount: state.alerts.length,
                      ),
                    ),
                ],
              ],
            ),
          );
        },
      ),
      floatingActionButton: _FabAdd(onTap: _showAddSheet),
    );
  }
}

// ─── App Bar ─────────────────────────────────────────────────────────────────
class _AlertsAppBar extends StatelessWidget {
  const _AlertsAppBar({required this.cs, required this.onAdd});
  final AppColorSet cs;
  final VoidCallback onAdd;

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
      title: Text('تنبيهات الأسعار',
          style: AppTextStyles.labelLg.copyWith(color: cs.text1)),
      centerTitle: false,
    );
  }
}

// ─── Stats row ────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.state, required this.cs});
  final PriceAlertsLoaded state;
  final AppColorSet cs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 6.h),
      child: Row(
        children: [
          _StatChip(
            label: 'نشط',
            value: state.activeCount.toString(),
            color: AppColors.green,
            lite: AppColors.greenLite,
          ),
          SizedBox(width: 8.w),
          _StatChip(
            label: 'مُفعَّل',
            value: state.triggeredCount.toString(),
            color: AppColors.gold,
            lite: AppColors.goldLite,
          ),
          SizedBox(width: 8.w),
          _StatChip(
            label: 'الكل',
            value: state.alerts.length.toString(),
            color: cs.text2,
            lite: cs.surface,
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    required this.lite,
  });
  final String label;
  final String value;
  final Color color;
  final Color lite;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: lite,
        borderRadius: BorderRadius.circular(9.r),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: AppTextStyles.labelMd
                  .copyWith(color: color, fontWeight: FontWeight.w800)),
          SizedBox(width: 4.w),
          Text(label,
              style: AppTextStyles.caption.copyWith(color: color)),
        ],
      ),
    );
  }
}

// ─── Alert card ───────────────────────────────────────────────────────────────
class _AlertCard extends StatelessWidget {
  const _AlertCard({
    required this.alert,
    required this.cs,
    required this.onToggle,
    required this.onDelete,
  });
  final PriceAlert alert;
  final AppColorSet cs;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isUp = alert.direction == AlertDirection.above;
    final dirColor = isUp ? AppColors.green : AppColors.red;
    final dirLite = isUp ? AppColors.greenLite : AppColors.redLite;
    final dist = alert.distancePercent;

    return Dismissible(
      key: Key(alert.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: EdgeInsets.fromLTRB(22.w, 0, 22.w, 12.h),
        decoration: BoxDecoration(
          color: AppColors.red.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.red.withValues(alpha: 0.2)),
        ),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 20.w),
        child: Icon(Icons.delete_outline_rounded,
            color: AppColors.red, size: 22.r),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('حذف التنبيه'),
            content: Text(
                'هل تريد حذف تنبيه ${alert.symbol} بسعر ${alert.targetPrice}؟'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('إلغاء')),
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('حذف',
                      style: TextStyle(color: AppColors.red))),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: EdgeInsets.fromLTRB(22.w, 0, 22.w, 12.h),
        padding: EdgeInsets.all(15.r),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
              color: alert.isTriggered
                  ? AppColors.gold.withValues(alpha: 0.3)
                  : cs.border),
          boxShadow: AppShadows.sm,
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Symbol
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: dirLite,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                        color: dirColor.withValues(alpha: 0.15)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    alert.direction.icon,
                    style: TextStyle(fontSize: 18.sp),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(alert.stockName,
                          style: AppTextStyles.labelMd
                              .copyWith(color: cs.text1)),
                      SizedBox(height: 2.h),
                      Text(
                        '${alert.symbol} · ${alert.direction.label} ${alert.targetPrice.toStringAsFixed(2)}',
                        style: AppTextStyles.caption
                            .copyWith(color: cs.text3),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Switch.adaptive(
                      value: alert.isActive,
                      onChanged:
                          alert.isTriggered ? null : onToggle,
                      activeColor: AppColors.navy,
                      materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                    ),
                    if (alert.isTriggered)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 7.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppColors.goldLite,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text('مُفعَّل',
                            style: AppTextStyles.caption.copyWith(
                                color: AppColors.gold,
                                fontWeight: FontWeight.w700,
                                fontSize: 9.sp)),
                      ),
                  ],
                ),
              ],
            ),
            // Distance bar
            if (dist != null && !alert.isTriggered) ...[
              SizedBox(height: 10.h),
              _DistanceBar(dist: dist, dirColor: dirColor, cs: cs),
            ],
          ],
        ),
      ),
    );
  }
}

class _DistanceBar extends StatelessWidget {
  const _DistanceBar(
      {required this.dist,
      required this.dirColor,
      required this.cs});
  final double dist;
  final Color dirColor;
  final AppColorSet cs;

  @override
  Widget build(BuildContext context) {
    final progress = (1 - (dist.abs() / 20)).clamp(0.0, 1.0);
    final label = dist > 0
        ? 'يبعد ${dist.abs().toStringAsFixed(1)}%'
        : 'تجاوز الهدف';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: cs.border, height: 1),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('المسافة للهدف',
                style: AppTextStyles.caption.copyWith(color: cs.text3)),
            Text(label,
                style: AppTextStyles.caption
                    .copyWith(color: dirColor, fontWeight: FontWeight.w700)),
          ],
        ),
        SizedBox(height: 5.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(3.r),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4.h,
            backgroundColor: cs.border,
            valueColor: AlwaysStoppedAnimation<Color>(dirColor),
          ),
        ),
      ],
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.cs, required this.onAdd});
  final AppColorSet cs;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.r,
            height: 80.r,
            decoration: BoxDecoration(
              color: cs.surface,
              shape: BoxShape.circle,
              border: Border.all(color: cs.border),
            ),
            child: Icon(Icons.notifications_none_rounded,
                size: 36.r, color: cs.text3),
          ),
          SizedBox(height: 16.h),
          Text('لا توجد تنبيهات بعد',
              style: AppTextStyles.labelLg.copyWith(color: cs.text2)),
          SizedBox(height: 6.h),
          Text('أضف تنبيهاً لمتابعة تحركات الأسعار',
              style: AppTextStyles.bodySm.copyWith(color: cs.text3)),
          SizedBox(height: 20.h),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: AppShadows.navyGlow,
              ),
              child: Text('+ إضافة تنبيه',
                  style:
                      AppTextStyles.button.copyWith(color: AppColors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── FAB ──────────────────────────────────────────────────────────────────────
class _FabAdd extends StatelessWidget {
  const _FabAdd({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 54.r,
        height: 54.r,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: AppShadows.navyGlow,
        ),
        child: Icon(Icons.add_rounded, color: AppColors.white, size: 26.r),
      ),
    );
  }
}

// ─── Add alert bottom sheet ───────────────────────────────────────────────────
class _AddAlertSheet extends StatefulWidget {
  const _AddAlertSheet();

  @override
  State<_AddAlertSheet> createState() => _AddAlertSheetState();
}

class _AddAlertSheetState extends State<_AddAlertSheet> {
  String _selectedSymbol = 'AAPL';
  String _selectedStockName = 'Apple Inc.';
  double _selectedCurrentPrice = 189.50;
  AlertDirection _direction = AlertDirection.above;
  final _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _priceController.text = '200.00';
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final price = double.tryParse(_priceController.text.trim());
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل سعراً صحيحاً')),
      );
      return;
    }
    final alert = PriceAlert(
      id: 'PA-${DateTime.now().millisecondsSinceEpoch}',
      symbol: _selectedSymbol,
      stockName: _selectedStockName,
      targetPrice: price,
      direction: _direction,
      isActive: true,
      createdAt: DateTime.now(),
      currentPrice: _selectedCurrentPrice,
    );
    await context.read<PriceAlertsCubit>().createAlert(alert);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إضافة التنبيه ✅',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.white)),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;

    return Container(
      margin: EdgeInsets.only(
          top: 60.h,
          bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: cs.bgApp,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(22.w, 18.h, 22.w, 30.h),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 18.h),
                decoration: BoxDecoration(
                  color: cs.border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            Text('إضافة تنبيه سعري',
                style: AppTextStyles.h3.copyWith(color: cs.text1)),
            SizedBox(height: 18.h),
            // Stock
            Text('اختر السهم',
                style: AppTextStyles.caption.copyWith(
                    color: cs.text3, fontWeight: FontWeight.w700)),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: _kStocks.map((s) {
                final (sym, name, price) = s;
                final isOn = sym == _selectedSymbol;
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedSymbol = sym;
                    _selectedStockName = name;
                    _selectedCurrentPrice = price;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    padding: EdgeInsets.symmetric(
                        horizontal: 12.w, vertical: 7.h),
                    decoration: BoxDecoration(
                      color: isOn
                          ? AppColors.navy.withValues(alpha: 0.08)
                          : cs.surface,
                      borderRadius: BorderRadius.circular(22.r),
                      border: Border.all(
                        color: isOn ? AppColors.navy : cs.border,
                        width: isOn ? 1.5 : 1,
                      ),
                    ),
                    child: Text(sym,
                        style: AppTextStyles.caption.copyWith(
                            color: isOn ? AppColors.navy : cs.text2,
                            fontWeight: FontWeight.w700)),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16.h),
            // Direction
            Text('الاتجاه',
                style: AppTextStyles.caption.copyWith(
                    color: cs.text3, fontWeight: FontWeight.w700)),
            SizedBox(height: 8.h),
            Row(
              children: AlertDirection.values.map((d) {
                final isOn = d == _direction;
                final color =
                    d == AlertDirection.above ? AppColors.green : AppColors.red;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _direction = d),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      margin: EdgeInsets.only(
                          left: d != AlertDirection.above ? 8.w : 0),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        color: isOn
                            ? color.withValues(alpha: 0.08)
                            : cs.surface,
                        borderRadius: BorderRadius.circular(13.r),
                        border: Border.all(
                          color: isOn ? color : cs.border,
                          width: isOn ? 1.5 : 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Text(d.icon,
                              style: TextStyle(fontSize: 18.sp)),
                          SizedBox(height: 3.h),
                          Text(
                            d == AlertDirection.above ? 'صعود' : 'هبوط',
                            style: AppTextStyles.caption.copyWith(
                                color: isOn ? color : cs.text2,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16.h),
            // Price input
            Text('السعر المستهدف',
                style: AppTextStyles.caption.copyWith(
                    color: cs.text3, fontWeight: FontWeight.w700)),
            SizedBox(height: 8.h),
            Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(13.r),
                border: Border.all(color: cs.border),
              ),
              child: TextField(
                controller: _priceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                style:
                    AppTextStyles.portValue.copyWith(color: cs.text1),
                decoration: InputDecoration(
                  hintText: 'أدخل السعر',
                  hintStyle: AppTextStyles.bodySm.copyWith(color: cs.text3),
                  suffixText: 'ر.س',
                  suffixStyle:
                      AppTextStyles.bodySm.copyWith(color: cs.text3),
                  filled: false,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 14.w, vertical: 14.h),
                ),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
                'السعر الحالي لـ $_selectedSymbol: ${_selectedCurrentPrice.toStringAsFixed(2)} ر.س',
                style: AppTextStyles.caption.copyWith(color: cs.text3)),
            SizedBox(height: 22.h),
            // Save button
            GestureDetector(
              onTap: _save,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 15.h),
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: AppShadows.navyGlow,
                ),
                alignment: Alignment.center,
                child: Text('حفظ التنبيه',
                    style: AppTextStyles.button
                        .copyWith(color: AppColors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
