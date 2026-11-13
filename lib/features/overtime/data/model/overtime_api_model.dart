import 'package:attendance_flutter/features/overtime/domain/entity/overtime_entity.dart';
import 'package:json_annotation/json_annotation.dart';
part 'overtime_api_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class OvertimeApiModel {
  final String id;
  final String userId;
  final String? overtimeStartTime;
  final String? overtimeEndTime;
  final String workDate;
  final String reason;
  final String status;
  final String? rejectReason;

  OvertimeApiModel({
    required this.id,
    required this.userId,
    this.overtimeStartTime,
    this.overtimeEndTime,
    this.workDate = '',
    required this.reason,
    required this.status,
    this.rejectReason,
  });

  factory OvertimeApiModel.fromJson(Map<String, dynamic> json) =>
      _$OvertimeApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$OvertimeApiModelToJson(this);

  // from Entity
  factory OvertimeApiModel.fromEntity(OvertimeEntity entity) {
    return OvertimeApiModel(
      id: entity.id,
      userId: entity.userId,
      overtimeStartTime: entity.overtimeStartTime,
      overtimeEndTime: entity.overtimeEndTime,
      workDate: entity.workDate,
      reason: entity.reason,
      status: entity.status,
      rejectReason: entity.rejectReason ?? '',
    );
  }

  // to Entity
  OvertimeEntity toEntity() {
    return OvertimeEntity(
      id: id,
      userId: userId,
      overtimeStartTime: overtimeStartTime,
      overtimeEndTime: overtimeEndTime,
      workDate: workDate,
      reason: reason,
      status: status,
      rejectReason: rejectReason,
    );
  }

  // to EntityList

  static List<OvertimeEntity> toEntityList(List<OvertimeApiModel> models) =>
      models.map((model) => model.toEntity()).toList();
}
