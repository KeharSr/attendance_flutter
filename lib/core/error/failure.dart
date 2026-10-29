import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure({
     this.statusCode,
    super.message = 'Failure from server',
  });

  final int? statusCode;

  @override
  List<Object?> get props => [statusCode, message];
}
