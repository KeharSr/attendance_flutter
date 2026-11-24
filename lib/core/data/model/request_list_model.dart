import 'package:attendance_flutter/core/domain/entity/request_list_entity.dart';

import 'request_summary_model.dart';

class RequestListModel<T> {
  const RequestListModel({required this.requests, required this.summary});

  factory RequestListModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) parseRequest,
  ) {
    final summary = json['summary'];
    return RequestListModel(
      requests: (json['data'] as List)
          .map((item) => parseRequest(item as Map<String, dynamic>))
          .toList(),
      summary: summary == null
          ? null
          : RequestSummaryModel.fromJson(summary as Map<String, dynamic>),
    );
  }

  final List<T> requests;
  final RequestSummaryModel? summary;

  RequestListEntity<E> toEntity<E>(E Function(T) convert) => RequestListEntity(
    requests: requests.map(convert).toList(),
    summary: summary?.toEntity(),
  );
}
