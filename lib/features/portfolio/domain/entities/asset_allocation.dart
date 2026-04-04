import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class AssetAllocation extends Equatable {
  const AssetAllocation({
    required this.label,
    required this.percentage,
    required this.color,
    required this.value,
  });

  final String label;
  final double percentage;
  final Color color;
  final double value;

  @override
  List<Object?> get props => [label, percentage];
}
