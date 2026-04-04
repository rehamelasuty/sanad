import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/market_tick.dart';
import '../cubit/market_feed_cubit.dart';
import '../cubit/market_feed_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// StockTickTile  —  single row in the live market feed list
//
// Performance design
// ──────────────────
// • Uses [BlocSelector] to subscribe to ONLY its symbol's [MarketTick].
//   When a batch of 300 stocks updates, only the ≈15 tiles currently
//   visible on-screen call their selector; and of those, only the ones
//   whose price actually changed rebuild.
//
// • [RepaintBoundary] wraps the animated content so that when this tile
//   flashes (price-change animation), the rest of the list is not repainted.
//
// • Price-change flash:
//   On each new tick, an [AnimationController] plays a 600 ms fade-out
//   from the direction colour (green/red) back to transparent.
// ─────────────────────────────────────────────────────────────────────────────

class StockTickTile extends StatefulWidget {
  const StockTickTile({
    super.key,
    required this.symbol,
  });

  final String symbol;

  @override
  State<StockTickTile> createState() => _StockTickTileState();
}

class _StockTickTileState extends State<StockTickTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flashCtrl;
  late final Animation<double>    _flashAnim;

  MarketTick? _prevTick;

  @override
  void initState() {
    super.initState();
    _flashCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _flashAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _flashCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _flashCtrl.dispose();
    super.dispose();
  }

  void _onNewTick(MarketTick? tick) {
    if (!mounted) return; // widget may have been disposed before callback fires
    if (tick == null) return;
    if (_prevTick != null && tick.price != _prevTick!.price) {
      _flashCtrl.forward(from: 0.0); // play flash animation
    }
    _prevTick = tick;
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;

    return BlocSelector<MarketFeedCubit, MarketFeedState, MarketTick?>(
      selector: (state) =>
          state is MarketFeedConnected ? state.tickMap[widget.symbol] : null,
      builder: (context, tick) {
        // Side-effect: trigger flash when price changes.
        WidgetsBinding.instance.addPostFrameCallback((_) => _onNewTick(tick));

        final isUp   = (tick?.direction == TickDirection.up);
        final isDown = (tick?.direction == TickDirection.down);

        final dirColor = isUp
            ? AppColors.green
            : isDown
                ? AppColors.red
                : cs.text3;

        return RepaintBoundary(
          child: AnimatedBuilder(
            animation: _flashAnim,
            builder: (context, child) {
              final flashColor = isUp
                  ? AppColors.green.withValues(alpha: _flashAnim.value * 0.12)
                  : isDown
                      ? AppColors.red.withValues(alpha: _flashAnim.value * 0.12)
                      : Colors.transparent;

              return Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 3.h),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
                decoration: BoxDecoration(
                  color: Color.lerp(cs.surface, flashColor, 1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: cs.border),
                ),
                child: child,
              );
            },
            child: Row(
              children: [
                // ── Symbol badge ────────────────────────────────────────────
                _SymbolBadge(symbol: widget.symbol, cs: cs),
                SizedBox(width: 12.w),

                // ── Name + symbol text ───────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tick?.name ?? widget.symbol,
                        style: AppTextStyles.labelMd.copyWith(color: cs.text1),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        tick != null
                            ? 'حجم: ${_formatVolume(tick.volume)}'
                            : '—',
                        style: AppTextStyles.caption.copyWith(color: cs.text3),
                      ),
                    ],
                  ),
                ),

                // ── Price + change ──────────────────────────────────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      tick != null
                          ? tick.price.toStringAsFixed(2)
                          : '—',
                      style: AppTextStyles.monoSm.copyWith(
                        color: cs.text1,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.sp,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    if (tick != null)
                      _ChangeBadge(tick: tick, color: dirColor)
                    else
                      const SizedBox.shrink(),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Symbol badge ──────────────────────────────────────────────────────────────
class _SymbolBadge extends StatelessWidget {
  const _SymbolBadge({required this.symbol, required this.cs});
  final String symbol;
  final AppColorSet cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  42.r,
      height: 42.r,
      decoration: BoxDecoration(
        color:        AppColors.navy.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(11.r),
        border:       Border.all(color: AppColors.navy.withValues(alpha: 0.12)),
      ),
      alignment: Alignment.center,
      child: Text(
        symbol.length > 4 ? symbol.substring(0, 2) : symbol.substring(0, 1),
        style: AppTextStyles.caption.copyWith(
          color:      AppColors.navy,
          fontWeight: FontWeight.w800,
          fontSize:   symbol.length > 3 ? 9.sp : 12.sp,
        ),
      ),
    );
  }
}

// ── Change badge ──────────────────────────────────────────────────────────────
class _ChangeBadge extends StatelessWidget {
  const _ChangeBadge({required this.tick, required this.color});
  final MarketTick tick;
  final Color      color;

  @override
  Widget build(BuildContext context) {
    final sign   = tick.change >= 0 ? '+' : '';
    final arrow  = tick.direction == TickDirection.up   ? '↑'
                 : tick.direction == TickDirection.down ? '↓'
                 : '–';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
      decoration: BoxDecoration(
        color:        color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        '$arrow $sign${tick.changePercent.toStringAsFixed(2)}%',
        style: AppTextStyles.caption.copyWith(
          color:      color,
          fontWeight: FontWeight.w700,
          fontSize:   10.sp,
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────
String _formatVolume(int v) {
  if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
  if (v >= 1000)    return '${(v / 1000).toStringAsFixed(0)}K';
  return v.toString();
}
