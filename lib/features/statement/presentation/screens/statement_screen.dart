import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/transaction_item.dart';
import '../../domain/repositories/statement_repository.dart';
import '../cubit/statement_cubit.dart';
import '../cubit/statement_state.dart';

class StatementScreen extends StatefulWidget {
  const StatementScreen({super.key});

  @override
  State<StatementScreen> createState() => _StatementScreenState();
}

class _StatementScreenState extends State<StatementScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StatementCubit>().loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Scaffold(
      backgroundColor: cs.bgPage,
      appBar: AppBar(
        backgroundColor: cs.bgApp,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: cs.text1,
          onPressed: () => context.pop(),
        ),
        title: Text(
          'كشف الحساب',
          style: AppTextStyles.labelLg.copyWith(color: cs.text1),
        ),
        centerTitle: true,
        actions: [
          _ExportButton(cs: cs),
          SizedBox(width: 8.w),
        ],
      ),
      body: BlocBuilder<StatementCubit, StatementState>(
        builder: (context, state) {
          return Column(
            children: [
              // Period filter bar
              _PeriodFilter(
                active: state is StatementLoaded
                    ? state.activePeriod
                    : StatementPeriod.thisMonth,
                onSelect: context.read<StatementCubit>().changePeriod,
              ),
              if (state is StatementLoaded) ...[
                // Summary card
                _SummaryCard(state: state),
                // List
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.all(16.r),
                    itemCount: state.transactions.length,
                    separatorBuilder: (_, __) => SizedBox(height: 8.h),
                    itemBuilder: (context, i) =>
                        _TransactionCard(item: state.transactions[i]),
                  ),
                ),
              ] else if (state is StatementLoading)
                const Expanded(
                    child: Center(
                        child: CircularProgressIndicator(
                            color: AppColors.green)))
              else if (state is StatementError)
                Expanded(
                  child: Center(
                    child: Text(state.message,
                        style:
                            AppTextStyles.bodySm.copyWith(color: AppColors.red)),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _PeriodFilter extends StatelessWidget {
  final StatementPeriod active;
  final ValueChanged<StatementPeriod> onSelect;

  const _PeriodFilter({required this.active, required this.onSelect});

  static const _periods = [
    (StatementPeriod.thisMonth, 'هذا الشهر'),
    (StatementPeriod.lastMonth, 'الشهر الماضي'),
    (StatementPeriod.threeMonths, '3 أشهر'),
    (StatementPeriod.year, 'سنة'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgApp,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _periods.map((pair) {
            final (period, label) = pair;
            final isActive = active == period;
            return Padding(
              padding: EdgeInsets.only(left: 8.w),
              child: GestureDetector(
                onTap: () => onSelect(period),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 14.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.navy : AppColors.bgPage,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                        color: isActive ? AppColors.navy : AppColors.border),
                  ),
                  child: Text(
                    label,
                    style: AppTextStyles.labelSm.copyWith(
                      color: isActive ? AppColors.white : AppColors.text2,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final StatementLoaded state;

  const _SummaryCard({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.r),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatCol(
              label: 'إجمالي الوارد',
              value: 'SAR ${state.totalCredit.toStringAsFixed(0)}',
              icon: '↑',
              color: AppColors.white,
            ),
          ),
          Container(width: 1, height: 40.h, color: AppColors.white.withOpacity(0.3)),
          Expanded(
            child: _StatCol(
              label: 'إجمالي الصادر',
              value: 'SAR ${state.totalDebit.toStringAsFixed(0)}',
              icon: '↓',
              color: AppColors.white,
            ),
          ),
          Container(width: 1, height: 40.h, color: AppColors.white.withOpacity(0.3)),
          Expanded(
            child: _StatCol(
              label: 'صافي',
              value: 'SAR ${(state.totalCredit - state.totalDebit).toStringAsFixed(0)}',
              icon: '=',
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCol extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  final Color color;

  const _StatCol({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: TextStyle(fontSize: 16.sp, color: color)),
        SizedBox(height: 4.h),
        Text(value,
            style: AppTextStyles.labelSm.copyWith(color: color)),
        SizedBox(height: 2.h),
        Text(label,
            style: AppTextStyles.caption.copyWith(
                color: color.withOpacity(0.75))),
      ],
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final TransactionItem item;

  const _TransactionCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.bgApp,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: item.isCredit ? AppColors.greenLite : AppColors.redLite,
              borderRadius: BorderRadius.circular(10.r),
            ),
            alignment: Alignment.center,
            child: Text(item.iconEmoji, style: TextStyle(fontSize: 18.sp)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: AppTextStyles.labelMd
                        .copyWith(color: AppColors.text1)),
                SizedBox(height: 3.h),
                Text(item.subtitle,
                    style:
                        AppTextStyles.caption.copyWith(color: AppColors.text3)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.isCredit ? '+' : '-'}SAR ${item.amount.toStringAsFixed(2)}',
                style: AppTextStyles.priceM.copyWith(
                  color: item.isCredit ? AppColors.green : AppColors.red,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                _formatDate(item.createdAt),
                style: AppTextStyles.caption.copyWith(color: AppColors.text4),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
  }
}

// ─── Export button ─────────────────────────────────────────────────────────────
class _ExportButton extends StatelessWidget {
  const _ExportButton({required this.cs});
  final AppColorSet cs;

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: cs.bgApp,
          borderRadius: BorderRadius.circular(20.r),
        ),
        padding: EdgeInsets.all(20.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('تصدير كشف الحساب',
                style: AppTextStyles.labelLg.copyWith(color: cs.text1)),
            SizedBox(height: 16.h),
            _ExportOption(
              icon: Icons.picture_as_pdf_rounded,
              label: 'تصدير PDF',
              sub: 'مناسب للطباعة والأرشفة',
              color: AppColors.red,
              cs: cs,
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('جاري تحضير ملف PDF... 📄',
                        style: AppTextStyles.bodySm
                            .copyWith(color: AppColors.white)),
                    backgroundColor: AppColors.navy,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                  ),
                );
              },
            ),
            SizedBox(height: 10.h),
            _ExportOption(
              icon: Icons.table_chart_rounded,
              label: 'تصدير CSV',
              sub: 'للتحليل في Excel أو Google Sheets',
              color: AppColors.green,
              cs: cs,
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('جاري تحضير ملف CSV... 📊',
                        style: AppTextStyles.bodySm
                            .copyWith(color: AppColors.white)),
                    backgroundColor: AppColors.navy,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                  ),
                );
              },
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showMenu(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: cs.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.download_rounded, size: 16.r, color: AppColors.navy),
            SizedBox(width: 4.w),
            Text('تصدير',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.navy, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _ExportOption extends StatelessWidget {
  const _ExportOption({
    required this.icon,
    required this.label,
    required this.sub,
    required this.color,
    required this.cs,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final String sub;
  final Color color;
  final AppColorSet cs;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: cs.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(11.r),
              ),
              child: Icon(icon, color: color, size: 20.r),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: AppTextStyles.labelMd.copyWith(color: cs.text1)),
                  SizedBox(height: 2.h),
                  Text(sub,
                      style: AppTextStyles.caption.copyWith(color: cs.text3)),
                ],
              ),
            ),
            Icon(Icons.chevron_left_rounded, color: cs.text3, size: 18.r),
          ],
        ),
      ),
    );
  }
}
