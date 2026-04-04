import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/asset_allocation.dart';
import '../../domain/entities/portfolio_holding.dart';

abstract interface class PortfolioLocalDataSource {
  Future<List<PortfolioHolding>> getHoldings();

  Future<List<AssetAllocation>> getAssetAllocations();
}

class PortfolioLocalDataSourceImpl implements PortfolioLocalDataSource {
  static const _holdings = [
    PortfolioHolding(
      symbol: 'AAPL',
      name: 'آبل',
      exchange: 'NASDAQ',
      quantity: 15,
      averageCost: 165.40,
      currentPrice: 189.30,
      isShariaCompliant: true,
      logoColor: 0xFF1C1C1E,
    ),
    PortfolioHolding(
      symbol: 'MSFT',
      name: 'مايكروسوفت',
      exchange: 'NASDAQ',
      quantity: 8,
      averageCost: 380.00,
      currentPrice: 415.50,
      isShariaCompliant: true,
      logoColor: 0xFF00A4EF,
    ),
    PortfolioHolding(
      symbol: 'NVDA',
      name: 'إنفيديا',
      exchange: 'NASDAQ',
      quantity: 5,
      averageCost: 650.00,
      currentPrice: 875.40,
      isShariaCompliant: true,
      logoColor: 0xFF76B900,
    ),
    PortfolioHolding(
      symbol: '1120',
      name: 'مصرف الراجحي',
      exchange: 'تداول',
      quantity: 100,
      averageCost: 82.20,
      currentPrice: 88.60,
      isShariaCompliant: true,
      logoColor: 0xFF006940,
    ),
    PortfolioHolding(
      symbol: '2222',
      name: 'أرامكو السعودية',
      exchange: 'تداول',
      quantity: 200,
      averageCost: 29.50,
      currentPrice: 27.20,
      isShariaCompliant: false,
      logoColor: 0xFF00843D,
    ),
  ];

  @override
  Future<List<PortfolioHolding>> getHoldings() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return _holdings;
  }

  @override
  Future<List<AssetAllocation>> getAssetAllocations() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    // Calculate total market value from holdings
    double totalValue = 0;
    final Map<String, double> byExchange = {};

    for (final h in _holdings) {
      final mv = h.marketValue;
      totalValue += mv;
      byExchange[h.exchange] = (byExchange[h.exchange] ?? 0) + mv;
    }

    return [
      AssetAllocation(
        label: 'الأسهم الأمريكية',
        percentage: (byExchange['NASDAQ'] ?? 0) / totalValue * 100,
        color: AppColors.green,
        value: byExchange['NASDAQ'] ?? 0,
      ),
      AssetAllocation(
        label: 'الأسهم السعودية',
        percentage: (byExchange['تداول'] ?? 0) / totalValue * 100,
        color: AppColors.blue,
        value: byExchange['تداول'] ?? 0,
      ),
    ];
  }
}
