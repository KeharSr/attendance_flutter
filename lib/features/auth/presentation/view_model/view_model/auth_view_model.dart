import 'dart:async';

import 'package:attendance_flutter/features/notifications/presentation/providers/notification_providers.dart';
import 'package:attendance_flutter/features/dashboard/presentation/view_model/view_model/dashboard_navigation.dart';
import 'package:attendance_flutter/core/dependency_injection/dependency_injection.dart';
import 'package:attendance_flutter/features/auth/domain/entity/auth_entity.dart';
import 'package:attendance_flutter/features/auth/domain/usecase/create_user_usecase.dart';
import 'package:attendance_flutter/features/auth/domain/usecase/login_user_usecase.dart';
import 'package:attendance_flutter/features/auth/presentation/view_model/state/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthViewModel extends Notifier<AuthState> {
  AuthViewModel();
  int _biometricOperation = 0;
  int _statusRequest = 0;

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
    if (state.isLoading || state.isLoggingOut || state.isBiometricLoading) {
      return;
    }
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      successMessage: null,
      logoutMessage: null,
    );
    _biometricOperation++;
    _statusRequest++;
    final result = await ref
        .read(loginUserUseCaseProvider)
        .call(LoginParams(phone: phone, password: password));
    if (!ref.mounted) return;
    await result.fold<Future<void>>(
      (failure) async {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (user) async {
        if (!ref.mounted) return;
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Login successful',
          user: user,
        );
        ref.read(authSessionProvider.notifier).markLoggedIn();
        unawaited(loadBiometricStatus());
      },
    );
  }

  Future<void> logoutUser() => _logout();

  Future<void> _logout({bool disableBiometrics = false}) async {
    if (!ref.read(authSessionProvider) ||
        state.isLoading ||
        state.isLoggingOut ||
        state.isBiometricLoading) {
      return;
    }
    state = state.copyWith(
      isLoggingOut: true,
      errorMessage: null,
      successMessage: null,
      logoutMessage: null,
    );
    _biometricOperation++;
    _statusRequest++;
    final notifications = ref.read(notificationViewModelProvider.notifier);
    final detached = await notifications.prepareLogout();
    if (!ref.mounted || !ref.read(authSessionProvider)) return;
    final detachFailure = detached.fold((failure) => failure, (_) => null);
    if (detachFailure != null) {
      state = state.copyWith(
        isLoggingOut: false,
        errorMessage: detachFailure.message,
      );
      unawaited(notifications.activate(requestPermission: false));
      return;
    }
    final result = disableBiometrics
        ? await ref.read(disableBiometricAndLogoutUsecaseProvider).call()
        : await ref.read(logoutUserUsecaseProvider).call();
    if (!ref.mounted || !ref.read(authSessionProvider)) return;
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoggingOut: false,
          errorMessage: failure.message,
        );
        unawaited(notifications.activate(requestPermission: false));
      },
      (message) {
        _completeLogout(message);
      },
    );
  }

  Future<void> expireSession() async {
    _biometricOperation++;
    _statusRequest++;
    await ref.read(clearExpiredSessionUsecaseProvider).call();
    if (!ref.mounted) return;
    _completeLogout('Your session has expired. Please sign in again.');
  }

  Future<void> loadBiometricStatus() async {
    final request = ++_statusRequest;
    final result = await ref.read(getBiometricStatusUsecaseProvider).call();
    if (!ref.mounted ||
        request != _statusRequest ||
        state.isBiometricLoading ||
        state.isLoggingOut) {
      return;
    }
    result.fold(
      (_) {},
      (status) => state = state.copyWith(
        biometricAvailable: status.available,
        biometricEnabled: status.enabled,
      ),
    );
  }

  Future<void> setBiometricLoginEnabled(bool enabled) async {
    if (state.isLoading ||
        state.isLoggingOut ||
        state.isBiometricLoading ||
        !ref.read(authSessionProvider)) {
      return;
    }
    if (!enabled) {
      await _logout(disableBiometrics: true);
      return;
    }
    final operation = ++_biometricOperation;
    _statusRequest++;
    state = state.copyWith(
      isBiometricLoading: true,
      errorMessage: null,
      successMessage: null,
    );
    final result = await ref.read(enableBiometricLoginUsecaseProvider).call();
    if (!ref.mounted || operation != _biometricOperation) return;
    result.fold(
      (failure) => state = state.copyWith(
        isBiometricLoading: false,
        errorMessage: failure.message,
      ),
      (enabled) => state = state.copyWith(
        isBiometricLoading: false,
        biometricEnabled: enabled || state.biometricEnabled,
        biometricAvailable: enabled || state.biometricAvailable,
        successMessage: enabled ? 'Biometric sign-in enabled.' : null,
      ),
    );
  }

  Future<void> loginWithBiometrics() async {
    if (state.isLoading || state.isLoggingOut || state.isBiometricLoading) {
      return;
    }
    final operation = ++_biometricOperation;
    _statusRequest++;
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      successMessage: null,
      logoutMessage: null,
    );
    final result = await ref.read(loginWithBiometricsUsecaseProvider).call();
    if (!ref.mounted || operation != _biometricOperation) return;
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (result) {
        final user = result.user;
        if (user == null) {
          state = state.copyWith(isLoading: false);
          return;
        }
        state = state.copyWith(
          isLoading: false,
          user: user,
          successMessage: 'Login successful',
        );
        ref.read(authSessionProvider.notifier).markLoggedIn();
      },
    );
  }

  void _completeLogout(String message) {
    state = AuthState.initial().copyWith(logoutMessage: message);
    ref.read(authSessionProvider.notifier).markLoggedOut();
    ref.invalidate(attendanceViewModelProvider);
    ref.invalidate(leaveViewModelProvider);
    ref.invalidate(overtimeViewModelProvider);
    ref.invalidate(missingAttendanceViewModelProvider);
    ref.invalidate(dashboardNavigationProvider);
  }
}
