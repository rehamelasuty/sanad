import '../../domain/entities/murabaha_investment.dart';
import '../../domain/entities/murabaha_plan.dart';

abstract interface class MurabahaLocalDataSource {
  Future<List<MurabahaPlan>> getPlans();

  Future<MurabahaInvestment> invest({
    required MurabahaPlan plan,
    required double amount,
  });

  Future<List<MurabahaInvestment>> getMyInvestments();
}

class MurabahaLocalDataSourceImpl implements MurabahaLocalDataSource {
  static final _plans = [
    const MurabahaPlan(
      id: 'murab-weekly',
      type: MurabahaPlanType.weekly,
      annualRatePercent: 3.80,
      minAmount: 1000,
      maxAmount: 500_000,
      termDays: 7,
      description:
          'استثمار أسبوعي قصير الأمد بعائد ثابت وفق صيغة المرابحة الشرعية. '
          'مناسب للسيولة المتاحة على المدى القصير.',
      isActive: true,
    ),
    const MurabahaPlan(
      id: 'murab-monthly',
      type: MurabahaPlanType.monthly,
      annualRatePercent: 4.80,
      minAmount: 5000,
      maxAmount: 2_000_000,
      termDays: 30,
      description:
          'استثمار شهري بعائد تنافسي متوافق مع أحكام الشريعة الإسلامية. '
          'الخيار الأمثل للادخار المنتظم.',
      isActive: true,
    ),
    const MurabahaPlan(
      id: 'murab-quarterly',
      type: MurabahaPlanType.quarterly,
      annualRatePercent: 5.50,
      minAmount: 10_000,
      maxAmount: 5_000_000,
      termDays: 90,
      description:
          'استثمار ربع سنوي بأعلى عائد في فئة المرابحات الشرعية. '
          'مخصص للمستثمرين الباحثين عن عوائد أعلى بمدة أطول قليلاً.',
      isActive: true,
    ),
  ];

  final List<MurabahaInvestment> _investments = [];

  @override
  Future<List<MurabahaPlan>> getPlans() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return _plans;
  }

  @override
  Future<MurabahaInvestment> invest({
    required MurabahaPlan plan,
    required double amount,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final now = DateTime.now();
    final investment = MurabahaInvestment(
      id: 'INV-${now.millisecondsSinceEpoch}',
      plan: plan,
      principalAmount: amount,
      startDate: now,
      maturityDate: now.add(Duration(days: plan.termDays)),
      status: InvestmentStatus.active,
    );
    _investments.add(investment);
    return investment;
  }

  @override
  Future<List<MurabahaInvestment>> getMyInvestments() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_investments);
  }
}
