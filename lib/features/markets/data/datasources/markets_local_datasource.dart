import 'package:flutter/material.dart';
import '../../domain/entities/market_index.dart';
import '../../domain/entities/stock.dart';

abstract interface class MarketsLocalDataSource {
  Future<List<Stock>> getStocks({String? category});
  Future<List<MarketIndex>> getMarketIndices();
}

class MarketsLocalDataSourceImpl implements MarketsLocalDataSource {
  static const _allStocks = [
    Stock(
      symbol: 'AAPL',
      name: 'Apple Inc.',
      exchange: 'NASDAQ',
      price: 189.50,
      change: 3.38,
      changePercent: 1.82,
      isShariaCompliant: true,
      currency: r'$',
      sector: 'تكنولوجيا',
      sparklineData: [20, 16, 18, 10, 6, 8, 3],
      logoColor: Color(0xFF555555),
    ),
    Stock(
      symbol: '2222',
      name: 'أرامكو السعودية',
      exchange: 'تداول',
      price: 29.85,
      change: 0.20,
      changePercent: 0.67,
      isShariaCompliant: true,
      currency: 'ر.س',
      sector: 'طاقة',
      sparklineData: [16, 12, 14, 9, 5, 7, 3],
    ),
    Stock(
      symbol: 'MSFT',
      name: 'Microsoft',
      exchange: 'NASDAQ',
      price: 415.20,
      change: -3.90,
      changePercent: -0.93,
      isShariaCompliant: false,
      currency: r'$',
      sector: 'تكنولوجيا',
      sparklineData: [6, 10, 8, 14, 12, 17, 20],
    ),
    Stock(
      symbol: 'NVDA',
      name: 'NVIDIA',
      exchange: 'NASDAQ',
      price: 876.30,
      change: 28.97,
      changePercent: 3.41,
      isShariaCompliant: true,
      currency: r'$',
      sector: 'تكنولوجيا',
      sparklineData: [20, 14, 10, 6, 4, 7, 2],
    ),
    Stock(
      symbol: '1120',
      name: 'الراجحي',
      exchange: 'تداول',
      price: 82.60,
      change: 3.27,
      changePercent: 4.12,
      isShariaCompliant: true,
      currency: 'ر.س',
      sector: 'مصرفي',
      sparklineData: [18, 16, 15, 12, 10, 11, 8],
      logoColor: Color(0xFF0B7A5E),
    ),
    Stock(
      symbol: 'META',
      name: 'Meta Platforms',
      exchange: 'NASDAQ',
      price: 512.70,
      change: 19.10,
      changePercent: 3.88,
      isShariaCompliant: false,
      currency: r'$',
      sector: 'تكنولوجيا',
      sparklineData: [18, 15, 12, 10, 8, 6, 4],
      logoColor: Color(0xFF2060C8),
    ),
    Stock(
      symbol: 'TSLA',
      name: 'Tesla Inc.',
      exchange: 'NASDAQ',
      price: 214.80,
      change: -4.72,
      changePercent: -2.15,
      isShariaCompliant: false,
      currency: r'$',
      sector: 'سيارات',
      sparklineData: [8, 10, 12, 14, 16, 15, 17],
      logoColor: Color(0xFFD63F52),
    ),
    Stock(
      symbol: '2010',
      name: 'سابك',
      exchange: 'تداول',
      price: 94.20,
      change: -0.80,
      changePercent: -0.84,
      isShariaCompliant: true,
      currency: 'ر.س',
      sector: 'بتروكيماويات',
      sparklineData: [10, 11, 12, 13, 12, 14, 15],
    ),
  ];

  @override
  Future<List<Stock>> getStocks({String? category}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (category == null || category == 'all') return _allStocks;
    if (category == 'saudi') {
      return _allStocks.where((s) => s.exchange == 'تداول').toList();
    }
    if (category == 'us') {
      return _allStocks.where((s) => s.exchange == 'NASDAQ').toList();
    }
    if (category == 'sharia') {
      return _allStocks.where((s) => s.isShariaCompliant).toList();
    }
    return _allStocks;
  }

  @override
  Future<List<MarketIndex>> getMarketIndices() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const [
      MarketIndex(name: 'تداول TASI', value: 12847, changePercent: 0.82),
      MarketIndex(name: 'S&P 500', value: 5234, changePercent: -0.34),
      MarketIndex(name: 'NASDAQ', value: 16390, changePercent: 0.51),
    ];
  }
}
