import 'package:attendance_flutter/features/auth/domain/entity/auth_entity.dart';
import 'package:equatable/equatable.dart';

class AuthState extends Equatable {
  final bool isLoading;
  final String? successMessage;
  final String? errorMessage;
  final AuthEntity? user;
  final bool willPasswordShow;

  const AuthState({
    required this.isLoading,
    required this.successMessage,
    required this.errorMessage,
    required this.user,
    required this.willPasswordShow,
  });

  factory AuthState.initial() => AuthState(
    isLoading: false,
    successMessage: null,
    errorMessage: null,
    user: null,
    willPasswordShow: false,
  );

  AuthState copyWith({
    bool? isLoading,
    String? successMessage,
    String? errorMessage,
    AuthEntity? user,
    bool? willPasswordShow,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      successMessage: successMessage ?? this.successMessage,
      errorMessage: errorMessage ?? this.errorMessage,
      user: user ?? this.user,
      willPasswordShow: willPasswordShow ?? this.willPasswordShow,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    successMessage,
    errorMessage,
    user,
    willPasswordShow,
  ];
}
