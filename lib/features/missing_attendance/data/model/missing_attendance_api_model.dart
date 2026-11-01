import 'package:attendance_flutter/features/missing_attendance/domain/entity/missing_attendance_entity.dart';
import 'package:json_annotation/json_annotation.dart';
part 'missing_attendance_api_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class MissingAttendanceApiModel {
  final int id;
  final int userId;
  final String missingDate;
  final String requestedCheckIn;
  final String requestCheckOut;
  final String reason;
  final String status;

  const MissingAttendanceApiModel({
    required this.id,
    required this.userId,
    required this.missingDate,
    required this.requestedCheckIn,
    required this.requestCheckOut,
    required this.reason,
    required this.status,
  });

  factory MissingAttendanceApiModel.fromJson(Map<String, dynamic> json) {
    return MissingAttendanceApiModel(
      id: _parseInt(json['id'], 'id'),
      userId: _parseInt(json['user_id'], 'user_id'),
      missingDate: _parseString(json['missing_date']),
      requestedCheckIn: _parseString(json['requested_check_in']),
      requestCheckOut: _parseString(json['request_check_out']),
      reason: _parseString(json['reason']),
      status: _parseString(json['status'], fallback: 'Pending'),
    );
  }

  Map<String, dynamic> toJson() => _$MissingAttendanceApiModelToJson(this);

  // from entity
  factory MissingAttendanceApiModel.fromEntity(MissingAttendanceEntity entity) {
    return MissingAttendanceApiModel(
      id: entity.id,
      userId: entity.userId,
      missingDate: entity.missingDate,
      requestedCheckIn: entity.requestedCheckIn,
      requestCheckOut: entity.requestCheckOut,
      reason: entity.reason,
      status: entity.status,
    );
  }

  // to Entity
  MissingAttendanceEntity toEntity() {
    return MissingAttendanceEntity(
      id: id,
      userId: userId,
      missingDate: missingDate,
      requestedCheckIn: requestedCheckIn,
      requestCheckOut: requestCheckOut,
      reason: reason,
      status: status,
    );
  }

  // to Entity list

  static List<MissingAttendanceEntity> toEntityList(
    List<MissingAttendanceApiModel> models,
  ) => models.map((model) => model.toEntity()).toList();
}

int _parseInt(Object? value, String fieldName) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    final parsed = int.tryParse(value);
    if (parsed != null) return parsed;
  }

  throw FormatException(
    'Expected $fieldName to be an integer, received $value.',
  );
}

String _parseString(Object? value, {String fallback = ''}) {
  if (value == null) return fallback;
  if (value is String) return value;
  return value.toString();
}
