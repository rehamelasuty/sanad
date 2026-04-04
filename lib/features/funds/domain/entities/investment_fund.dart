import 'package:equatable/equatable.dart';

enum FundExchange { local, us, global }

class InvestmentFund extends Equatable {
  const InvestmentFund({
    required this.id,
    required this.symbol,
    required this.name,
    required this.sector,
    required this.annualReturn,
    required this.exchange,
    this.unitPrice,
    this.minInvestment,
    this.totalAssets,
    this.distributionFrequency,
    this.isShariaCompliant = true,
  });

  final String id;
  final String symbol;
  final String name;
  final String sector;
  final double annualReturn; // e.g. 12.4 means 12.4%
  final FundExchange exchange;
  final double? unitPrice;
  final double? minInvestment;
  final double? totalAssets; // in millions SAR
  final String? distributionFrequency;
  final bool isShariaCompliant;

  @override
  List<Object?> get props => [id, symbol];
}
