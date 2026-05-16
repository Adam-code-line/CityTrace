import 'package:json_annotation/json_annotation.dart';

part 'journey_model.g.dart';

/// 行程模型
///
/// 代表用户一次完整的城市探索旅程，包含行程基本信息、状态、
/// 以及关联的瞬间（精彩记录点）。
/// status: "ongoing" 表示正在进行中，"ended" 表示已结束。
@JsonSerializable()
class JourneyModel {
  /// 行程唯一标识
  final String journeyId;

  /// 行程标题名称
  final String title;

  /// 行程描述文字
  final String? description;

  /// 封面图片 URL
  final String cover;

  /// 行程状态：ongoing（进行中）/ ended（已结束）
  final String status;

  /// 行程开始时间（ISO 8601 格式字符串）
  final String startTime;

  /// 行程结束时间（ISO 8601 格式字符串，进行中时为 null）
  final String? endTime;

  /// 所属文件夹 ID（未归类时为 null）
  final String? folderId;

  /// 关联的瞬间 ID 列表
  final List<String>? moments;

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
