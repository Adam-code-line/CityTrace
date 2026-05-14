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
  final String? folderId; // 保留向后兼容
  final List<String>? folderIds; // 多文件夹归属
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
    this.folderIds,
    this.moments,
  });

  /// 获取所有文件夹ID（合并 folderId 和 folderIds）
  List<String> getAllFolderIds() {
    final ids = <String>{};
    if (folderId != null && folderId!.isNotEmpty) ids.add(folderId!);
    if (folderIds != null) ids.addAll(folderIds!);
    return ids.toList();
  }

  /// 判断是否属于某个文件夹
  bool isInFolder(String fid) {
    if (folderId == fid) return true;
    if (folderIds != null && folderIds!.contains(fid)) return true;
    return false;
  }

  factory JourneyModel.fromJson(Map<String, dynamic> json) =>
      _$JourneyModelFromJson(json);
  Map<String, dynamic> toJson() => _$JourneyModelToJson(this);
}