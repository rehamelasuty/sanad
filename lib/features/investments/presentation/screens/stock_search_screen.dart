import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../market_feed/domain/entities/market_tick.dart';
import '../../../market_feed/presentation/cubit/market_feed_cubit.dart';
import '../../../market_feed/presentation/cubit/market_feed_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// StockSearchScreen
//
// Full-screen search that filters symbols live from MarketFeedCubit.
// Provided at app-level so no BlocProvider needed here.
// ─────────────────────────────────────────────────────────────────────────────

const _kLogoColors = <Color>[
  Color(0xFF1A7C5E),
  Color(0xFF1B4FA8),
  Color(0xFFC9322A),
  Color(0xFFC9922A),
  Color(0xFF5E348B),
  Color(0xFF0D6E8C),
  Color(0xFF2E7D32),
  Color(0xFF8D1F8D),
];

Color _logoColor(String symbol) =>
    _kLogoColors[symbol.hashCode.abs() % _kLogoColors.length];

String _shortLabel(String s) => s.length > 4 ? s.substring(0, 4) : s;

class StockSearchScreen extends StatefulWidget {
  const StockSearchScreen({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  State<StockSearchScreen> createState() => _StockSearchScreenState();
}

class _StockSearchScreenState extends State<StockSearchScreen> {
  late final TextEditingController _ctrl;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialQuery);
    _query = widget.initialQuery;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<MarketTick> _filter(Map<String, MarketTick> tickMap) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return tickMap.values.toList();
    final results = tickMap.values
        .where((t) =>
            t.symbol.toLowerCase().contains(q) ||
            t.name.toLowerCase().contains(q))
        .toList();
    results.sort((a, b) {
      final aExact = a.symbol.toLowerCase() == q ? 0 : 1;
      final bExact = b.symbol.toLowerCase() == q ? 0 : 1;
      return aExact.compareTo(bExact);
    });
    return results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Column(
          children: [
            // ── Search bar ────────────────────────────────────────────────────
            Container(
              color: AppColors.white,
              padding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44.h,
                      decoration: BoxDecoration(
                        color: AppColors.bgPage,
                        borderRadius: AppRadius.fullAll,
                      ),
                      child: TextField(
                        controller: _ctrl,
                        autofocus: true,
                        style: AppTextStyles.bodyLg,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'ابحث باسم السهم أو رمزه...',
                          hintStyle: AppTextStyles.bodyMd
                              .copyWith(color: AppColors.text3),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: AppColors.text3,
                            size: 20.sp,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 12.h),
                          isDense: true,
                        ),
                        onChanged: (v) => setState(() => _query = v),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Text(
                      'إلغاء',
                      style: AppTextStyles.labelMd
                          .copyWith(color: AppColors.navy),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),

            // ── Results ───────────────────────────────────────────────────────
            Expanded(
              child: BlocBuilder<MarketFeedCubit, MarketFeedState>(
                builder: (context, state) {
                  if (state is MarketFeedConnecting ||
                      state is MarketFeedInitial) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.navy,
                        strokeWidth: 2,
                      ),
                    );
                  }
                  if (state is! MarketFeedConnected) {
                    return _EmptyState(
                      icon: Icons.wifi_off_rounded,
                      message: 'لم يتم الاتصال بالسوق بعد',
                    );
                  }

                  final results = _filter(state.tickMap);

                  if (results.isEmpty) {
                    return _EmptyState(
                      icon: Icons.search_off_rounded,
                      message: 'لا توجد نتائج لـ "$_query"',
                    );
                  }

                  return ListView.separated(
                    padding: EdgeInsets.only(top: 8.h, bottom: 24.h),
                    itemCount: results.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      indent: 68.w,
                      endIndent: 16.w,
                      color: AppColors.border,
                    ),
                    itemBuilder: (_, i) => _SearchResultTile(
                      tick: results[i],
                      onTap: () => context
                          .push(AppRoutes.tradeRoute(results[i].symbol)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 44.sp, color: AppColors.text4),
          SizedBox(height: 12.h),
          Text(
            message,
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.text3),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({
    required this.tick,
    required this.onTap,
  });

  final MarketTick tick;
  final VoidCallback onTap;

  static final _fmt = NumberFormat('#,##0.##');

  @override
  Widget build(BuildContext context) {
    final isUp = tick.change >= 0;
    final pctColor = isUp ? AppColors.green : AppColors.red;
    final sign = isUp ? '+' : '';
    final logoColor = _logoColor(tick.symbol);
    final isSaudi = RegExp(r'^\d{4}$').hasMatch(tick.symbol);
    final currency = isSaudi ? '﷼' : '\$';

    return InkWell(
      onTap: onTap,
      child: Container(
        color: AppColors.white,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
        child: Row(
          children: [
            // Logo badge
            Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                color: logoColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: logoColor.withValues(alpha: 0.3)),
              ),
              alignment: Alignment.center,
              child: Text(
                _shortLabel(tick.symbol),
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: logoColor,
                ),
              ),
            ),
            SizedBox(width: 12.w),

            // Name + symbol
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tick.symbol, style: AppTextStyles.bodyLg),
                  SizedBox(height: 2.h),
                  Text(
                    tick.name,
                    style: AppTextStyles.labelSm,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Price + change
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$currency ${_fmt.format(tick.price)}',
                  style: AppTextStyles.holdingPrice,
                ),
                SizedBox(height: 2.h),
                Text(
                  '$sign${tick.changePercent.toStringAsFixed(2)}%',
                  style: AppTextStyles.priceSm.copyWith(color: pctColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
