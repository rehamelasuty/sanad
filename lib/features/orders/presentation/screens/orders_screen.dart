import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../trade/domain/entities/order.dart';
import '../cubit/orders_cubit.dart';
import '../cubit/orders_state.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OrdersCubit>().loadOrders();
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
          'الأوامر',
          style: AppTextStyles.labelLg.copyWith(color: AppColors.text1),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (context, state) {
          if (state is OrdersLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.navy));
          }
          if (state is OrdersError) {
            return Center(
              child: Text(state.message,
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.red)),
            );
          }
          if (state is OrdersLoaded) {
            return Column(
              children: [
                _FilterBar(
                  active: state.activeFilter,
                  onFilter: context.read<OrdersCubit>().filterByStatus,
                ),
                Expanded(
                  child: state.displayed.isEmpty
                      ? Center(
                          child: Text('لا توجد أوامر',
                              style: AppTextStyles.bodySm
                                  .copyWith(color: AppColors.text3)))
                      : ListView.separated(
                          padding: EdgeInsets.all(16.r),
                          itemCount: state.displayed.length,
                          separatorBuilder: (_, __) => SizedBox(height: 10.h),
                          itemBuilder: (context, i) =>
                              _OrderCard(order: state.displayed[i]),
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

class _FilterBar extends StatelessWidget {
  final OrderStatus? active;
  final ValueChanged<OrderStatus?> onFilter;

  const _FilterBar({required this.active, required this.onFilter});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgApp,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _Pill(label: 'الكل', active: active == null, onTap: () => onFilter(null)),
            SizedBox(width: 8.w),
            _Pill(
                label: 'منفذ',
                active: active == OrderStatus.filled,
                onTap: () => onFilter(OrderStatus.filled)),
            SizedBox(width: 8.w),
            _Pill(
                label: 'معلق',
                active: active == OrderStatus.pending,
                onTap: () => onFilter(OrderStatus.pending)),
            SizedBox(width: 8.w),
            _Pill(
                label: 'ملغي',
                active: active == OrderStatus.cancelled,
                onTap: () => onFilter(OrderStatus.cancelled)),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Pill({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: active ? AppColors.navy : AppColors.bgPage,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
              color: active ? AppColors.navy : AppColors.border),
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

class _OrderCard extends StatelessWidget {
  final Order order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final isBuy = order.side == OrderSide.buy;
    final price = order.filledPrice ?? order.limitPrice ?? 0;
    final total = price * order.quantity;

    Color statusColor;
    String statusLabel;
    switch (order.status) {
      case OrderStatus.filled:
        statusColor = AppColors.green;
        statusLabel = 'منفذ';
      case OrderStatus.pending:
        statusColor = AppColors.gold;
        statusLabel = 'معلق';
      case OrderStatus.cancelled:
        statusColor = AppColors.text3;
        statusLabel = 'ملغي';
      case OrderStatus.rejected:
        statusColor = AppColors.red;
        statusLabel = 'مرفوض';
    }

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.bgApp,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Side indicator
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: isBuy ? AppColors.greenLite : AppColors.redLite,
              borderRadius: BorderRadius.circular(10.r),
            ),
            alignment: Alignment.center,
            child: Text(
              isBuy ? '↑' : '↓',
              style: TextStyle(
                fontSize: 20.sp,
                color: isBuy ? AppColors.green : AppColors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${isBuy ? 'شراء' : 'بيع'} ${order.symbol}',
                      style:
                          AppTextStyles.labelMd.copyWith(color: AppColors.text1),
                    ),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: AppTextStyles.priceM.copyWith(
                        color: isBuy ? AppColors.text1 : AppColors.red,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${order.quantity.toInt()} وحدة • \$${price.toStringAsFixed(2)}',
                      style:
                          AppTextStyles.caption.copyWith(color: AppColors.text3),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        statusLabel,
                        style:
                            AppTextStyles.caption.copyWith(color: statusColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
