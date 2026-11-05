import 'package:attendance_flutter/features/missing_attendance/domain/usecase/delete_missing_attendance_usecase.dart';
import 'package:attendance_flutter/features/missing_attendance/domain/usecase/edit_missing_attendance_usecase.dart';
import 'package:attendance_flutter/core/dependency_injection/dependency_injection.dart';
import 'package:attendance_flutter/features/missing_attendance/domain/usecase/create_missing_attendance_usecase.dart';
import 'package:attendance_flutter/features/missing_attendance/presentation/view_model/state/missing_attendance_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MissingAttendanceViewModel extends Notifier<MissingAttendanceState> {
  @override
  build() {
    return MissingAttendanceState.inital();
  }

  Future<void> createMissingAttendance({
    required String missingDate,
    required String requestedCheckIn,
    required String requestedCheckOut,
    required String reason,
  }) async {
    if (state.isLoading) return;
    state = state.copyWith(
      isLoading: true,
      failureMessage: null,
      successMessage: null,
    );
    final createMissingAttendance = ref.read(
      createMissingAttendanceUsecaseProvider,
    );

    final result = await createMissingAttendance.call(
      MissingAttendanceParams(
        missingDate: missingDate,
        requestedCheckIn: requestedCheckIn,
        requestedCheckOut: requestedCheckOut,
        reason: reason,
      ),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          failureMessage: failure.message,
          successMessage: null,
        );
      },
      (missingAttendance) {
        state = state.copyWith(
          isLoading: false,
          failureMessage: null,
          successMessage: "Missing Attendance Created Successfully",
          missingAttendance: [...state.missingAttendance, missingAttendance],
        );
      },
    );
  }

  Future<void> fetchMissingAttendance() async {
    if (state.isLoading) return;
    state = state.copyWith(
      isLoading: true,
      failureMessage: null,
      successMessage: null,
    );

    final fetchMissingAttendanceUseCase = ref.read(
      fetchMissingAttendanceUsecaseProvider,
    );

    final result = await fetchMissingAttendanceUseCase.call();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          failureMessage: failure.message,
          successMessage: null,
        );
      },
      (missingAttendance) {
        state = state.copyWith(
          isLoading: false,
          failureMessage: null,
          successMessage: null,
          missingAttendance: missingAttendance,
        );
      },
    );
  }

  Future<bool> editMissingAttendance({
    required String requestId,
    required String missingDate,
    required String? requestedCheckIn,
    required String? requestedCheckOut,
    required String reason,
  }) async {
    if (state.isLoading) return false;
    state = state.copyWith(
      isLoading: true,
      failureMessage: null,
      successMessage: null,
    );
    final result = await ref
        .read(editMissingAttendanceUsecaseProvider)
        .call(
          EditMissingAttendanceParams(
            requestId: requestId,
            missingDate: missingDate,
            requestedCheckIn: requestedCheckIn,
            requestedCheckOut: requestedCheckOut,
            reason: reason,
          ),
        );
    if (!ref.mounted) return false;
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          failureMessage: failure.message,
        );
        return false;
      },
      (updated) {
        state = state.copyWith(
          isLoading: false,
          missingAttendance: state.missingAttendance
              .map((item) => item.id.toString() == requestId ? updated : item)
              .toList(),
          successMessage: 'Attendance report updated successfully.',
        );
        return true;
      },
    );
  }

  Future<bool> deleteMissingAttendance({required String requestId}) async {
    if (state.isLoading) return false;
    state = state.copyWith(
      isLoading: true,
      failureMessage: null,
      successMessage: null,
    );
    final result = await ref
        .read(deleteMissingAttendanceUsecaseProvider)
        .call(DeleteMissingAttendanceParams(requestId: requestId));
    if (!ref.mounted) return false;
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          failureMessage: failure.message,
        );
        return false;
      },
      (deleted) {
        if (!deleted) {
          state = state.copyWith(
            isLoading: false,
            failureMessage: 'Unable to delete the request. Please try again.',
          );
          return false;
        }
        state = state.copyWith(
          isLoading: false,
          missingAttendance: state.missingAttendance
              .where((item) => item.id.toString() != requestId)
              .toList(),
          successMessage: 'Attendance report deleted successfully.',
        );
        return true;
      },
    );
  }
}
