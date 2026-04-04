import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../cubit/trade_cubit.dart';
import '../cubit/trade_state.dart';

class OrderSheet extends StatefulWidget {
  const OrderSheet({super.key});

  @override
  State<OrderSheet> createState() => _OrderSheetState();
}

class _OrderSheetState extends State<OrderSheet> {
  final _qtyController = TextEditingController(text: '1');

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TradeCubit, TradeState>(
      listener: (context, state) {
        if (state is TradeLoaded && state.orderSuccess) {
          _showSuccessSnackBar(context);
          context.read<TradeCubit>().dismissOrderSuccess();
        }
      },
      builder: (context, state) {
        if (state is! TradeLoaded) return const SizedBox.shrink();

        final isBuy = state.orderSide == OrderSideTab.buy;
        final actionColor = isBuy ? AppColors.green : AppColors.red;
        final currency = state.stock.exchange == 'تداول' ? 'ر.س' : 'USD';
        final total = state.quantity * state.stock.currentPrice;

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 22.w),
          padding: EdgeInsets.all(18.r),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppRadius.mdAll,
            boxShadow: AppShadows.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Buy / Sell toggle
              Container(
                height: 42.h,
                decoration: BoxDecoration(
                  color: AppColors.bgPage,
                ),
                child: Row(
                  children: [
                    _SideTab(
                      label: 'شراء',
                      active: isBuy,
                      color: AppColors.green,
                      onTap: () => context
                          .read<TradeCubit>()
                          .setOrderSide(OrderSideTab.buy),
                    ),
                    _SideTab(
                      label: 'بيع',
                      active: !isBuy,
                      color: AppColors.red,
                      onTap: () => context
                          .read<TradeCubit>()
                          .setOrderSide(OrderSideTab.sell),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // Quantity input
              Row(
                children: [
                  Text('الكمية', style: AppTextStyles.bodyMd),
                  const Spacer(),
                  _QtyButton(
                    icon: Icons.remove,
                    onTap: () {
                      final newQty = state.quantity - 1;
                      if (newQty >= 1) {
                        context.read<TradeCubit>().updateQuantity(newQty);
                        _qtyController.text = newQty.toInt().toString();
                      }
                    },
                  ),
                  SizedBox(
                    width: 56.w,
                    child: TextField(
                      controller: _qtyController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      style: AppTextStyles.monoSm.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.text1,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onChanged: (v) {
                        final qty = double.tryParse(v);
                        if (qty != null) {
                          context.read<TradeCubit>().updateQuantity(qty);
                        }
                      },
                    ),
                  ),
                  _QtyButton(
                    icon: Icons.add,
                    onTap: () {
                      final newQty = state.quantity + 1;
                      context.read<TradeCubit>().updateQuantity(newQty);
                      _qtyController.text = newQty.toInt().toString();
                    },
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // Estimated total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('الإجمالي التقديري', style: AppTextStyles.bodyMd),
                  Text(
                    '${total.toStringAsFixed(2)} $currency',
                    style: AppTextStyles.monoSm.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.text1,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Action button
              SizedBox(
                height: 48.h,
                child: ElevatedButton(
                  onPressed: state.isPlacingOrder
                      ? null
                      : () => context.read<TradeCubit>().placeOrder(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: actionColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    elevation: 0,
                  ),
                  child: state.isPlacingOrder
                      ? SizedBox(
                          width: 20.r,
                          height: 20.r,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          isBuy ? 'تأكيد الشراء' : 'تأكيد البيع',
                          style: AppTextStyles.button,
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSuccessSnackBar(BuildContext context) {
    final state = context.read<TradeCubit>().state;
    if (state is! TradeLoaded) return;
    final isBuy = state.orderSide == OrderSideTab.buy;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isBuy ? 'تم تنفيذ أمر الشراء بنجاح ✓' : 'تم تنفيذ أمر البيع بنجاح ✓',
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: isBuy ? AppColors.green : AppColors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r)),
      ),
    );
  }
}

class _SideTab extends StatelessWidget {
  const _SideTab({
    required this.label,
    required this.active,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: double.infinity,
          decoration: BoxDecoration(
            color: active ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.labelLg.copyWith(
              color: active ? Colors.white : AppColors.text3,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32.r,
        height: 32.r,
        decoration: BoxDecoration(
          color: AppColors.bgPage,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, size: 18.r, color: AppColors.text2),
      ),
    );
  }
}
