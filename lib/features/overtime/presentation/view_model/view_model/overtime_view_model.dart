import 'package:attendance_flutter/core/dependency_injection/dependency_injection.dart';
import 'package:attendance_flutter/features/overtime/domain/usecase/overtime_request_usecase.dart';
import 'package:attendance_flutter/features/overtime/presentation/view_model/state/overtime_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OvertimeViewModel extends Notifier<OvertimeState> {
  @override
  OvertimeState build() => OvertimeState.initial();

  void setWorkDate(DateTime date) {
    state = state.copyWith(workDate: date);
  }

  void clearWorkDate() {
    state = state.copyWith(workDate: null);
  }

  Future<void> createOvertimeRequest({
    required String workDate,
    required double overtimeHours,
    required String reason,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      successMessage: null,
    );

    final overtimeRequestUsecaseProvider = ref.read(
      overtimeRequestUseCaseProvider,
    );

    final result = await overtimeRequestUsecaseProvider.call(
      OvertimeRequestParams(
        workDate: workDate,
        overtimeHours: overtimeHours,
        reason: reason,
      ),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          successMessage: null,
          errorMessage: failure.message,
        );
      },
      (overtime) {
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Overtime request submitted for review.',
          errorMessage: null,
          overtime: [overtime, ...state.overtime],
        );
      },
    );
  }

  Future<void> getAllOvertimeRequest() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      successMessage: null,
    );

    final getAllOvertimeUsecaseProvider = ref.read(
      getAllOvertimeRequestUseCaseProvider,
    );

    final result = await getAllOvertimeUsecaseProvider.call();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          successMessage: null,
          errorMessage: failure.message,
        );
      },
      (overtime) {
        state = state.copyWith(
          isLoading: false,
          successMessage: null,
          errorMessage: null,
          overtime: overtime,
        );
      },
    );
  }
}
