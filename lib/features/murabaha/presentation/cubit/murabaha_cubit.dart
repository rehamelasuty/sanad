import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/murabaha_plan.dart';
import '../../domain/usecases/get_murabaha_plans_usecase.dart';
import '../../domain/usecases/invest_in_murabaha_usecase.dart';
import 'murabaha_state.dart';

class MurabahaCubit extends Cubit<MurabahaState> {
  MurabahaCubit({
    required GetMurabahaPlansUseCase getPlans,
    required InvestInMurabahaUseCase invest,
  })  : _getPlans = getPlans,
        _invest = invest,
        super(const MurabahaInitial());

  final GetMurabahaPlansUseCase _getPlans;
  final InvestInMurabahaUseCase _invest;

  Future<void> loadPlans() async {
    emit(const MurabahaLoading());
    final result = await _getPlans().run();
    result.fold(
      (failure) => emit(MurabahaError(failure.userMessage)),
      (plans) => emit(
        MurabahaLoaded(
          plans: plans,
          investments: const [],
          selectedPlan: plans.isNotEmpty ? plans[1] : null, // default monthly
        ),
      ),
    );
  }

  void selectPlan(MurabahaPlan plan) {
    final current = state;
    if (current is MurabahaLoaded) {
      emit(current.copyWith(selectedPlan: plan));
    }
  }

  void updateAmount(double amount) {
    final current = state;
    if (current is MurabahaLoaded) {
      final plan = current.selectedPlan;
      final clamped = plan != null
          ? amount.clamp(plan.minAmount, plan.maxAmount).toDouble()
          : amount.clamp(0, double.maxFinite).toDouble();
      emit(current.copyWith(amount: clamped));
    }
  }

  Future<void> invest() async {
    final current = state;
    if (current is! MurabahaLoaded || current.selectedPlan == null) return;

    emit(current.copyWith(isInvesting: true));

    final result = await _invest(
      plan: current.selectedPlan!,
      amount: current.amount,
    ).run();

    result.fold(
      (failure) {
        emit(current.copyWith(isInvesting: false));
      },
      (investment) {
        emit(
          current.copyWith(
            isInvesting: false,
            lastInvestment: investment,
            investments: [...current.investments, investment],
          ),
        );
      },
    );
  }

  void dismissSuccess() {
    final current = state;
    if (current is MurabahaLoaded) {
      emit(current.copyWith(clearLastInvestment: true));
    }
  }
}
