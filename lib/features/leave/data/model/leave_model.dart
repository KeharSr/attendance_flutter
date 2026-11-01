import 'package:attendance_flutter/features/leave/domain/entity/leave_entity.dart';
import 'package:json_annotation/json_annotation.dart';
part 'leave_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class LeaveModel {
  final String id;
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final String status;

  const LeaveModel({
    required this.id,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
  });

  factory LeaveModel.fromJson(Map<String, dynamic> json) =>
      _$LeaveModelFromJson(json);

  Map<String, dynamic> toJson() => _$LeaveModelToJson(this);

  factory LeaveModel.fromEntity(LeaveEntity entity) {
    return LeaveModel(
      id: entity.id,
      userId: entity.userId,
      startDate: entity.startDate,
      endDate: entity.endDate,
      reason: entity.reason,
      status: entity.status,
    );
  }

  LeaveEntity toEntity() {
    return LeaveEntity(
      id: id,
      userId: userId,
      startDate: startDate,
      endDate: endDate,
      reason: reason,
      status: status,
    );
  }

  static List<LeaveEntity> toEntityList(List<LeaveModel> models) =>
      models.map((model) => model.toEntity()).toList();
}
