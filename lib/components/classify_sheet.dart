import 'package:citytrace/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../models/journey_model.dart';
import '../models/folder_model.dart';

/// 行程归类 BottomSheet（单文件夹选择）
class ClassifySheet extends StatefulWidget {
  final JourneyModel journey;
  final RxList<FolderModel> folders;
  final Future<void> Function(String name) onCreateFolder;
  final void Function(String journeyId, String? folderId) onConfirm;

  const ClassifySheet({
    super.key,
    required this.journey,
    required this.folders,
    required this.onCreateFolder,
    required this.onConfirm,
  });

  static Future<void> show({
    required JourneyModel journey,
    required RxList<FolderModel> folders,
    required Future<void> Function(String name) onCreateFolder,
    required void Function(String journeyId, String? folderId) onConfirm,
  }) {
    return Get.bottomSheet(
      ClassifySheet(
        journey: journey,
        folders: folders,
        onCreateFolder: onCreateFolder,
        onConfirm: onConfirm,
      ),
      isScrollControlled: true,
    );
  }

  @override
  State<ClassifySheet> createState() => _ClassifySheetState();
}

class _ClassifySheetState extends State<ClassifySheet> {
  String? _selectedId;
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedId = widget.journey.folderId;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: Get.height * 0.75),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(20.r),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "归类到文件夹",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, size: 18.r, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1.h),

          // 文件夹列表
          Expanded(
            child: Obx(() {
              if (widget.folders.isEmpty) {
                return _buildEmptyFolders();
              }
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: widget.folders.length + 1, // +1 for "不归类"
                itemBuilder: (context, index) {
                  if (index == widget.folders.length) {
                    return _buildNoneOption();
                  }
                  return _buildFolderItem(widget.folders[index]);
                },
              );
            }),
          ),

          _buildCreateRow(),

          // 确认按钮
          Padding(
            padding: EdgeInsets.all(20.r),
            child: SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                onPressed: _handleConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _selectedId != null ? "确认归类" : "移出所有文件夹",
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFolders() {
    return Padding(
      padding: EdgeInsets.all(40.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_outlined, size: 60.r, color: Colors.grey.shade200),
          SizedBox(height: 16.h),
          const Text("暂无文件夹，请在下方新建", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  /// "不归类"选项（取消当前文件夹）
  Widget _buildNoneOption() {
    final isNone = _selectedId == null;
    return ListTile(
      leading: Container(
        width: 40.r,
        height: 40.r,
        decoration: BoxDecoration(
          color: isNone
              ? AppColors.primaryOpacity010
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(
          Icons.folder_off_outlined,
          color: isNone ? AppColors.primary : Colors.grey,
          size: 22.r,
        ),
      ),
      title: Text(
        "不归类",
        style: TextStyle(
          fontWeight: isNone ? FontWeight.bold : FontWeight.normal,
          color: isNone ? AppColors.primary : AppColors.textBlack,
        ),
      ),
      trailing: isNone
          ? Container(
              padding: EdgeInsets.all(4.r),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check, color: AppColors.white, size: 16.r),
            )
          : const SizedBox.shrink(),
      onTap: () => setState(() => _selectedId = null),
    );
  }

  Widget _buildFolderItem(FolderModel folder) {
    final isSelected = _selectedId == folder.folderId;
    return ListTile(
      leading: Container(
        width: 40.r,
        height: 40.r,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryOpacity010
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(
          isSelected ? Icons.folder_special_outlined : Icons.folder_outlined,
          color: isSelected ? AppColors.primary : Colors.grey,
          size: 22.r,
        ),
      ),
      title: Text(
        folder.name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppColors.primary : AppColors.textBlack,
        ),
      ),
      trailing: isSelected
          ? Container(
              padding: EdgeInsets.all(4.r),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check, color: AppColors.white, size: 16.r),
            )
          : Icon(Icons.add_circle_outline, color: Colors.grey.shade300, size: 22.r),
      onTap: () => setState(() => _selectedId = folder.folderId),
    );
  }

  Widget _buildCreateRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: "新建文件夹名称...",
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14.sp,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: _handleCreateFolder,
            child: Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(Icons.add, color: AppColors.white, size: 22.r),
            ),
          ),
        ],
      ),
    );
  }

  void _handleCreateFolder() async {
    final name = _textController.text.trim();
    if (name.isEmpty) {
      Get.snackbar("提示", "请输入文件夹名称");
      return;
    }
    final exists = widget.folders.any((f) => f.name == name);
    if (exists) {
      Get.snackbar("提示", "已存在同名文件夹");
      return;
    }
    await widget.onCreateFolder(name);
    _textController.clear();
    FocusScope.of(Get.context!).unfocus();
  }

  void _handleConfirm() {
    Get.back();
    widget.onConfirm(widget.journey.journeyId, _selectedId);
  }
}