import 'package:attendance_flutter/core/dependency_injection/dependency_injection.dart';
import 'package:attendance_flutter/core/service/location/geo_location.dart';
import 'package:attendance_flutter/features/dashboard/domain/usecase/clockin_usecase.dart';
import 'package:attendance_flutter/features/dashboard/domain/usecase/clockout_usecase.dart';
import 'package:attendance_flutter/features/dashboard/presentation/view_model/state/attendance_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class AttendanceViewModel extends Notifier<AttendanceState> {
  @override
  build() {
    return AttendanceState.initial();
  }

  Future<void> clockInAttendance() async {
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

      print(position.latitude);
      print(position.longitude);
      print(position.accuracy);

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
            attendance: null,
          );
        },
        (clockOut) {
          state = state.copyWith(
            isLoading: false,
            successMessage: 'Clock-In successful',
            attendance: clockOut,
          );
        },
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  Future<void> clockOutAttendance() async {
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

      print(position.latitude);
      print(position.longitude);
      print(position.accuracy);

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
            attendance: null,
          );
        },
        (clockIn) {
          state = state.copyWith(
            isLoading: false,
            successMessage: 'Clock-out successful',
            attendance: clockIn,
          );
        },
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }
}
