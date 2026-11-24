import 'package:attendance_flutter/core/dependency_injection/dependency_injection.dart';
import 'package:attendance_flutter/features/overtime/domain/usecase/delete_overtime_usecase.dart';
import 'package:attendance_flutter/features/overtime/domain/usecase/edit_overtime_usecase.dart';
import 'package:attendance_flutter/features/overtime/domain/usecase/overtime_request_usecase.dart';
import 'package:attendance_flutter/features/overtime/presentation/view_model/state/overtime_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:attendance_flutter/features/overtime/domain/usecase/get_all_overtime_request_usecase.dart';

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
    required String overtimeStartTime,
    required String overtimeEndTime,
    required String reason,
  }) async {
    if (state.isLoading) return;
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
        overtimeStartTime: overtimeStartTime,
        overtimeEndTime: overtimeEndTime,
        reason: reason,
      ),
    );

    if (!ref.mounted) return;
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
        );
      },
    );
    if (result.isRight()) await getAllOvertimeRequest();
  }

  Future<void> selectYear(int year) async {
    if (state.isLoading || year == state.selectedYear || year < 1) return;
    state = state.copyWith(selectedYear: year, overtime: [], summary: null);
    await getAllOvertimeRequest();
  }

  Future<void> selectMonth(int month) async {
    if (state.isLoading ||
        month == state.selectedMonth ||
        month < 1 ||
        month > 12) {
      return;
    }
    state = state.copyWith(selectedMonth: month, overtime: [], summary: null);
    await getAllOvertimeRequest();
  }

  Future<void> getAllOvertimeRequest() async {
    if (state.isLoading) return;
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      successMessage: null,
    );

    final getAllOvertimeUsecaseProvider = ref.read(
      getAllOvertimeRequestUseCaseProvider,
    );

    final result = await getAllOvertimeUsecaseProvider.call(
      GetAllOvertimeParams(
        year: state.selectedYear,
        month: state.selectedMonth,
      ),
    );

    if (!ref.mounted) return;
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          successMessage: null,
          errorMessage: failure.message,
        );
      },
      (page) {
        state = state.copyWith(
          isLoading: false,
          successMessage: null,
          errorMessage: null,
          overtime: page.requests,
          summary: page.summary,
        );
      },
    );
  }

  Future<void> editOvertimeRequest({
    required String overtimeId,
    required String workDate,
    required String overtimeStartTime,
    required String overtimeEndTime,
    required String reason,
  }) async {
    if (state.isLoading) return;
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
        overtimeStartTime: overtimeStartTime,
        overtimeEndTime: overtimeEndTime,
        reason: reason,
      ),
    );

    if (!ref.mounted) return;
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
    if (result.isRight()) await getAllOvertimeRequest();
  }

  Future<void> deleteOvertime({required String overtimeId}) async {
    if (state.isLoading) return;
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      successMessage: null,
    );

    final deleteOvertimeUseCase = ref.read(deleteOvertimeUseCaseProvider);

    final result = await deleteOvertimeUseCase.call(
      DeleteOvertimeParams(overtimeId: overtimeId),
    );

    if (!ref.mounted) return;
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          successMessage: null,
          errorMessage: failure.message,
        );
      },
      (success) {
        final idToRemove = overtimeId;
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
    if (result.isRight()) await getAllOvertimeRequest();
  }
}
