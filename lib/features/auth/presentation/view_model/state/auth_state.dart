import 'package:attendance_flutter/features/auth/domain/entity/auth_entity.dart';
import 'package:equatable/equatable.dart';

class AuthState extends Equatable {
  static const _notProvided = Object();
  final bool isLoading;
  final bool isLoggingOut;
  final String? logoutMessage;
  final String? successMessage;
  final String? errorMessage;
  final AuthEntity? user;
  final bool willPasswordShow;

  const AuthState({
    required this.isLoading,
    this.isLoggingOut = false,
    this.logoutMessage,
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
    bool? isLoggingOut,
    Object? logoutMessage = _notProvided,
    Object? successMessage = _notProvided,
    Object? errorMessage = _notProvided,
    Object? user = _notProvided,
    bool? willPasswordShow,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isLoggingOut: isLoggingOut ?? this.isLoggingOut,
      logoutMessage: identical(logoutMessage, _notProvided)
          ? this.logoutMessage
          : logoutMessage as String?,
      successMessage: identical(successMessage, _notProvided)
          ? this.successMessage
          : successMessage as String?,
      errorMessage: identical(errorMessage, _notProvided)
          ? this.errorMessage
          : errorMessage as String?,
      user: identical(user, _notProvided) ? this.user : user as AuthEntity?,
      willPasswordShow: willPasswordShow ?? this.willPasswordShow,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isLoggingOut,
    logoutMessage,
    successMessage,
    errorMessage,
    user,
    willPasswordShow,
  ];
}
