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
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      successMessage: null,
    );

    final loginUsecase = ref.read(loginUserUseCaseProvider);

    final result = await loginUsecase.call(
      LoginParams(phone: phone, password: password),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          successMessage: null,
          isLoading: false,
        );
      },
      (success) {
        state = state.copyWith(
          successMessage: 'Login successful',
          errorMessage: null,
          isLoading: false,
        );
      },
    );
  }
}
