import 'dart:math';

import '../../domain/entities/order.dart';
import '../../domain/entities/stock_detail.dart';

abstract interface class TradeLocalDataSource {
  Future<StockDetail> getStockDetail(String symbol);

  Future<Order> placeOrder({
    required String symbol,
    required OrderSide side,
    required OrderType type,
    required double quantity,
    double? limitPrice,
  });

  Future<List<Order>> getOrderHistory(String symbol);
}

class TradeLocalDataSourceImpl implements TradeLocalDataSource {
  static final Map<String, StockDetail> _stocks = {
    'AAPL': StockDetail(
      symbol: 'AAPL',
      name: 'آبل',
      exchange: 'NASDAQ',
      currentPrice: 189.30,
      changeToday: 2.45,
      changeTodayPercent: 1.31,
      open: 187.20,
      high: 190.10,
      low: 186.75,
      previousClose: 186.85,
      volume: 52_340_000,
      marketCap: 2_960_000_000_000,
      peRatio: 30.4,
      week52High: 199.62,
      week52Low: 143.90,
      isShariaCompliant: true,
      debtToEquityRatio: 1.79,
      prohibitedRevenuePercent: 0.8,
      purificationPercent: 0.2,
      logoColor: 0xFF1C1C1E,
      chartData: _generateChart(189.30, 14),
    ),
    '2222': StockDetail(
      symbol: '2222',
      name: 'أرامكو السعودية',
      exchange: 'تداول',
      currentPrice: 27.20,
      changeToday: -0.35,
      changeTodayPercent: -1.27,
      open: 27.55,
      high: 27.65,
      low: 27.00,
      previousClose: 27.55,
      volume: 12_800_000,
      marketCap: 6_850_000_000_000,
      peRatio: 14.2,
      week52High: 32.80,
      week52Low: 24.90,
      isShariaCompliant: false,
      debtToEquityRatio: 0.52,
      prohibitedRevenuePercent: 3.1,
      purificationPercent: 0.0,
      logoColor: 0xFF00843D,
      chartData: _generateChart(27.20, 14),
    ),
    'MSFT': StockDetail(
      symbol: 'MSFT',
      name: 'مايكروسوفت',
      exchange: 'NASDAQ',
      currentPrice: 415.50,
      changeToday: 5.20,
      changeTodayPercent: 1.27,
      open: 410.30,
      high: 416.80,
      low: 409.90,
      previousClose: 410.30,
      volume: 18_900_000,
      marketCap: 3_090_000_000_000,
      peRatio: 35.8,
      week52High: 430.82,
      week52Low: 309.98,
      isShariaCompliant: true,
      debtToEquityRatio: 0.35,
      prohibitedRevenuePercent: 0.5,
      purificationPercent: 0.1,
      logoColor: 0xFF00A4EF,
      chartData: _generateChart(415.50, 14),
    ),
    'NVDA': StockDetail(
      symbol: 'NVDA',
      name: 'إنفيديا',
      exchange: 'NASDAQ',
      currentPrice: 875.40,
      changeToday: 23.10,
      changeTodayPercent: 2.71,
      open: 852.30,
      high: 878.50,
      low: 850.00,
      previousClose: 852.30,
      volume: 35_600_000,
      marketCap: 2_160_000_000_000,
      peRatio: 68.2,
      week52High: 974.00,
      week52Low: 403.12,
      isShariaCompliant: true,
      debtToEquityRatio: 0.41,
      prohibitedRevenuePercent: 0.3,
      purificationPercent: 0.1,
      logoColor: 0xFF76B900,
      chartData: _generateChart(875.40, 14),
    ),
    '1120': StockDetail(
      symbol: '1120',
      name: 'مصرف الراجحي',
      exchange: 'تداول',
      currentPrice: 88.60,
      changeToday: 1.10,
      changeTodayPercent: 1.26,
      open: 87.50,
      high: 89.20,
      low: 87.30,
      previousClose: 87.50,
      volume: 3_400_000,
      marketCap: 332_000_000_000,
      peRatio: 17.5,
      week52High: 104.80,
      week52Low: 72.40,
      isShariaCompliant: true,
      debtToEquityRatio: 0.0,
      prohibitedRevenuePercent: 0.0,
      purificationPercent: 0.0,
      logoColor: 0xFF006940,
      chartData: _generateChart(88.60, 14),
    ),
  };

  static List<double> _generateChart(double basePrice, int days) {
    final rng = Random(basePrice.toInt());
    final data = <double>[];
    double price = basePrice * 0.92;
    for (var i = 0; i < days; i++) {
      price += (rng.nextDouble() - 0.45) * basePrice * 0.015;
      data.add(price.clamp(basePrice * 0.85, basePrice * 1.15));
    }
    data[data.length - 1] = basePrice;
    return data;
  }

  @override
  Future<StockDetail> getStockDetail(String symbol) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final stock = _stocks[symbol.toUpperCase()];
    if (stock == null) {
      throw Exception('رمز السهم غير موجود: $symbol');
    }
    return stock;
  }

  @override
  Future<Order> placeOrder({
    required String symbol,
    required OrderSide side,
    required OrderType type,
    required double quantity,
    double? limitPrice,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    final stock = _stocks[symbol.toUpperCase()];
    return Order(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      symbol: symbol,
      side: side,
      type: type,
      quantity: quantity,
      limitPrice: limitPrice ?? stock?.currentPrice,
      status: OrderStatus.filled,
      createdAt: DateTime.now(),
      filledPrice: stock?.currentPrice,
      filledAt: DateTime.now(),
    );
  }

  @override
  Future<List<Order>> getOrderHistory(String symbol) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return [];
  }
}
