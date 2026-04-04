import 'package:equatable/equatable.dart';

enum AlertDirection {
  above, // سعر السهم يصل أو يتجاوز الهدف
  below, // سعر السهم ينزل إلى أو تحت الهدف
}

extension AlertDirectionX on AlertDirection {
  String get label => switch (this) {
        AlertDirection.above => 'يصل إلى أو يتجاوز',
        AlertDirection.below => 'ينخفض إلى أو دون',
      };
  String get icon => switch (this) {
        AlertDirection.above => '📈',
        AlertDirection.below => '📉',
      };
}

class PriceAlert extends Equatable {
  const PriceAlert({
    required this.id,
    required this.symbol,
    required this.stockName,
    required this.targetPrice,
    required this.direction,
    required this.isActive,
    required this.createdAt,
    this.triggeredAt,
    this.currentPrice,
  });

  final String id;
  final String symbol;
  final String stockName;
  final double targetPrice;
  final AlertDirection direction;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? triggeredAt;
  final double? currentPrice;

  bool get isTriggered => triggeredAt != null;

  double? get distancePercent {
    if (currentPrice == null || currentPrice! <= 0) return null;
    return ((targetPrice - currentPrice!) / currentPrice!) * 100;
  }

  PriceAlert copyWith({
    String? id,
    String? symbol,
    String? stockName,
    double? targetPrice,
    AlertDirection? direction,
    bool? isActive,
    DateTime? createdAt,
    DateTime? triggeredAt,
    double? currentPrice,
  }) {
    return PriceAlert(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      stockName: stockName ?? this.stockName,
      targetPrice: targetPrice ?? this.targetPrice,
      direction: direction ?? this.direction,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      triggeredAt: triggeredAt ?? this.triggeredAt,
      currentPrice: currentPrice ?? this.currentPrice,
    );
  }

  @override
  List<Object?> get props => [
        id, symbol, stockName, targetPrice, direction,
        isActive, createdAt, triggeredAt, currentPrice,
      ];
}
