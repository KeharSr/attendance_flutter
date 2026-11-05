import 'package:attendance_flutter/core/dependency_injection/dependency_injection.dart';
import 'package:attendance_flutter/core/service/location/geo_location.dart';
import 'package:attendance_flutter/features/dashboard/domain/usecase/clockin_usecase.dart';
import 'package:attendance_flutter/features/dashboard/domain/usecase/clockout_usecase.dart';
import 'package:attendance_flutter/features/dashboard/presentation/view_model/state/attendance_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class AttendanceViewModel extends Notifier<AttendanceState> {
  @override
  AttendanceState build() {
    return AttendanceState.initial();
  }

  Future<void> clockInAttendance() async {
    if (state.isLoading || state.isFetchingToday) return;
    final record = state.attendance;
    final now = ref.read(currentTimeProvider).value ?? DateTime.now();
    if (record != null && record.isForDate(now)) {
      state = state.copyWith(
        successMessage: null,
        errorMessage: record.checkout != null
            ? 'Attendance is completed for today. You can clock in tomorrow.'
            : 'You have already clocked in today.',
      );
      return;
    }
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      successMessage: null,
    );

    try {
      final clockInUseCase = ref.read(clockInUseCaseProvider);
      final Position position = await GeoLocation.getCurrentLocation();

      final result = await clockInUseCase.call(
        ClockInParams(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: position.accuracy,
        ),
      );

      if (!ref.mounted) return;

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
        },
        (clockOut) {
          state = state.copyWith(
            isLoading: false,
            successMessage: 'Clock-In successful',
            hasLoadedToday: true,
            todayErrorMessage: null,
            attendance: clockOut,
          );
        },
      );
    } catch (error) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  Future<void> clockOutAttendance() async {
    if (state.isLoading || state.isFetchingToday) return;
    final record = state.attendance;
    final now = ref.read(currentTimeProvider).value ?? DateTime.now();
    if (record != null && record.isForDate(now) && record.checkout != null) {
      state = state.copyWith(
        successMessage: null,
        errorMessage: 'You have already clocked out today.',
      );
      return;
    }
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      successMessage: null,
    );

    try {
      final clockOutUseCase = ref.read(clockOutUseCaseProvider);
      final Position position = await GeoLocation.getCurrentLocation();

      final result = await clockOutUseCase.call(
        ClockOutParams(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: position.accuracy,
        ),
      );

      if (!ref.mounted) return;

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
        },
        (clockIn) {
          state = state.copyWith(
            isLoading: false,
            successMessage: 'Clock-out successful',
            hasLoadedToday: true,
            todayErrorMessage: null,
            attendance: clockIn,
          );
        },
      );
    } catch (error) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  Future<void> todayAttendance() async {
    if (state.isLoading || state.isFetchingToday) return;
    state = state.copyWith(
      isFetchingToday: true,
      todayErrorMessage: null,
      successMessage: null,
    );

    try {
      final result = await ref.read(todayAttendanceUsecaseProvider).call();
      if (!ref.mounted) return;
      result.fold(
        (failure) => state = state.copyWith(
          isFetchingToday: false,
          todayErrorMessage: failure.message,
        ),
        (attendance) => state = state.copyWith(
          isFetchingToday: false,
          hasLoadedToday: true,
          todayErrorMessage: null,
          attendance: attendance,
        ),
      );
    } catch (error) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isFetchingToday: false,
        todayErrorMessage: error.toString(),
      );
    }
  }
}
