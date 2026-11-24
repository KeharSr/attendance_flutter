import 'package:attendance_flutter/features/leave/domain/usecase/delete_leave_usecase.dart';
import 'package:attendance_flutter/features/leave/domain/usecase/edit_leave_usecase.dart';
import 'package:attendance_flutter/features/leave/domain/usecase/get_all_leave_usecase.dart';
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
    if (state.isLoading) return;
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      successMessage: null,
    );

    final submitLeaveUseCase = ref.read(submitLeaveUseCaseProvider);

    final result = await submitLeaveUseCase.call(
      SubmitLeaveParams(startDate: startDate, endDate: endDate, reason: reason),
    );

    if (!ref.mounted) return;
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(
        isLoading: false,
        successMessage: 'Leave request submitted for review.',
      ),
    );
    if (result.isRight()) await getAllLeaves();
  }

  Future<void> selectYear(int year) async {
    if (state.isLoading || year == state.selectedYear || year < 1) return;
    state = state.copyWith(selectedYear: year, requests: [], summary: null);
    await getAllLeaves();
  }

  Future<void> selectMonth(int month) async {
    if (state.isLoading ||
        month == state.selectedMonth ||
        month < 1 ||
        month > 12) {
      return;
    }
    state = state.copyWith(selectedMonth: month, requests: [], summary: null);
    await getAllLeaves();
  }

  Future<void> getAllLeaves() async {
    if (state.isLoading) return;
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      successMessage: null,
    );
    final getAllLeaveUseCase = ref.read(getAllLeaveUseCaseProvider);

    final result = await getAllLeaveUseCase.call(
      GetAllLeaveParams(year: state.selectedYear, month: state.selectedMonth),
    );
    if (!ref.mounted) return;

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (page) => state = state.copyWith(
        isLoading: false,
        requests: page.requests,
        summary: page.summary,
      ),
    );
  }

  Future<bool> editLeave({
    required String leaveRequestId,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    if (state.isLoading) return false;
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      successMessage: null,
    );
    final result = await ref
        .read(editLeaveUsecaseProvider)
        .call(
          EditLeaveParams(
            leaveRequestId: leaveRequestId,
            startDate: startDate,
            endDate: endDate,
            reason: reason,
          ),
        );
    if (!ref.mounted) return false;
    final updated = result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (updated) {
        state = state.copyWith(
          isLoading: false,
          requests: state.requests
              .map(
                (item) => item.id.toString() == leaveRequestId ? updated : item,
              )
              .toList(),
          successMessage: 'Leave request updated successfully.',
        );
        return true;
      },
    );
    if (updated) await getAllLeaves();
    return updated;
  }

  Future<bool> deleteLeave({required String leaveRequestId}) async {
    if (state.isLoading) return false;
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      successMessage: null,
    );
    final result = await ref
        .read(deleteLeaveUsecaseProvider)
        .call(DeleteLeaveParams(leaveRequestId: leaveRequestId));
    if (!ref.mounted) return false;
    final deleted = result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (deleted) {
        if (!deleted) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: 'Unable to delete the request. Please try again.',
          );
          return false;
        }
        state = state.copyWith(
          isLoading: false,
          requests: state.requests
              .where((item) => item.id.toString() != leaveRequestId)
              .toList(),
          successMessage: 'Leave request deleted successfully.',
        );
        return true;
      },
    );
    if (deleted) await getAllLeaves();
    return deleted;
  }
}
