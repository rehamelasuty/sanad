import '../../domain/entities/portfolio_summary.dart';

class PortfolioSummaryModel extends PortfolioSummary {
  const PortfolioSummaryModel({
    required super.totalValue,
    required super.changeToday,
    required super.changeTodayPercent,
    required super.usStocksValue,
    required super.saudiStocksValue,
    required super.cashValue,
    required super.totalProfit,
    required super.userName,
    required super.userInitial,
  });

  factory PortfolioSummaryModel.fromJson(Map<String, dynamic> json) =>
      PortfolioSummaryModel(
        totalValue: (json['total_value'] as num).toDouble(),
        changeToday: (json['change_today'] as num).toDouble(),
        changeTodayPercent: (json['change_today_percent'] as num).toDouble(),
        usStocksValue: (json['us_stocks_value'] as num).toDouble(),
        saudiStocksValue: (json['saudi_stocks_value'] as num).toDouble(),
        cashValue: (json['cash_value'] as num).toDouble(),
        totalProfit: (json['total_profit'] as num).toDouble(),
        userName: json['user_name'] as String,
        userInitial: json['user_initial'] as String,
      );
}
