import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/dca_plan.dart';
import '../../domain/usecases/dca_plan_usecases.dart';
import '../../domain/usecases/get_dca_plans_usecase.dart';
import 'dca_state.dart';

class DcaCubit extends Cubit<DcaState> {
  final GetDcaPlansUseCase _getPlans;
  final CreateDcaPlanUseCase _createPlan;
  final ToggleDcaPlanUseCase _togglePlan;

  DcaCubit({
    required GetDcaPlansUseCase getPlans,
    required CreateDcaPlanUseCase createPlan,
    required ToggleDcaPlanUseCase togglePlan,
  })  : _getPlans = getPlans,
        _createPlan = createPlan,
        _togglePlan = togglePlan,
        super(const DcaInitial());

  Future<void> loadPlans() async {
    emit(const DcaLoading());
    final result = await _getPlans().run();
    result.fold(
      (failure) => emit(DcaError(failure.message)),
      (plans) => emit(DcaLoaded(plans: plans)),
    );
  }

  Future<void> createPlan(DcaPlan plan) async {
    final current = state;
    if (current is! DcaLoaded) return;
    emit(current.copyWith(isCreating: true));
    final result = await _createPlan(plan).run();
    result.fold(
      (failure) => emit(DcaError(failure.message)),
      (created) => emit(DcaLoaded(plans: [...current.plans, created])),
    );
  }

  Future<void> togglePlan(String id, {required bool active}) async {
    final current = state;
    if (current is! DcaLoaded) return;
    final result = await _togglePlan(id, active: active).run();
    result.fold(
      (failure) => emit(DcaError(failure.message)),
      (updated) {
        final newPlans = current.plans
            .map((p) => p.id == updated.id ? updated : p)
            .toList();
        emit(DcaLoaded(plans: newPlans));
      },
    );
  }
}
