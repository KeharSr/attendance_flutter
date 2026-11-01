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
          successMessage: 'Missing Attendance Retrived Sucessfully',
          missingAttendance: missingAttendance,
        );
      },
    );
  }
}
