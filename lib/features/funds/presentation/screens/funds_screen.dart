import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/investment_fund.dart';
import '../cubit/funds_cubit.dart';
import '../cubit/funds_state.dart';

class FundsScreen extends StatefulWidget {
  const FundsScreen({super.key});

  @override
  State<FundsScreen> createState() => _FundsScreenState();
}

class _FundsScreenState extends State<FundsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FundsCubit>().loadFunds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.bgApp,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: AppColors.text1,
          onPressed: () => context.pop(),
        ),
        title: Text(
          'صناديق الاستثمار',
          style: AppTextStyles.labelLg.copyWith(color: AppColors.text1),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<FundsCubit, FundsState>(
        builder: (context, state) {
          if (state is FundsLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.green));
          }
          if (state is FundsError) {
            return Center(
              child: Text(state.message,
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.red)),
            );
          }
          if (state is FundsLoaded) {
            return Column(
              children: [
                _FundsFilterBar(
                  active: state.activeFilter,
                  onFilter: context.read<FundsCubit>().filterByExchange,
                ),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.all(16.r),
                    itemCount: state.displayed.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (context, i) =>
                        _FundCard(fund: state.displayed[i]),
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _FundsFilterBar extends StatelessWidget {
  final FundExchange? active;
  final ValueChanged<FundExchange?> onFilter;

  const _FundsFilterBar({required this.active, required this.onFilter});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgApp,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        children: [
          _FundPill(label: 'الكل', active: active == null, onTap: () => onFilter(null)),
          SizedBox(width: 8.w),
          _FundPill(
              label: 'محلية',
              active: active == FundExchange.local,
              onTap: () => onFilter(FundExchange.local)),
          SizedBox(width: 8.w),
          _FundPill(
              label: 'أمريكية',
              active: active == FundExchange.us,
              onTap: () => onFilter(FundExchange.us)),
          SizedBox(width: 8.w),
          _FundPill(
              label: 'عالمية',
              active: active == FundExchange.global,
              onTap: () => onFilter(FundExchange.global)),
        ],
      ),
    );
  }
}

class _FundPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _FundPill({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: active ? AppColors.green : AppColors.bgPage,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
              color: active ? AppColors.green : AppColors.border),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSm.copyWith(
            color: active ? AppColors.white : AppColors.text2,
          ),
        ),
      ),
    );
  }
}

class _FundCard extends StatelessWidget {
  final InvestmentFund fund;

  const _FundCard({required this.fund});

  @override
  Widget build(BuildContext context) {
    final isPositive = fund.annualReturn > 0;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.bgApp,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  fund.symbol.substring(0, 1),
                  style: AppTextStyles.h4.copyWith(color: AppColors.white),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(fund.name,
                        style: AppTextStyles.labelMd
                            .copyWith(color: AppColors.text1)),
                    SizedBox(height: 3.h),
                    Row(
                      children: [
                        Text(fund.sector,
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.text3)),
                        if (fund.isShariaCompliant) ...[
                          SizedBox(width: 8.w),
                          Text('☽',
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.green)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Annual return badge
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isPositive ? AppColors.greenLite : AppColors.redLite,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '${isPositive ? '+' : ''}${fund.annualReturn.toStringAsFixed(1)}%',
                  style: AppTextStyles.labelSm.copyWith(
                    color: isPositive ? AppColors.green : AppColors.red,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Divider(height: 1, color: AppColors.border.withOpacity(0.5)),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (fund.unitPrice != null)
                _FundStat(
                    label: 'سعر الوحدة',
                    value: 'SAR ${fund.unitPrice!.toStringAsFixed(2)}'),
              if (fund.minInvestment != null)
                _FundStat(
                    label: 'الحد الأدنى',
                    value: 'SAR ${fund.minInvestment!.toStringAsFixed(0)}'),
              if (fund.distributionFrequency != null)
                _FundStat(
                    label: 'التوزيعات',
                    value: fund.distributionFrequency!),
            ],
          ),
          SizedBox(height: 14.h),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: double.infinity,
              height: 40.h,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10.r),
              ),
              alignment: Alignment.center,
              child: Text(
                'استثمر الآن',
                style: AppTextStyles.button.copyWith(color: AppColors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FundStat extends StatelessWidget {
  final String label;
  final String value;

  const _FundStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.caption.copyWith(color: AppColors.text4)),
        SizedBox(height: 2.h),
        Text(value,
            style: AppTextStyles.labelSm.copyWith(color: AppColors.text1)),
      ],
    );
  }
}
