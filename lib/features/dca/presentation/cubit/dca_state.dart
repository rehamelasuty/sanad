import 'package:equatable/equatable.dart';

import '../../domain/entities/dca_plan.dart';

sealed class DcaState extends Equatable {
  const DcaState();
  @override
  List<Object?> get props => [];
}

final class DcaInitial extends DcaState {
  const DcaInitial();
}

final class DcaLoading extends DcaState {
  const DcaLoading();
}

final class DcaLoaded extends DcaState {
  const DcaLoaded({required this.plans, this.isCreating = false});

  final List<DcaPlan> plans;
  final bool isCreating;

  double get totalMonthlyCommitment =>
      plans.where((p) => p.isActive).fold(0, (s, p) => s + p.estimatedMonthly);

  DcaLoaded copyWith({List<DcaPlan>? plans, bool? isCreating}) =>
      DcaLoaded(
        plans: plans ?? this.plans,
        isCreating: isCreating ?? this.isCreating,
      );

  @override
  List<Object?> get props => [plans, isCreating];
}

final class DcaError extends DcaState {
  const DcaError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
