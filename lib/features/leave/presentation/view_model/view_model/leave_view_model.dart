import 'package:attendance_flutter/core/dependency_injection/dependency_injection.dart';
import 'package:attendance_flutter/features/leave/domain/usecase/submit_leave_usecase.dart';
import 'package:attendance_flutter/features/leave/presentation/view_model/state/leave_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LeaveViewModel extends Notifier<LeaveState> {
  @override
  LeaveState build() => LeaveState.initial();

  void setStartDate(DateTime date) {
    state = state.copyWith(
      startDate: date,
      endDate: state.endDate != null && state.endDate!.isBefore(date)
          ? null
          : state.endDate,
    );
  }

  void setEndDate(DateTime date) {
    state = state.copyWith(endDate: date);
  }

  void clearSelectedDates() {
    state = state.copyWith(startDate: null, endDate: null);
  }

  Future<void> submitLeave({
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      successMessage: null,
    );

    final submitLeaveUseCase = ref.read(submitLeaveUseCaseProvider);

    final result = await submitLeaveUseCase.call(
      SubmitLeaveParams(startDate: startDate, endDate: endDate, reason: reason),
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (request) => state = state.copyWith(
        isLoading: false,
        requests: [request, ...state.requests],
        successMessage: 'Leave request submitted for review.',
      ),
    );
  }

  Future<void> getAllLeaves() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      successMessage: null,
    );
    final getAllLeaveUseCase = ref.read(getAllLeaveUseCaseProvider);

    final result = await getAllLeaveUseCase.call();

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (requests) =>
          state = state.copyWith(isLoading: false, requests: requests),
    );
  }
}
