import 'package:equatable/equatable.dart';

enum IpoStatus { current, upcoming, closed }

class IpoListing extends Equatable {
  const IpoListing({
    required this.id,
    required this.symbol,
    required this.name,
    required this.sector,
    required this.offeringPrice,
    required this.minShares,
    required this.status,
    required this.subscriptionRate,
    this.closingDate,
    this.allocationDate,
    this.isShariaCompliant = true,
  });

  final String id;
  final String symbol;
  final String name;
  final String sector;
  final double offeringPrice;
  final int minShares;
  final IpoStatus status;
  final double subscriptionRate; // e.g. 2.84 means 284%
  final DateTime? closingDate;
  final DateTime? allocationDate;
  final bool isShariaCompliant;

  @override
  List<Object?> get props => [id, symbol, status];
}
