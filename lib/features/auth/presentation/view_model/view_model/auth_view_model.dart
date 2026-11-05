import 'package:attendance_flutter/features/dashboard/presentation/view_model/view_model/dashboard_navigation.dart';
import 'package:attendance_flutter/core/dependency_injection/dependency_injection.dart';
import 'package:attendance_flutter/features/auth/domain/entity/auth_entity.dart';
import 'package:attendance_flutter/features/auth/domain/usecase/create_user_usecase.dart';
import 'package:attendance_flutter/features/auth/domain/usecase/login_user_usecase.dart';
import 'package:attendance_flutter/features/auth/presentation/view_model/state/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthViewModel extends Notifier<AuthState> {
  AuthViewModel();

  @override
  AuthState build() {
    return AuthState.initial();
  }

  Future<void> createUser(AuthEntity entity) async {
    state = state.copyWith(
      isLoading: true,
      successMessage: null,
      errorMessage: null,
    );

    final createUserUseCase = ref.read(createUserUseCaseProvider);
    final result = await createUserUseCase.call(
      CreateUserParams(
        name: entity.name,
        phone: entity.phone,
        password: entity.password,
      ),
    );
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          successMessage: null,
          errorMessage: failure.message,
          user: null,
        );
      },
      (user) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: null,
          successMessage: 'User created successfully',
          user: user,
        );
      },
    );
  }

  void togglePasswordVisibility() {
    state = state.copyWith(willPasswordShow: !state.willPasswordShow);
  }

  Future<void> loginUser({
    required String phone,
    required String password,
  }) async {
    if (state.isLoading || state.isLoggingOut) return;
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      successMessage: null,
      logoutMessage: null,
    );
    final result = await ref
        .read(loginUserUseCaseProvider)
        .call(LoginParams(phone: phone, password: password));
    if (!ref.mounted) return;
    await result.fold<Future<void>>(
      (failure) async {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (user) async {
        await ref
            .read(appSharedPrefsProvider)
            .saveUserSession(
              userId: user.id ?? '',
              name: user.name,
              phone: user.phone,
            );
        if (!ref.mounted) return;
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Login successful',
          user: user,
        );
        ref.read(authSessionProvider.notifier).markLoggedIn();
      },
    );
  }

  Future<void> logoutUser() async {
    if (state.isLoading || state.isLoggingOut) return;
    state = state.copyWith(
      isLoggingOut: true,
      errorMessage: null,
      successMessage: null,
      logoutMessage: null,
    );
    final result = await ref.read(logoutUserUsecaseProvider).call();
    if (!ref.mounted) return;
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoggingOut: false,
          errorMessage: failure.message,
        );
      },
      (message) {
        state = AuthState.initial().copyWith(logoutMessage: message);
        ref.read(authSessionProvider.notifier).markLoggedOut();
        ref.invalidate(attendanceViewModelProvider);
        ref.invalidate(leaveViewModelProvider);
        ref.invalidate(overtimeViewModelProvider);
        ref.invalidate(missingAttendanceViewModelProvider);
        ref.invalidate(dashboardNavigationProvider);
      },
    );
  }
}
