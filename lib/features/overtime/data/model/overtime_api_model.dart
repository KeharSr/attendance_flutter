import 'package:attendance_flutter/features/overtime/domain/entity/overtime_entity.dart';
import 'package:json_annotation/json_annotation.dart';
part 'overtime_api_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class OvertimeApiModel {
  final int id;
  final int userId;
  final String workDate;
  final double overtimeHours;
  final String reason;
  final String status;

  OvertimeApiModel({
    required this.id,
    required this.userId,
    required this.workDate,
    required this.overtimeHours,
    required this.reason,
    required this.status,
  });

  factory OvertimeApiModel.fromJson(Map<String, dynamic> json) =>
      _$OvertimeApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$OvertimeApiModelToJson(this);

  // from Entity
  factory OvertimeApiModel.fromEntity(OvertimeEntity entity) {
    return OvertimeApiModel(
      id: entity.id,
      userId: entity.userId,
      workDate: entity.workDate,
      overtimeHours: entity.overtimeHours,
      reason: entity.reason,
      status: entity.status,
    );
  }

  // to Entity
  OvertimeEntity toEntity() {
    return OvertimeEntity(
      id: id,
      userId: userId,
      workDate: workDate,
      overtimeHours: overtimeHours,
      reason: reason,
      status: status,
    );
  }

  // to EntityList

  static List<OvertimeEntity> toEntityList(List<OvertimeApiModel> models) =>
      models.map((model) => model.toEntity()).toList();
}
