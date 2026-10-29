import 'package:attendance_flutter/core/api/api_client.dart';
import 'package:attendance_flutter/features/auth/data/data_source/auth_data_source.dart';
import 'package:attendance_flutter/features/auth/data/repository/auth_repository_impl.dart';
import 'package:attendance_flutter/features/auth/domain/usecase/create_user_usecase.dart';
import 'package:attendance_flutter/features/auth/domain/usecase/login_user_usecase.dart';
import 'package:attendance_flutter/features/auth/presentation/view_model/state/auth_state.dart';
import 'package:attendance_flutter/features/auth/presentation/view_model/view_model/auth_view_model.dart';
import 'package:attendance_flutter/features/dashboard/data/data_source/attendance_data_source.dart';
import 'package:attendance_flutter/features/dashboard/data/repository/attendance_repository_impl.dart';
import 'package:attendance_flutter/features/dashboard/domain/usecase/clockin_usecase.dart';
import 'package:attendance_flutter/features/dashboard/presentation/view_model/state/attendance_state.dart';
import 'package:attendance_flutter/features/dashboard/presentation/view_model/view_model/attendance_view_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider((ref) {
  return Dio();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(dio: ref.read(dioProvider));
});

final authDataSourceProvider = Provider<AuthDataSource>((ref) {
  return AuthDataSource(apiClient: ref.read(apiClientProvider));
});

final authRepositoryImplProvider = Provider<AuthRepositoryImpl>((ref) {
  return AuthRepositoryImpl(authDataSource: ref.read(authDataSourceProvider));
});

final createUserUseCaseProvider = Provider<CreateUserUsecase>((ref) {
  return CreateUserUsecase(
    authRepository: ref.read(authRepositoryImplProvider),
  );
});
final loginUserUseCaseProvider = Provider<LoginUserUsecase>((ref) {
  return LoginUserUsecase(
    iAuthRepository: ref.read(authRepositoryImplProvider),
  );
});

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(() {
  return AuthViewModel();
});

// ================================ Attendance Provider ===================================

final attendanceDataSourceProvider = Provider(
  (ref) => AttendanceDataSource(apiClient: ref.read(apiClientProvider)),
);

final attendanceRepositoyImplProvider = Provider((ref) {
  return AttendanceRepositoryImpl(
    attendanceDataSource: ref.read(attendanceDataSourceProvider),
  );
});

final clockInUseCaseProvider = Provider(
  (ref) => ClockinUsecase(
    iAttendanceRepository: ref.read(attendanceRepositoyImplProvider),
  ),
);

final attendanceViewModelProvider =
    NotifierProvider<AttendanceViewModel, AttendanceState>(() {
      return AttendanceViewModel();
    });
