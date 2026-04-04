import 'package:equatable/equatable.dart';

class PortfolioSummary extends Equatable {
  final double totalValue;
  final double changeToday;
  final double changeTodayPercent;
  final double usStocksValue;
  final double saudiStocksValue;
  final double cashValue;
  final double totalProfit;
  final String userName;
  final String userInitial;

  const PortfolioSummary({
    required this.totalValue,
    required this.changeToday,
    required this.changeTodayPercent,
    required this.usStocksValue,
    required this.saudiStocksValue,
    required this.cashValue,
    required this.totalProfit,
    required this.userName,
    required this.userInitial,
  });

  @override
  List<Object?> get props => [
        totalValue,
        changeToday,
        changeTodayPercent,
        usStocksValue,
        saudiStocksValue,
        cashValue,
        totalProfit,
        userName,
        userInitial,
      ];
}
