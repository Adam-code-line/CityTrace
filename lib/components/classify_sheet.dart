import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../models/journey_model.dart';
import '../models/folder_model.dart';

/// 行程归类 BottomSheet
/// 支持多选文件夹 + 新建文件夹 + 确认归类
class ClassifySheet extends StatefulWidget {
  final JourneyModel journey;
  final List<FolderModel> folders;
  final Future<void> Function(String name) onCreateFolder;
  final Future<void> Function(String journeyId, List<String> folderIds) onConfirm;

  const ClassifySheet({
    super.key,
    required this.journey,
    required this.folders,
    required this.onCreateFolder,
    required this.onConfirm,
  });

  /// 弹出归类面板
  static Future<void> show({
    required JourneyModel journey,
    required List<FolderModel> folders,
    required Future<void> Function(String name) onCreateFolder,
    required Future<void> Function(String journeyId, List<String> folderIds) onConfirm,
  }) {
    return Get.bottomSheet(
      ClassifySheet(
        journey: journey,
        folders: folders,
        onCreateFolder: onCreateFolder,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<ClassifySheet> createState() => _ClassifySheetState();
}

class _ClassifySheetState extends State<ClassifySheet> {
  late List<String> _selectedIds;
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedIds = List<String>.from(widget.journey.getAllFolderIds());
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
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题
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
                // 关闭按钮
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
            child: widget.folders.isEmpty
                ? _buildEmptyFolders()
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: widget.folders.length,
                    itemBuilder: (context, index) =>
                        _buildFolderItem(widget.folders[index]),
                  ),
          ),

          // 新建文件夹行
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
                  backgroundColor: const Color(0xFF009688),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "确认归类 (${_selectedIds.length})",
                  style: TextStyle(
                    color: Colors.white,
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
          Icon(
            Icons.folder_open_outlined,
            size: 60.r,
            color: Colors.grey.shade200,
          ),
          SizedBox(height: 16.h),
          const Text(
            "暂无文件夹，请在下方新建",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildFolderItem(FolderModel folder) {
    final isSelected = _selectedIds.contains(folder.folderId);
    return ListTile(
      leading: Container(
        width: 40.r,
        height: 40.r,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF009688).withOpacity(0.1)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(
          isSelected
              ? Icons.folder_special_outlined
              : Icons.folder_outlined,
          color: isSelected ? const Color(0xFF009688) : Colors.grey,
          size: 22.r,
        ),
      ),
      title: Text(
        folder.name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? const Color(0xFF009688) : Colors.black87,
        ),
      ),
      trailing: isSelected
          ? Container(
              padding: EdgeInsets.all(4.r),
              decoration: BoxDecoration(
                color: const Color(0xFF009688),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: 16.r,
              ),
            )
          : Icon(
              Icons.add_circle_outline,
              color: Colors.grey.shade300,
              size: 22.r,
            ),
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedIds.remove(folder.folderId);
          } else {
            _selectedIds.add(folder.folderId);
          }
        });
      },
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
                color: const Color(0xFF009688),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: 22.r,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleCreateFolder() {
    final name = _textController.text.trim();
    if (name.isEmpty) {
      Get.snackbar("提示", "请输入文件夹名称");
      return;
    }
    // 检查是否已存在同名文件夹
    final exists = widget.folders.any((f) => f.name == name);
    if (exists) {
      Get.snackbar("提示", "已存在同名文件夹");
      return;
    }
    widget.onCreateFolder(name);
    _textController.clear();
    FocusScope.of(Get.context!).unfocus();
  }

  void _handleConfirm() {
    if (_selectedIds.isEmpty) {
      Get.snackbar("提示", "请选择至少一个文件夹");
      return;
    }
    Get.back();
    widget.onConfirm(widget.journey.journeyId, List<String>.from(_selectedIds));
  }
}