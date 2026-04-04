import '../../domain/entities/price_alert.dart';

abstract class PriceAlertsLocalDatasource {
  Future<List<PriceAlert>> getAlerts();
  Future<PriceAlert> createAlert(PriceAlert alert);
  Future<PriceAlert> toggleAlert(String alertId, {required bool active});
  Future<void> deleteAlert(String alertId);
}

class PriceAlertsLocalDatasourceImpl implements PriceAlertsLocalDatasource {
  final List<PriceAlert> _alerts = [
    PriceAlert(
      id: 'PA-001',
      symbol: 'AAPL',
      stockName: 'Apple Inc.',
      targetPrice: 200.0,
      direction: AlertDirection.above,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      currentPrice: 189.50,
    ),
    PriceAlert(
      id: 'PA-002',
      symbol: '2222',
      stockName: 'أرامكو السعودية',
      targetPrice: 27.0,
      direction: AlertDirection.below,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      currentPrice: 28.90,
    ),
    PriceAlert(
      id: 'PA-003',
      symbol: '1120',
      stockName: 'مصرف الراجحي',
      targetPrice: 95.0,
      direction: AlertDirection.above,
      isActive: false,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      triggeredAt: DateTime.now().subtract(const Duration(days: 3)),
      currentPrice: 96.50,
    ),
  ];

  @override
  Future<List<PriceAlert>> getAlerts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_alerts);
  }

  @override
  Future<PriceAlert> createAlert(PriceAlert alert) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _alerts.add(alert);
    return alert;
  }

  @override
  Future<PriceAlert> toggleAlert(String alertId,
      {required bool active}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final idx = _alerts.indexWhere((a) => a.id == alertId);
    if (idx == -1) throw Exception('Alert not found: $alertId');
    final updated = _alerts[idx].copyWith(isActive: active);
    _alerts[idx] = updated;
    return updated;
  }

  @override
  Future<void> deleteAlert(String alertId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _alerts.removeWhere((a) => a.id == alertId);
  }
}
