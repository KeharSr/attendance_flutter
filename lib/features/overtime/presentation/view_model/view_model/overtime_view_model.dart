import 'package:attendance_flutter/core/dependency_injection/dependency_injection.dart';
import 'package:attendance_flutter/features/overtime/domain/usecase/delete_overtime_usecase.dart';
import 'package:attendance_flutter/features/overtime/domain/usecase/edit_overtime_usecase.dart';
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

  Future<void> editOvertimeRequest({
    required String overtimeId,
    required String workDate,
    required double overtimeHours,
    required String reason,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      successMessage: null,
    );

    final editOvertimeEditUseCaseProvider = ref.read(
      editOvertimeUseCaseProvider,
    );

    final result = await editOvertimeEditUseCaseProvider.call(
      EditOvertimeRequestParams(
        overtimeId: overtimeId,
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
        final updatedOvertime = state.overtime
            .map((item) => item.id == overtime.id ? overtime : item)
            .toList();
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Overtime edit successfully.',
          errorMessage: null,
          overtime: updatedOvertime,
        );
      },
    );
  }

  Future<void> deleteOvertime({required String overtimeId}) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      successMessage: null,
    );

    final deleteOvertimeUseCase = ref.read(deleteOvertimeUseCaseProvider);

    final result = await deleteOvertimeUseCase.call(
      DeleteOvertimeParams(overtimeId: overtimeId),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          successMessage: null,
          errorMessage: failure.message,
        );
      },
      (success) {
        final idToRemove = int.parse(overtimeId);
        final updatedOvertime = state.overtime
            .where((item) => item.id != idToRemove)
            .toList();

        state = state.copyWith(
          isLoading: false,
          successMessage: 'Overtime deleted successfully.',
          errorMessage: null,
          overtime: updatedOvertime,
        );
      },
    );
  }
}
