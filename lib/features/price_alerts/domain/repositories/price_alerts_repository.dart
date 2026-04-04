import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/price_alert.dart';

abstract class PriceAlertsRepository {
  TaskEither<Failure, List<PriceAlert>> getAlerts();
  TaskEither<Failure, PriceAlert> createAlert(PriceAlert alert);
  TaskEither<Failure, PriceAlert> toggleAlert(String alertId,
      {required bool active});
  TaskEither<Failure, Unit> deleteAlert(String alertId);
}
