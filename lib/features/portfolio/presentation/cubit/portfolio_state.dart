import 'package:equatable/equatable.dart';

import '../../domain/entities/asset_allocation.dart';
import '../../domain/entities/portfolio_holding.dart';

sealed class PortfolioState extends Equatable {
  const PortfolioState();

  @override
  List<Object?> get props => [];
}

final class PortfolioInitial extends PortfolioState {
  const PortfolioInitial();
}

final class PortfolioLoading extends PortfolioState {
  const PortfolioLoading();
}

final class PortfolioLoaded extends PortfolioState {
  const PortfolioLoaded({
    required this.holdings,
    required this.allocations,
    this.hideValues = false,
    this.sortOrder = HoldingSortOrder.byValue,
  });

  final List<PortfolioHolding> holdings;
  final List<AssetAllocation> allocations;
  final bool hideValues;
  final HoldingSortOrder sortOrder;

  double get totalMarketValue =>
      holdings.fold(0, (sum, h) => sum + h.marketValue);
  double get totalCost => holdings.fold(0, (sum, h) => sum + h.totalCost);
  double get totalReturn => totalMarketValue - totalCost;
  double get totalReturnPercent =>
      totalCost == 0 ? 0 : (totalReturn / totalCost) * 100;

  List<PortfolioHolding> get sortedHoldings {
    final copy = List<PortfolioHolding>.from(holdings);
    switch (sortOrder) {
      case HoldingSortOrder.byValue:
        copy.sort((a, b) => b.marketValue.compareTo(a.marketValue));
      case HoldingSortOrder.byReturn:
        copy.sort((a, b) => b.totalReturn.compareTo(a.totalReturn));
      case HoldingSortOrder.byReturnPercent:
        copy.sort(
            (a, b) => b.totalReturnPercent.compareTo(a.totalReturnPercent));
      case HoldingSortOrder.byName:
        copy.sort((a, b) => a.name.compareTo(b.name));
    }
    return copy;
  }

  PortfolioLoaded copyWith({
    List<PortfolioHolding>? holdings,
    List<AssetAllocation>? allocations,
    bool? hideValues,
    HoldingSortOrder? sortOrder,
  }) =>
      PortfolioLoaded(
        holdings: holdings ?? this.holdings,
        allocations: allocations ?? this.allocations,
        hideValues: hideValues ?? this.hideValues,
        sortOrder: sortOrder ?? this.sortOrder,
      );

  @override
  List<Object?> get props => [holdings, allocations, hideValues, sortOrder];
}

final class PortfolioError extends PortfolioState {
  const PortfolioError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

enum HoldingSortOrder { byValue, byReturn, byReturnPercent, byName }

extension HoldingSortLabel on HoldingSortOrder {
  String get label => switch (this) {
        HoldingSortOrder.byValue => 'القيمة',
        HoldingSortOrder.byReturn => 'الربح',
        HoldingSortOrder.byReturnPercent => 'نسبة الربح',
        HoldingSortOrder.byName => 'الاسم',
      };
}
