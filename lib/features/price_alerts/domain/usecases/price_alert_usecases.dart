import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/price_alert.dart';
import '../repositories/price_alerts_repository.dart';

class GetAlertsUseCase {
  const GetAlertsUseCase(this._repo);
  final PriceAlertsRepository _repo;

  TaskEither<Failure, List<PriceAlert>> call() => _repo.getAlerts();
}

class CreateAlertUseCase {
  const CreateAlertUseCase(this._repo);
  final PriceAlertsRepository _repo;

  TaskEither<Failure, PriceAlert> call(PriceAlert alert) =>
      _repo.createAlert(alert);
}

class ToggleAlertUseCase {
  const ToggleAlertUseCase(this._repo);
  final PriceAlertsRepository _repo;

  TaskEither<Failure, PriceAlert> call(String alertId,
          {required bool active}) =>
      _repo.toggleAlert(alertId, active: active);
}

class DeleteAlertUseCase {
  const DeleteAlertUseCase(this._repo);
  final PriceAlertsRepository _repo;

  TaskEither<Failure, Unit> call(String alertId) =>
      _repo.deleteAlert(alertId);
}
