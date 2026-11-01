import 'package:attendance_flutter/core/api/api_client.dart';
import 'package:attendance_flutter/core/service/shared_prefs/app_shared_prefs.dart';
import 'package:attendance_flutter/features/auth/data/data_source/auth_data_source.dart';
import 'package:attendance_flutter/features/auth/data/repository/auth_repository_impl.dart';
import 'package:attendance_flutter/features/auth/domain/usecase/create_user_usecase.dart';
import 'package:attendance_flutter/features/auth/domain/usecase/login_user_usecase.dart';
import 'package:attendance_flutter/features/auth/presentation/view_model/state/auth_state.dart';
import 'package:attendance_flutter/features/auth/presentation/view_model/view_model/auth_view_model.dart';
import 'package:attendance_flutter/features/dashboard/data/data_source/attendance_data_source.dart';
import 'package:attendance_flutter/features/dashboard/data/repository/attendance_repository_impl.dart';
import 'package:attendance_flutter/features/dashboard/domain/usecase/clockin_usecase.dart';
import 'package:attendance_flutter/features/dashboard/domain/usecase/clockout_usecase.dart';
import 'package:attendance_flutter/features/dashboard/presentation/view_model/state/attendance_state.dart';
import 'package:attendance_flutter/features/dashboard/presentation/view_model/view_model/attendance_view_model.dart';
import 'package:attendance_flutter/features/leave/data/data_source/leave_data_source.dart';
import 'package:attendance_flutter/features/leave/data/repository/leave_repository_impl.dart';
import 'package:attendance_flutter/features/leave/domain/usecase/get_all_leave_usecase.dart';
import 'package:attendance_flutter/features/leave/domain/usecase/submit_leave_usecase.dart';
import 'package:attendance_flutter/features/leave/presentation/view_model/state/leave_state.dart';
import 'package:attendance_flutter/features/leave/presentation/view_model/view_model/leave_view_model.dart';
import 'package:attendance_flutter/features/missing_attendance/data/data_source/missing_attendance_data_source.dart';
import 'package:attendance_flutter/features/missing_attendance/data/repository/missing_attendance_repository_impl.dart';
import 'package:attendance_flutter/features/missing_attendance/domain/usecase/create_missing_attendance_usecase.dart';
import 'package:attendance_flutter/features/missing_attendance/domain/usecase/fetch_missing_attendance_usecase.dart';
import 'package:attendance_flutter/features/missing_attendance/presentation/view_model/state/missing_attendance_state.dart';
import 'package:attendance_flutter/features/missing_attendance/presentation/view_model/view_model/missing_attendance_view_model.dart';
import 'package:attendance_flutter/features/overtime/data/data_source/overtime_data_source.dart';
import 'package:attendance_flutter/features/overtime/data/repository/overtime_repository_impl.dart';
import 'package:attendance_flutter/features/overtime/domain/usecase/get_all_overtime_request_usecase.dart';
import 'package:attendance_flutter/features/overtime/domain/usecase/overtime_request_usecase.dart';
import 'package:attendance_flutter/features/overtime/presentation/view_model/state/overtime_state.dart';
import 'package:attendance_flutter/features/overtime/presentation/view_model/view_model/overtime_view_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final dioProvider = Provider((ref) {
  return Dio();
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw StateError(
    'SharedPreferences has not been initialized. '
    'Initialize it in main() and override sharedPreferencesProvider.',
  );
});

final appSharedPrefsProvider = Provider<AppSharedPrefs>((ref) {
  return AppSharedPrefs(sharedPreferences: ref.read(sharedPreferencesProvider));
});

class AuthSessionNotifier extends Notifier<bool> {
  @override
  bool build() => ref.read(appSharedPrefsProvider).isUserLoggedIn();

  void markLoggedOut() {
    state = false;
  }
}

final authSessionProvider = NotifierProvider<AuthSessionNotifier, bool>(
  AuthSessionNotifier.new,
);

final apiClientProvider = Provider<ApiClient>((ref) {
  late final ApiClient apiClient;
  apiClient = ApiClient(
    dio: ref.read(dioProvider),
    onUnauthorized: () async {
      await ref.read(appSharedPrefsProvider).removeSession();
      apiClient.clearAuthToken();
      ref.read(authSessionProvider.notifier).markLoggedOut();
    },
  );
  final token = ref.read(appSharedPrefsProvider).getAuthToken();
  if (token != null && token.isNotEmpty) {
    apiClient.setAuthToken(token);
  }
  return apiClient;
});

final authDataSourceProvider = Provider<AuthDataSource>((ref) {
  return AuthDataSource(
    apiClient: ref.read(apiClientProvider),
    appSharedPrefs: ref.read(appSharedPrefsProvider),
  );
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

final clockOutUseCaseProvider = Provider(
  (ref) => ClockOutUseCase(
    iAttendanceRepository: ref.read(attendanceRepositoyImplProvider),
  ),
);

final attendanceViewModelProvider =
    NotifierProvider<AttendanceViewModel, AttendanceState>(() {
      return AttendanceViewModel();
    });

final currentTimeProvider = StreamProvider.autoDispose<DateTime>((ref) {
  return Stream.periodic(const Duration(minutes: 1), (_) => DateTime.now());
});

// ================================= Leave Provider =================================

final leaveDataSourceProvider = Provider<LeaveDataSource>((ref) {
  return LeaveDataSource(apiClient: ref.read(apiClientProvider));
});

final leaveRepositoryProvider = Provider<LeaveRepositoryImpl>((ref) {
  return LeaveRepositoryImpl(dataSource: ref.read(leaveDataSourceProvider));
});

final submitLeaveUseCaseProvider = Provider<SubmitLeaveUseCase>((ref) {
  return SubmitLeaveUseCase(
    iLeaveRepository: ref.read(leaveRepositoryProvider),
  );
});

final getAllLeaveUseCaseProvider = Provider<GetAllLeaveUsecase>((ref) {
  return GetAllLeaveUsecase(
    iLeaveRepository: ref.read(leaveRepositoryProvider),
  );
});

final leaveViewModelProvider = NotifierProvider<LeaveViewModel, LeaveState>(
  LeaveViewModel.new,
);

// =================================== Overtime Provider ===========================

final overtimeDataSourceProvider = Provider<OvertimeDataSource>((ref) {
  return OvertimeDataSource(apiClient: ref.read(apiClientProvider));
});

final overtimeRepositoryProvider = Provider<OvertimeRepositoryImpl>((ref) {
  return OvertimeRepositoryImpl(
    overtimeDataSource: ref.read(overtimeDataSourceProvider),
  );
});

final overtimeRequestUseCaseProvider = Provider<OvertimeRequestUsecase>((ref) {
  return OvertimeRequestUsecase(
    iOvertimeRepository: ref.read(overtimeRepositoryProvider),
  );
});

final getAllOvertimeRequestUseCaseProvider =
    Provider<GetAllOvertimeRequestUsecase>((ref) {
      return GetAllOvertimeRequestUsecase(
        iOvertimeRepository: ref.read(overtimeRepositoryProvider),
      );
    });

final overtimeViewModelProvider =
    NotifierProvider<OvertimeViewModel, OvertimeState>(OvertimeViewModel.new);

// ================================= Missing Attendance Provider ==========================

final missingAttendanceDataSourceProvider = Provider(
  (ref) => MissingAttendanceDataSource(apiClient: ref.read(apiClientProvider)),
);

final missingAttendanceRepositoryProvider = Provider(
  (ref) => MissingAttendanceRepositoryImpl(
    missingAttendanceDataSource: ref.read(missingAttendanceDataSourceProvider),
  ),
);

final createMissingAttendanceUsecaseProvider = Provider(
  (ref) => CreateMissingAttendanceUsecase(
    iMissingAttendanceRepository: ref.read(missingAttendanceRepositoryProvider),
  ),
);

final fetchMissingAttendanceUsecaseProvider = Provider(
  (ref) => FetchMissingAttendanceUsecase(
    iMissingAttendanceRepository: ref.read(missingAttendanceRepositoryProvider),
  ),
);

final missingAttendanceViewModelProvider =
    NotifierProvider<MissingAttendanceViewModel, MissingAttendanceState>(() {
      return MissingAttendanceViewModel();
    });
