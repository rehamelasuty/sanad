import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/order.dart';

// ─────────────────────────────────────────────────────────────────────────────
// OrderReceiptScreen
//
// Shown after a trade order is successfully placed.
// Receives [Order] + [stockName] via go_router's extra parameter.
// ─────────────────────────────────────────────────────────────────────────────

class OrderReceiptScreen extends StatefulWidget {
  const OrderReceiptScreen({
    super.key,
    required this.order,
    required this.stockName,
  });

  final Order order;
  final String stockName;

  @override
  State<OrderReceiptScreen> createState() => _OrderReceiptScreenState();
}

class _OrderReceiptScreenState extends State<OrderReceiptScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ctrl.forward();
      HapticFeedback.mediumImpact();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBuy = widget.order.side == OrderSide.buy;
    final color = isBuy ? AppColors.green : AppColors.red;
    final sideLabel = isBuy ? 'شراء' : 'بيع';
    final price = widget.order.filledPrice ?? widget.order.limitPrice ?? 0.0;
    final total = widget.order.quantity * price;
    final isSaudi = RegExp(r'^\d{4}$').hasMatch(widget.order.symbol);
    final currency = isSaudi ? '﷼' : '\$';
    final fmt = NumberFormat('#,##0.##');
    final dateFmt = DateFormat('d MMM y، h:mm a', 'ar');
    final isExecuted = widget.order.status == OrderStatus.filled;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────────────────
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                children: [
                  _CircleBtn(
                    icon: Icons.arrow_forward_ios_rounded,
                    onTap: () => context.pop(),
                  ),
                  const Spacer(),
                  Text('إيصال الأمر', style: AppTextStyles.h3),
                  const Spacer(),
                  SizedBox(width: 36.w), // balance left button
                ],
              ),
            ),

            // ── Scrollable content ───────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 22.w),
                child: Column(
                  children: [
                    SizedBox(height: 16.h),

                    // ── Animated checkmark ──────────────────────────────────
                    ScaleTransition(
                      scale: _scale,
                      child: Container(
                        width: 80.w,
                        height: 80.w,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isExecuted
                              ? Icons.check_rounded
                              : Icons.access_time_rounded,
                          size: 38.sp,
                          color: color,
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),

                    // ── Status title ────────────────────────────────────────
                    FadeTransition(
                      opacity: _fade,
                      child: Column(
                        children: [
                          Text(
                            isExecuted
                                ? 'تم تنفيذ الأمر بنجاح'
                                : 'تم استلام الأمر',
                            style: AppTextStyles.h3.copyWith(color: color),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '$sideLabel · ${widget.stockName}',
                            style: AppTextStyles.bodyMd
                                .copyWith(color: AppColors.text2),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 26.h),

                    // ── Receipt card ────────────────────────────────────────
                    FadeTransition(
                      opacity: _fade,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: AppRadius.mdAll,
                          boxShadow: AppShadows.sm,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header strip
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 18.w, vertical: 14.h),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.07),
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(AppRadius.md)),
                              ),
                              child: Row(
                                children: [
                                  _SideBadge(
                                      label: sideLabel, color: color),
                                  SizedBox(width: 10.w),
                                  Text(
                                    widget.order.symbol,
                                    style: AppTextStyles.labelLg,
                                  ),
                                  const Spacer(),
                                  Text(
                                    widget.order.id,
                                    style: AppTextStyles.monoSm
                                        .copyWith(color: AppColors.text3),
                                  ),
                                ],
                              ),
                            ),

                            // Detail rows
                            Padding(
                              padding: EdgeInsets.all(18.w),
                              child: Column(
                                children: [
                                  _ReceiptRow(
                                    label: 'نوع الأمر',
                                    value: widget.order.type == OrderType.market
                                        ? 'أمر السوق'
                                        : 'أمر محدد',
                                  ),
                                  const _ReceiptDivider(),
                                  _ReceiptRow(
                                    label: 'الكمية',
                                    value:
                                        '${widget.order.quantity.toInt()} سهم',
                                  ),
                                  const _ReceiptDivider(),
                                  _ReceiptRow(
                                    label: 'سعر التنفيذ',
                                    value: '$currency ${fmt.format(price)}',
                                  ),
                                  const _ReceiptDivider(),
                                  _ReceiptRow(
                                    label: 'الإجمالي',
                                    value: '$currency ${fmt.format(total)}',
                                    isTotal: true,
                                    totalColor: color,
                                  ),
                                  const _ReceiptDivider(),
                                  _ReceiptRow(
                                    label: 'الحالة',
                                    value: _statusLabel(widget.order.status),
                                  ),
                                  const _ReceiptDivider(),
                                  _ReceiptRow(
                                    label: 'التوقيت',
                                    value: dateFmt.format(
                                      widget.order.filledAt ??
                                          widget.order.createdAt,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),

            // ── Bottom actions ───────────────────────────────────────────────
            FadeTransition(
              opacity: _fade,
              child: Padding(
                padding:
                    EdgeInsets.fromLTRB(22.w, 8.h, 22.w, 20.h),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: () =>
                            context.go(AppRoutes.investmentsStocks),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.navy,
                          foregroundColor: AppColors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppRadius.mdAll,
                          ),
                          elevation: 0,
                        ),
                        child:
                            Text('عودة للسوق', style: AppTextStyles.button),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: OutlinedButton(
                        onPressed: () => context.go(AppRoutes.orders),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.navy,
                          side: const BorderSide(color: AppColors.border2),
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppRadius.mdAll,
                          ),
                        ),
                        child: Text(
                          'عرض الأوامر',
                          style: AppTextStyles.button
                              .copyWith(color: AppColors.navy),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(OrderStatus s) => switch (s) {
        OrderStatus.filled => '✅ منفذ',
        OrderStatus.pending => '⏳ معلق',
        OrderStatus.cancelled => '❌ ملغى',
        OrderStatus.rejected => '🚫 مرفوض',
      };
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          boxShadow: AppShadows.sm,
        ),
        child: Icon(icon, size: 16.sp, color: AppColors.text1),
      ),
    );
  }
}

class _SideBadge extends StatelessWidget {
  const _SideBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: AppRadius.fullAll,
      ),
      child: Text(
        label,
        style: AppTextStyles.badgeSm.copyWith(color: color),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({
    required this.label,
    required this.value,
    this.isTotal = false,
    this.totalColor,
  });

  final String label;
  final String value;
  final bool isTotal;
  final Color? totalColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? AppTextStyles.labelLg
              : AppTextStyles.bodyMd,
        ),
        Text(
          value,
          style: isTotal
              ? AppTextStyles.holdingPrice.copyWith(
                  color: totalColor ?? AppColors.text1,
                  fontSize: 15.sp,
                )
              : AppTextStyles.monoSm.copyWith(
                  color: AppColors.text1,
                  fontWeight: FontWeight.w600,
                ),
        ),
      ],
    );
  }
}

class _ReceiptDivider extends StatelessWidget {
  const _ReceiptDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(height: 20.h, color: AppColors.border);
  }
}
