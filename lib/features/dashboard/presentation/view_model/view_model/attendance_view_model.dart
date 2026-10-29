import 'package:attendance_flutter/core/dependency_injection/dependency_injection.dart';
import 'package:attendance_flutter/features/dashboard/domain/usecase/clockin_usecase.dart';
import 'package:attendance_flutter/features/dashboard/presentation/view_model/state/attendance_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AttendanceViewModel extends Notifier<AttendanceState> {
  @override
  build() {
    return AttendanceState.initial();
  }

  Future<void> clockInEvent({
    required double latitude,
    required double longitude,
    required num accuracy,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      successMessage: null,
    );

    final clockInUseCase = ref.read(clockInUseCaseProvider);

    final result = await clockInUseCase.call(
      ClockInParams(
        latitude: latitude,
        longitude: longitude,
        accuracy: accuracy,
      ),
    );

    result.fold(
      (failure) {
        state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
          attendance: null,
        );
      },
      (clockIn) {
        state.copyWith(
          isLoading: false,
          successMessage: 'Clock In sucessful',
          attendance: clockIn,
        );
      },
    );
  }
}
