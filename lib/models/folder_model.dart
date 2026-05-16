import 'package:json_annotation/json_annotation.dart';

part 'folder_model.g.dart';

/// 文件夹模型
///
/// 用于将行程归类管理，支持对行程进行分类整理。
/// 一个文件夹下可包含多个行程，一个行程仅可属于一个文件夹。
@JsonSerializable()
class FolderModel {
  /// 文件夹唯一标识
  final String folderId;

  /// 文件夹名称
  final String name;

  /// 文件夹描述文字
  final String? description;

  /// 创建时间字符串
  final String? createTime;

  /// 文件夹内行程数量（用于列表简略显示）
  final String? journeyCount;

  FolderModel({
    required this.folderId,
    required this.name,
    this.description,
    this.createTime,
    this.journeyCount,
  });
  factory FolderModel.fromJson(Map<String, dynamic> json) =>
      _$FolderModelFromJson(json);
}
