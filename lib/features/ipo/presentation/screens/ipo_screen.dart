import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/ipo_listing.dart';
import '../cubit/ipo_cubit.dart';
import '../cubit/ipo_state.dart';

class IpoScreen extends StatefulWidget {
  const IpoScreen({super.key});

  @override
  State<IpoScreen> createState() => _IpoScreenState();
}

class _IpoScreenState extends State<IpoScreen> {
  @override
  void initState() {
    super.initState();
    context.read<IpoCubit>().loadListings();
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
          'الاكتتابات',
          style: AppTextStyles.labelLg.copyWith(color: AppColors.text1),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<IpoCubit, IpoState>(
        builder: (context, state) {
          if (state is IpoLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.green));
          }
          if (state is IpoError) {
            return Center(
              child: Text(state.message,
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.red)),
            );
          }
          if (state is IpoLoaded) {
            return Column(
              children: [
                _IpoFilterBar(
                  active: state.activeFilter,
                  onFilter: context.read<IpoCubit>().filterByStatus,
                ),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.all(16.r),
                    itemCount: state.displayed.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (context, i) =>
                        _IpoCard(listing: state.displayed[i]),
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

class _IpoFilterBar extends StatelessWidget {
  final IpoStatus? active;
  final ValueChanged<IpoStatus?> onFilter;

  const _IpoFilterBar({required this.active, required this.onFilter});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgApp,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        children: [
          _IpoPill(label: 'الكل', active: active == null, onTap: () => onFilter(null)),
          SizedBox(width: 8.w),
          _IpoPill(
              label: 'جارية',
              active: active == IpoStatus.current,
              onTap: () => onFilter(IpoStatus.current)),
          SizedBox(width: 8.w),
          _IpoPill(
              label: 'قادمة',
              active: active == IpoStatus.upcoming,
              onTap: () => onFilter(IpoStatus.upcoming)),
          SizedBox(width: 8.w),
          _IpoPill(
              label: 'مغلقة',
              active: active == IpoStatus.closed,
              onTap: () => onFilter(IpoStatus.closed)),
        ],
      ),
    );
  }
}

class _IpoPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _IpoPill({required this.label, required this.active, required this.onTap});

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

class _IpoCard extends StatelessWidget {
  final IpoListing listing;

  const _IpoCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    final isActive = listing.status == IpoStatus.current;
    final isClosed = listing.status == IpoStatus.closed;

    Color statusColor;
    String statusLabel;
    switch (listing.status) {
      case IpoStatus.current:
        statusColor = AppColors.green;
        statusLabel = 'جارية';
      case IpoStatus.upcoming:
        statusColor = AppColors.gold;
        statusLabel = 'قادمة';
      case IpoStatus.closed:
        statusColor = AppColors.text3;
        statusLabel = 'مغلقة';
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgApp,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isActive ? AppColors.green.withOpacity(0.4) : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(14.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Company avatar
                    Container(
                      width: 44.r,
                      height: 44.r,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        listing.symbol.substring(0, 1),
                        style: AppTextStyles.h4
                            .copyWith(color: AppColors.white),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(listing.name,
                              style: AppTextStyles.labelMd
                                  .copyWith(color: AppColors.text1)),
                          SizedBox(height: 2.h),
                          Row(
                            children: [
                              Text(listing.symbol,
                                  style: AppTextStyles.caption
                                      .copyWith(color: AppColors.text3)),
                              SizedBox(width: 8.w),
                              Text('•',
                                  style: AppTextStyles.caption
                                      .copyWith(color: AppColors.text4)),
                              SizedBox(width: 8.w),
                              Text(listing.sector,
                                  style: AppTextStyles.caption
                                      .copyWith(color: AppColors.text3)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Status badge
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(statusLabel,
                          style: AppTextStyles.badgeSm
                              .copyWith(color: statusColor)),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                // Details row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _IpoStat(
                        label: 'سعر الإصدار',
                        value: 'SAR ${listing.offeringPrice.toStringAsFixed(2)}'),
                    _IpoStat(
                        label: 'الحد الأدنى',
                        value: '${listing.minShares} سهم'),
                    if (listing.closingDate != null)
                      _IpoStat(
                          label: 'الإغلاق',
                          value: _formatDate(listing.closingDate!)),
                  ],
                ),
                if (isActive && listing.subscriptionRate > 0) ...[
                  SizedBox(height: 12.h),
                  // Subscription progress
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('نسبة الاكتتاب',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.text3)),
                      Text(
                        '${(listing.subscriptionRate * 100).toStringAsFixed(0)}%',
                        style: AppTextStyles.labelSm
                            .copyWith(color: AppColors.green),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: LinearProgressIndicator(
                      value: listing.subscriptionRate > 1
                          ? 1.0
                          : listing.subscriptionRate,
                      backgroundColor: AppColors.border,
                      color: AppColors.green,
                      minHeight: 6.h,
                    ),
                  ),
                ],
                if (listing.isShariaCompliant)
                  Padding(
                    padding: EdgeInsets.only(top: 10.h),
                    child: Row(
                      children: [
                        Text('☽ متوافق مع الشريعة',
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.green)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (!isClosed)
            Container(
              decoration: BoxDecoration(
                color: isActive ? AppColors.greenLite : AppColors.bgPage,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16.r),
                  bottomRight: Radius.circular(16.r),
                ),
              ),
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    isActive ? 'اشترك الآن' : 'سجل اهتمامك',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.button.copyWith(
                        color:
                            isActive ? AppColors.green : AppColors.text2),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}';
}

class _IpoStat extends StatelessWidget {
  final String label;
  final String value;

  const _IpoStat({required this.label, required this.value});

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
