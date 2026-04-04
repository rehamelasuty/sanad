import 'package:flutter/material.dart';

import '../../../../core/widgets/common/section_header.dart';
import '../../../../core/widgets/common/stock_list_tile.dart';
import '../../domain/entities/watchlist_item.dart';

class WatchlistSection extends StatelessWidget {
  const WatchlistSection({
    super.key,
    required this.items,
    this.onViewAll,
    this.onItemTap,
  });

  final List<WatchlistItem> items;
  final VoidCallback? onViewAll;
  final void Function(WatchlistItem)? onItemTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'قائمة المتابعة',
          actionLabel: 'عرض الكل ←',
          onAction: onViewAll,
        ),
        ...items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return StockListTile(
            symbol: item.symbol,
            name: item.name,
            exchange: item.exchange,
            price: item.price,
            changePercent: item.changePercent,
            sparklineData: item.sparklineData,
            currency: item.currency,
            isShariaCompliant: item.isShariaCompliant,
            isLast: i == items.length - 1,
            onTap: () => onItemTap?.call(item),
          );
        }),
      ],
    );
  }
}
