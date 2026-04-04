import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Stock extends Equatable {
  final String symbol;
  final String name;
  final String exchange;
  final double price;
  final double change;
  final double changePercent;
  final bool isShariaCompliant;
  final String currency;
  final String sector;
  final List<double> sparklineData;
  final Color? logoColor;

  const Stock({
    required this.symbol,
    required this.name,
    required this.exchange,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.isShariaCompliant,
    required this.currency,
    required this.sector,
    required this.sparklineData,
    this.logoColor,
  });

  bool get isPositive => changePercent >= 0;

  @override
  List<Object?> get props => [symbol, price, changePercent];
}
