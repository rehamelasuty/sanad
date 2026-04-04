import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/price_alert.dart';
import '../../domain/usecases/price_alert_usecases.dart';
import 'price_alerts_state.dart';

class PriceAlertsCubit extends Cubit<PriceAlertsState> {
  PriceAlertsCubit({
    required GetAlertsUseCase getAlerts,
    required CreateAlertUseCase createAlert,
    required ToggleAlertUseCase toggleAlert,
    required DeleteAlertUseCase deleteAlert,
  })  : _getAlerts = getAlerts,
        _createAlert = createAlert,
        _toggleAlert = toggleAlert,
        _deleteAlert = deleteAlert,
        super(const PriceAlertsInitial());

  final GetAlertsUseCase _getAlerts;
  final CreateAlertUseCase _createAlert;
  final ToggleAlertUseCase _toggleAlert;
  final DeleteAlertUseCase _deleteAlert;

  Future<void> loadAlerts() async {
    emit(const PriceAlertsLoading());
    final result = await _getAlerts().run();
    result.fold(
      (failure) => emit(PriceAlertsError(failure.message)),
      (alerts) => emit(PriceAlertsLoaded(alerts: alerts)),
    );
  }

  Future<void> createAlert(PriceAlert alert) async {
    final current = state;
    if (current is! PriceAlertsLoaded) return;
    emit(current.copyWith(isCreating: true));
    final result = await _createAlert(alert).run();
    result.fold(
      (failure) => emit(PriceAlertsError(failure.message)),
      (created) => emit(PriceAlertsLoaded(
          alerts: [...current.alerts, created])),
    );
  }

  Future<void> toggleAlert(String alertId, {required bool active}) async {
    final current = state;
    if (current is! PriceAlertsLoaded) return;
    final result = await _toggleAlert(alertId, active: active).run();
    result.fold(
      (failure) => emit(PriceAlertsError(failure.message)),
      (updated) {
        final alerts = current.alerts
            .map((a) => a.id == alertId ? updated : a)
            .toList();
        emit(PriceAlertsLoaded(alerts: alerts));
      },
    );
  }

  Future<void> deleteAlert(String alertId) async {
    final current = state;
    if (current is! PriceAlertsLoaded) return;
    final result = await _deleteAlert(alertId).run();
    result.fold(
      (failure) => emit(PriceAlertsError(failure.message)),
      (_) {
        final alerts =
            current.alerts.where((a) => a.id != alertId).toList();
        emit(PriceAlertsLoaded(alerts: alerts));
      },
    );
  }
}
