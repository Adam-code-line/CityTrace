import 'package:json_annotation/json_annotation.dart';

part 'journey_model.g.dart';

@JsonSerializable()
class JourneyModel {
  final String journeyId;
  final String title;
  final String? description;
  final String cover;
  final String status; // ongoing, ended
  final String startTime;
  final String? endTime;
  final String? folderId; // 所属文件夹
  final List<String>? moments; // 瞬间 ID 列表

  JourneyModel({
    required this.journeyId,
    required this.title,
    this.description,
    required this.cover,
    required this.status,
    required this.startTime,
    this.endTime,
    this.folderId,
    this.moments,
  });

  /// 获取所属文件夹ID（可能为 null）
  String? getFolderId() => folderId;

  /// 判断是否属于某个文件夹
  bool isInFolder(String fid) => folderId == fid;

  factory JourneyModel.fromJson(Map<String, dynamic> json) =>
      _$JourneyModelFromJson(json);
  Map<String, dynamic> toJson() => _$JourneyModelToJson(this);
}