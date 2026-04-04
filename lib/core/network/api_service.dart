import 'package:dio/dio.dart';

/// HTTP API service.
/// Local datasources are used for all features currently;
/// this class is a stub for future network integration.
class ApiService {
  ApiService(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> getPortfolioSummary() async {
    final res = await _dio.get('/portfolio/summary');
    return res.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getWatchlist() async {
    final res = await _dio.get('/watchlist');
    return res.data as List<dynamic>;
  }

  Future<List<dynamic>> getStocks({
    String? category,
    bool? shariaOnly,
  }) async {
    final res = await _dio.get(
      '/markets/stocks',
      queryParameters: {
        if (category != null) 'category': category,
        if (shariaOnly != null) 'sharia_only': shariaOnly,
      },
    );
    return res.data as List<dynamic>;
  }

  Future<List<dynamic>> getMarketIndices() async {
    final res = await _dio.get('/markets/indices');
    return res.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> getStockDetail(String symbol) async {
    final res = await _dio.get('/stocks/$symbol');
    return res.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getChartData(
    String symbol, {
    String? timeframe,
  }) async {
    final res = await _dio.get(
      '/stocks/$symbol/chart',
      queryParameters: {
        if (timeframe != null) 'timeframe': timeframe,
      },
    );
    return res.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> placeOrder(Map<String, dynamic> body) async {
    final res = await _dio.post('/orders', data: body);
    return res.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getMurabahaPlanss() async {
    final res = await _dio.get('/murabaha/plans');
    return res.data as List<dynamic>;
  }

  Future<List<dynamic>> getHoldings() async {
    final res = await _dio.get('/portfolio/holdings');
    return res.data as List<dynamic>;
  }
}
