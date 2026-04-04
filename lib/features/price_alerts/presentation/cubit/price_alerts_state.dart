import 'package:equatable/equatable.dart';
import '../../domain/entities/price_alert.dart';

sealed class PriceAlertsState extends Equatable {
  const PriceAlertsState();
  @override
  List<Object?> get props => [];
}

final class PriceAlertsInitial extends PriceAlertsState {
  const PriceAlertsInitial();
}

final class PriceAlertsLoading extends PriceAlertsState {
  const PriceAlertsLoading();
}

final class PriceAlertsLoaded extends PriceAlertsState {
  const PriceAlertsLoaded({
    required this.alerts,
    this.isCreating = false,
  });
  final List<PriceAlert> alerts;
  final bool isCreating;

  int get activeCount => alerts.where((a) => a.isActive).length;
  int get triggeredCount => alerts.where((a) => a.isTriggered).length;

  PriceAlertsLoaded copyWith({
    List<PriceAlert>? alerts,
    bool? isCreating,
  }) {
    return PriceAlertsLoaded(
      alerts: alerts ?? this.alerts,
      isCreating: isCreating ?? this.isCreating,
    );
  }

  @override
  List<Object?> get props => [alerts, isCreating];
}

final class PriceAlertsError extends PriceAlertsState {
  const PriceAlertsError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
