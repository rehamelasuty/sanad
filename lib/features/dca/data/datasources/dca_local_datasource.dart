import '../../domain/entities/dca_plan.dart';

class DcaLocalDataSource {
  final List<DcaPlan> _plans = [
    DcaPlan(
      id: 'DCA-001',
      symbol: 'AAPL',
      stockName: 'Apple Inc.',
      amountPerCycle: 500,
      frequency: DcaFrequency.weekly,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      nextRunAt: DateTime.now().add(const Duration(days: 4)),
      totalCycles: 4,
      totalInvested: 2000,
    ),
    DcaPlan(
      id: 'DCA-002',
      symbol: '2222',
      stockName: 'أرامكو السعودية',
      amountPerCycle: 1000,
      frequency: DcaFrequency.monthly,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      nextRunAt: DateTime.now().add(const Duration(days: 12)),
      totalCycles: 2,
      totalInvested: 2000,
    ),
  ];

  List<DcaPlan> getPlans() => List.unmodifiable(_plans);

  DcaPlan createPlan(DcaPlan plan) {
    _plans.add(plan);
    return plan;
  }

  DcaPlan togglePlan(String id, {required bool active}) {
    final index = _plans.indexWhere((p) => p.id == id);
    if (index == -1) throw Exception('DCA plan not found');
    final updated = _plans[index].copyWith(isActive: active);
    _plans[index] = updated;
    return updated;
  }

  void deletePlan(String id) {
    _plans.removeWhere((p) => p.id == id);
  }
}
