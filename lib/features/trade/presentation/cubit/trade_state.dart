import 'package:equatable/equatable.dart';

import '../../domain/entities/stock_detail.dart';

sealed class TradeState extends Equatable {
  const TradeState();

  @override
  List<Object?> get props => [];
}

final class TradeInitial extends TradeState {
  const TradeInitial();
}

final class TradeLoading extends TradeState {
  const TradeLoading();
}

final class TradeLoaded extends TradeState {
  const TradeLoaded({
    required this.stock,
    this.selectedChartRange = ChartRange.twoWeeks,
    this.orderSide = OrderSideTab.buy,
    this.quantity = 1.0,
    this.isPlacingOrder = false,
    this.orderSuccess = false,
  });

  final StockDetail stock;
  final ChartRange selectedChartRange;
  final OrderSideTab orderSide;
  final double quantity;
  final bool isPlacingOrder;
  final bool orderSuccess;

  TradeLoaded copyWith({
    StockDetail? stock,
    ChartRange? selectedChartRange,
    OrderSideTab? orderSide,
    double? quantity,
    bool? isPlacingOrder,
    bool? orderSuccess,
  }) =>
      TradeLoaded(
        stock: stock ?? this.stock,
        selectedChartRange: selectedChartRange ?? this.selectedChartRange,
        orderSide: orderSide ?? this.orderSide,
        quantity: quantity ?? this.quantity,
        isPlacingOrder: isPlacingOrder ?? this.isPlacingOrder,
        orderSuccess: orderSuccess ?? this.orderSuccess,
      );

  @override
  List<Object?> get props => [
        stock,
        selectedChartRange,
        orderSide,
        quantity,
        isPlacingOrder,
        orderSuccess,
      ];
}

final class TradeError extends TradeState {
  const TradeError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

enum ChartRange { oneDay, oneWeek, twoWeeks, oneMonth, threeMonths, oneYear }

enum OrderSideTab { buy, sell }

extension ChartRangeLabel on ChartRange {
  String get label => switch (this) {
        ChartRange.oneDay => '١ي',
        ChartRange.oneWeek => '١أ',
        ChartRange.twoWeeks => '٢أ',
        ChartRange.oneMonth => '١ش',
        ChartRange.threeMonths => '٣ش',
        ChartRange.oneYear => '١س',
      };
}
