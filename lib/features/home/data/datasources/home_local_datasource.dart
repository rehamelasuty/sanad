import '../../domain/entities/portfolio_summary.dart';
import '../../domain/entities/watchlist_item.dart';
import '../models/portfolio_summary_model.dart';
import '../models/watchlist_item_model.dart';

abstract interface class HomeLocalDataSource {
  Future<PortfolioSummary> getPortfolioSummary();
  Future<List<WatchlistItem>> getWatchlist();
}

/// Provides realistic dummy data — replace with real API calls when ready.
class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  @override
  Future<PortfolioSummary> getPortfolioSummary() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const PortfolioSummaryModel(
      totalValue: 48392.50,
      changeToday: 1109.40,
      changeTodayPercent: 2.34,
      usStocksValue: 31420.00,
      saudiStocksValue: 12680.00,
      cashValue: 4292.50,
      totalProfit: 6842.00,
      userName: 'محمد الأحمدي',
      userInitial: 'م',
    );
  }

  @override
  Future<List<WatchlistItem>> getWatchlist() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      const WatchlistItemModel(
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
      ),
      const WatchlistItemModel(
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
      const WatchlistItemModel(
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
      const WatchlistItemModel(
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
    ];
  }
}
