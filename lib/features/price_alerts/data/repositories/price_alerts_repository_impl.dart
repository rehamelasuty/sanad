import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/price_alert.dart';
import '../../domain/repositories/price_alerts_repository.dart';
import '../datasources/price_alerts_local_datasource.dart';

class PriceAlertsRepositoryImpl implements PriceAlertsRepository {
  const PriceAlertsRepositoryImpl(this._datasource);
  final PriceAlertsLocalDatasource _datasource;

  @override
  TaskEither<Failure, List<PriceAlert>> getAlerts() =>
      TaskEither.tryCatch(
        () => _datasource.getAlerts(),
        (e, _) => CacheFailure(e.toString()),
      );

  @override
  TaskEither<Failure, PriceAlert> createAlert(PriceAlert alert) =>
      TaskEither.tryCatch(
        () => _datasource.createAlert(alert),
        (e, _) => CacheFailure(e.toString()),
      );

  @override
  TaskEither<Failure, PriceAlert> toggleAlert(String alertId,
          {required bool active}) =>
      TaskEither.tryCatch(
        () => _datasource.toggleAlert(alertId, active: active),
        (e, _) => CacheFailure(e.toString()),
      );

  @override
  TaskEither<Failure, Unit> deleteAlert(String alertId) =>
      TaskEither.tryCatch(
        () async {
          await _datasource.deleteAlert(alertId);
          return unit;
        },
        (e, _) => CacheFailure(e.toString()),
      );
}
