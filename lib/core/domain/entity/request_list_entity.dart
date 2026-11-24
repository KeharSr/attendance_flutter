import 'package:equatable/equatable.dart';

import 'request_summary_entity.dart';

class RequestListEntity<T> extends Equatable {
  const RequestListEntity({required this.requests, required this.summary});

  final List<T> requests;
  final RequestSummaryEntity? summary;

  @override
  List<Object?> get props => [requests, summary];
}
