import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/common/app_loading_error.dart';
import '../../domain/entities/murabaha_plan.dart';
import '../cubit/murabaha_cubit.dart';
import '../cubit/murabaha_state.dart';

class MurabahaScreen extends StatelessWidget {
  const MurabahaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MurabahaCubit>()..loadPlans(),
      child: const _MurabahaView(),
    );
  }
}

class _MurabahaView extends StatelessWidget {
  const _MurabahaView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: BlocConsumer<MurabahaCubit, MurabahaState>(
        listener: (context, state) {
          if (state is MurabahaLoaded && state.lastInvestment != null) {
            _showSuccessDialog(context, state);
          }
        },
        builder: (context, state) => switch (state) {
          MurabahaInitial() || MurabahaLoading() =>
            const Center(child: AppLoadingWidget()),
          MurabahaError(:final message) => Center(
              child: AppErrorWidget(
                message: message,
                onRetry: () => context.read<MurabahaCubit>().loadPlans(),
              ),
            ),
          MurabahaLoaded() => _MurabahaContent(state: state),
        },
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, MurabahaLoaded state) {
    final inv = state.lastInvestment!;
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r)),
        title: Row(
          children: [
            const Text('☽ ', style: TextStyle(fontSize: 20)),
            Text('تم الاستثمار بنجاح', style: AppTextStyles.h3),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DialogRow(
                label: 'المبلغ المستثمر',
                value: '${inv.principalAmount.toStringAsFixed(2)} ر.س'),
            _DialogRow(
                label: 'الربح المتوقع',
                value:
                    '+${inv.expectedProfit.toStringAsFixed(2)} ر.س'),
            _DialogRow(
                label: 'تاريخ الاستحقاق',
                value:
                    '${inv.maturityDate.day}/${inv.maturityDate.month}/${inv.maturityDate.year}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<MurabahaCubit>().dismissSuccess();
            },
            child: Text(
              'حسناً',
              style: TextStyle(color: AppColors.green),
            ),
          ),
        ],
      ),
    );
  }
}

class _MurabahaContent extends StatefulWidget {
  const _MurabahaContent({required this.state});

  final MurabahaLoaded state;

  @override
  State<_MurabahaContent> createState() => _MurabahaContentState();
}

class _MurabahaContentState extends State<_MurabahaContent> {
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _amountController.text =
        widget.state.amount.toStringAsFixed(0);
  }

  @override
  void didUpdateWidget(_MurabahaContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.selectedPlan != widget.state.selectedPlan) {
      _amountController.text =
          widget.state.amount.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    return CustomScrollView(
      slivers: [
        _MurabahaAppBar(),
        SliverToBoxAdapter(
          child: Column(
            children: [
              SizedBox(height: 8.h),
              _IslamicHeader(),
              SizedBox(height: 20.h),
              _PlanSelector(
                plans: state.plans,
                selectedPlan: state.selectedPlan,
              ),
              SizedBox(height: 20.h),
              if (state.selectedPlan != null) ...[
                _Calculator(
                  state: state,
                  amountController: _amountController,
                ),
                SizedBox(height: 20.h),
                _InvestButton(state: state),
                SizedBox(height: 20.h),
              ],
              _ShariaDisclaimerCard(),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ],
    );
  }
}

class _MurabahaAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.bgApp,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      title: Text('المرابحة الإسلامية', style: AppTextStyles.h3),
      centerTitle: false,
    );
  }
}

class _IslamicHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 22.w),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: AppColors.murabahaBgGradient,
        borderRadius: AppRadius.lgAll,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'استثمر بشكل شرعي',
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.gold,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'عوائد ثابتة متوافقة مع أحكام الشريعة الإسلامية',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.text2,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          Text(
            '☾',
            style: TextStyle(
              fontSize: 48.sp,
              color: AppColors.gold,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanSelector extends StatelessWidget {
  const _PlanSelector({
    required this.plans,
    required this.selectedPlan,
  });

  final List<MurabahaPlan> plans;
  final MurabahaPlan? selectedPlan;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 22.w),
          child: Text('اختر الخطة', style: AppTextStyles.h4),
        ),
        SizedBox(height: 10.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 22.w),
          child: Column(
            children: plans
                .map(
                  (p) => Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: _PlanCard(
                      plan: p,
                      isSelected: p.id == selectedPlan?.id,
                      onTap: () =>
                          context.read<MurabahaCubit>().selectPlan(p),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  final MurabahaPlan plan;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.goldLite : AppColors.white,
          borderRadius: AppRadius.mdAll,
          border: Border.all(
            color: isSelected
                ? AppColors.gold
                : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected ? AppShadows.sm : [],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plan.type.label, style: AppTextStyles.h4),
                  SizedBox(height: 4.h),
                  Text(
                    '${plan.termDays} يوم · '
                    'حد أدنى ${(plan.minAmount / 1000).toStringAsFixed(0)}ألف ر.س',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${plan.annualRatePercent.toStringAsFixed(2)}%',
                  style: AppTextStyles.monoSm.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 18.sp,
                    color: AppColors.gold,
                  ),
                ),
                Text(
                  'سنوياً',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Calculator extends StatelessWidget {
  const _Calculator({
    required this.state,
    required this.amountController,
  });

  final MurabahaLoaded state;
  final TextEditingController amountController;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 22.w),
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.mdAll,
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('احسب عائدك', style: AppTextStyles.h4),
          SizedBox(height: 16.h),
          // Amount input
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            style: AppTextStyles.priceM.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.text1,
            ),
            decoration: InputDecoration(
              prefixText: 'ر.س  ',
              prefixStyle: AppTextStyles.bodyMd.copyWith(
                color: AppColors.text3,
              ),
              hintText: 'أدخل المبلغ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.gold, width: 1.5),
              ),
            ),
            onChanged: (v) {
              final amount = double.tryParse(v);
              if (amount != null) {
                context.read<MurabahaCubit>().updateAmount(amount);
              }
            },
          ),
          SizedBox(height: 16.h),
          // Return breakdown
          _ReturnRow(
            label: 'المبلغ المستثمر',
            value: '${state.amount.toStringAsFixed(2)} ر.س',
            isBold: false,
          ),
          SizedBox(height: 8.h),
          _ReturnRow(
            label:
                'الربح المتوقع (${state.selectedPlan!.termDays} يوم)',
            value:
                '+${state.expectedReturn.toStringAsFixed(2)} ر.س',
            valueColor: AppColors.gold,
          ),
          Divider(height: 20.h, color: AppColors.border),
          _ReturnRow(
            label: 'الإجمالي عند الاستحقاق',
            value: '${state.totalPayout.toStringAsFixed(2)} ر.س',
            isBold: true,
          ),
        ],
      ),
    );
  }
}

class _ReturnRow extends StatelessWidget {
  const _ReturnRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold ? AppTextStyles.bodyLg : AppTextStyles.bodyMd,
        ),
        Text(
          value,
          style: AppTextStyles.monoSm.copyWith(
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? AppColors.text1,
            fontSize: isBold ? 15.sp : null,
          ),
        ),
      ],
    );
  }
}

class _InvestButton extends StatelessWidget {
  const _InvestButton({required this.state});

  final MurabahaLoaded state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 22.w),
      child: SizedBox(
        width: double.infinity,
        height: 52.h,
        child: ElevatedButton(
          onPressed: state.isInvesting || state.selectedPlan == null
              ? null
              : () => context.read<MurabahaCubit>().invest(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
            elevation: 0,
          ),
          child: state.isInvesting
              ? SizedBox(
                  width: 22.r,
                  height: 22.r,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  'استثمر الآن ☽',
                  style: AppTextStyles.button.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16.sp,
                  ),
                ),
        ),
      ),
    );
  }
}

class _ShariaDisclaimerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 22.w),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.goldLite,
        borderRadius: AppRadius.mdAll,
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '☽ ',
                style: TextStyle(
                    fontSize: 14.sp, color: AppColors.gold),
              ),
              Text(
                'إفصاح شرعي',
                style: AppTextStyles.labelLg.copyWith(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'تعمل عوائد وفق أحكام الشريعة الإسلامية بصيغة المرابحة '
            'المعتمدة من هيئة الرقابة الشرعية. العوائد المعلنة إرشادية '
            'وقد تختلف بناءً على ظروف السوق. الاستثمار في المرابحات '
            'لا يتضمن فوائد ربوية محرمة.',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.text2,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogRow extends StatelessWidget {
  const _DialogRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMd),
          Text(
            value,
            style: AppTextStyles.monoSm.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.text1,
            ),
          ),
        ],
      ),
    );
  }
}
