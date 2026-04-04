import '../../domain/entities/watchlist_item.dart';

class WatchlistItemModel extends WatchlistItem {
  const WatchlistItemModel({
    required super.symbol,
    required super.name,
    required super.exchange,
    required super.price,
    required super.change,
    required super.changePercent,
    required super.isShariaCompliant,
    required super.currency,
    required super.sector,
    required super.sparklineData,
  });

  factory WatchlistItemModel.fromJson(Map<String, dynamic> json) =>
      WatchlistItemModel(
        symbol: json['symbol'] as String,
        name: json['name'] as String,
        exchange: json['exchange'] as String,
        price: (json['price'] as num).toDouble(),
        change: (json['change'] as num).toDouble(),
        changePercent: (json['change_percent'] as num).toDouble(),
        isShariaCompliant: json['is_sharia_compliant'] as bool? ?? false,
        currency: json['currency'] as String,
        sector: json['sector'] as String,
        sparklineData: (json['sparkline_data'] as List)
            .map((e) => (e as num).toDouble())
            .toList(),
      );
}
