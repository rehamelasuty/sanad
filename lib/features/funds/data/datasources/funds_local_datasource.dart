import '../../domain/entities/investment_fund.dart';

class FundsLocalDataSource {
  List<InvestmentFund> getFunds() {
    return const [
      InvestmentFund(
        id: 'FUND-001',
        symbol: 'RJHI',
        name: 'صندوق الراجحي للأسهم السعودية',
        sector: 'أسهم',
        annualReturn: 12.4,
        exchange: FundExchange.local,
        unitPrice: 15.72,
        minInvestment: 1000,
        totalAssets: 2400,
        distributionFrequency: 'ربع سنوي',
        isShariaCompliant: true,
      ),
      InvestmentFund(
        id: 'FUND-002',
        symbol: 'VOO',
        name: 'صندوق فانغارد S&P 500',
        sector: 'أسهم متنوعة',
        annualReturn: 24.8,
        exchange: FundExchange.us,
        unitPrice: 145.80,
        minInvestment: 500,
        totalAssets: 980000,
        distributionFrequency: 'ربع سنوي',
        isShariaCompliant: false,
      ),
      InvestmentFund(
        id: 'FUND-003',
        symbol: 'AREF',
        name: 'صندوق العقارات السعودي المتنوع',
        sector: 'عقارات',
        annualReturn: 8.7,
        exchange: FundExchange.local,
        unitPrice: 10.45,
        minInvestment: 2000,
        totalAssets: 560,
        distributionFrequency: 'نصف سنوي',
        isShariaCompliant: true,
      ),
      InvestmentFund(
        id: 'FUND-004',
        symbol: 'GOLD',
        name: 'صندوق الذهب الإسلامي',
        sector: 'سلع',
        annualReturn: 15.2,
        exchange: FundExchange.global,
        unitPrice: 88.30,
        minInvestment: 500,
        totalAssets: 1200,
        distributionFrequency: 'سنوي',
        isShariaCompliant: true,
      ),
    ];
  }
}
