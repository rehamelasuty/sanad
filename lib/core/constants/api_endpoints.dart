abstract class ApiEndpoints {
  // Portfolio
  static const String portfolioSummary = '/portfolio/summary';
  static const String watchlist = '/watchlist';

  // Markets
  static const String stocks = '/markets/stocks';
  static const String indices = '/markets/indices';

  // Trade
  static String stockDetail(String symbol) => '/stocks/$symbol';
  static const String placeOrder = '/orders';

  // Murabaha
  static const String murabahaPlanss = '/murabaha/plans';
}
