import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'list_controller.dart';
import '../../models/journey_model.dart';

class ListPage extends GetView<ListController> {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ListController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "我的行程",
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 文件夹筛选条 (横向滑动)
          _buildFolderFilter(),

          // 行程列表
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.journeys.isEmpty) {
                return _buildEmptyState();
              }
              return ListView.builder(
                padding: EdgeInsets.all(20.r),
                itemCount: controller.journeys.length,
                itemBuilder: (context, index) =>
                    _buildSwipeableCard(controller.journeys[index]),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// 文件夹筛选条
  Widget _buildFolderFilter() {
    return Container(
      height: 60.h,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Obx(
        () => ListView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          children: [
            // "全部"选项
            _buildFilterChip("全部", "all"),
            // 动态加载的文件夹
            ...controller.folders.map(
              (f) => _buildFilterChip(f.name, f.folderId, isDynamic: true),
            ),
            Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: GestureDetector(
                onTap: () => _showCreateFolderDialog(
                  onConfirm: (name) => controller.createFolder(name),
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                  child: Icon(Icons.add, color: Colors.black54, size: 20.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String id, {bool isDynamic = false}) {
    return Obx(() {
      bool isSelected = controller.selectedFolderId.value == id;
      return GestureDetector(
        onTap: () => controller.onFolderChanged(id),
        onLongPress: () {
          if (isDynamic) _showFolderOptions(id, label);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.only(right: 12.w),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF009688) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(25.r),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: isSelected ? Colors.white : Colors.black54,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      );
    });
  }

  /// 右滑可归类的行程卡片
  Widget _buildSwipeableCard(JourneyModel journey) {
    return GestureDetector(
      onTap: () => Get.toNamed('/journey', arguments: journey.journeyId),
      onLongPress: () => _showJourneyOptions(journey),
      child: Stack(
        children: [
          // 右滑时露出的底层操作区
          _buildSlideAction(journey),
          // 上层卡片（通过 Dismissible 实现右滑效果）
          Dismissible(
            key: ValueKey('swipe_${journey.journeyId}'),
            direction: DismissDirection.startToEnd,
            confirmDismiss: (direction) async {
              // 阻止真正移除，改为显示归类弹窗
              _showClassifyBottomSheet(journey);
              return false; // 不移除卡片
            },
            background: const SizedBox.shrink(),
            child: _buildJourneyCard(journey),
          ),
        ],
      ),
    );
  }

  /// 右滑时露出的操作提示区
  Widget _buildSlideAction(JourneyModel journey) {
    final currentFolderIds = journey.getAllFolderIds();
    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      child: Container(
        width: 160.w,
        margin: EdgeInsets.only(bottom: 20.h),
        decoration: BoxDecoration(
          color: const Color(0xFF009688),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            bottomLeft: Radius.circular(20.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              currentFolderIds.isNotEmpty
                  ? Icons.replay_outlined
                  : Icons.folder_outlined,
              color: Colors.white,
              size: 24.r,
            ),
            SizedBox(width: 8.w),
            Text(
              currentFolderIds.isNotEmpty ? "重新归类" : "归类",
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 行程卡片
  Widget _buildJourneyCard(JourneyModel journey) {
    final currentFolderIds = journey.getAllFolderIds();
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        children: [
          // 卡片上半部分：路径缩略图或头图
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            child: Image.network(
              journey.cover,
              height: 160.h,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) =>
                  Container(color: Colors.teal.shade100, height: 160.h),
            ),
          ),
          // 卡片下半部分：信息
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        journey.title,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      journey.startTime.split('T')[0],
                      style:
                          TextStyle(color: Colors.grey, fontSize: 12.sp),
                    ),
                    if (currentFolderIds.isNotEmpty) ...[
                      SizedBox(width: 12.w),
                      // 显示已归类标记
                      ...currentFolderIds.take(2).map((fid) {
                        final folder = controller.folders.firstWhereOrNull(
                          (f) => f.folderId == fid,
                        );
                        if (folder == null) return const SizedBox.shrink();
                        return Padding(
                          padding: EdgeInsets.only(right: 6.w),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF009688).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text(
                              folder.name,
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: const Color(0xFF009688),
                              ),
                            ),
                          ),
                        );
                      }),
                      if (currentFolderIds.length > 2)
                        Text(
                          "+${currentFolderIds.length - 2}",
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // 底部：右滑提示
          Container(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.swipe,
                  size: 14.r,
                  color: Colors.grey.shade300,
                ),
                SizedBox(width: 4.w),
                Text(
                  currentFolderIds.isNotEmpty ? "右滑重新归类" : "右滑归类到文件夹",
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey.shade300,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 归类 BottomSheet（支持多选 + 新建文件夹）
  void _showClassifyBottomSheet(JourneyModel journey) {
    // 当前已选择的文件夹 ID（支持多选）- 使用普通列表通过 StatefulBuilder 管理
    final selectedIds = List<String>.from(journey.getAllFolderIds());
    // 文本控制器用于新建文件夹
    final textController = TextEditingController();

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) => Container(
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
                        child:
                            Icon(Icons.close, size: 18.r, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1.h),

              // 文件夹列表
              Expanded(
                child: Obx(() {
                  if (controller.folders.isEmpty) {
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
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: controller.folders.length,
                    itemBuilder: (context, index) {
                      final folder = controller.folders[index];
                      final isSelected = selectedIds.contains(folder.folderId);
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
                            color: isSelected
                                ? const Color(0xFF009688)
                                : Colors.grey,
                            size: 22.r,
                          ),
                        ),
                        title: Text(
                          folder.name,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? const Color(0xFF009688)
                                : Colors.black87,
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
                          setSheetState(() {
                            if (isSelected) {
                              selectedIds.remove(folder.folderId);
                            } else {
                              selectedIds.add(folder.folderId);
                            }
                          });
                        },
                      );
                    },
                  );
                }),
              ),

              // 新建文件夹行
              Padding(
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
                          controller: textController,
                          decoration: InputDecoration(
                            hintText: "新建文件夹名称...",
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14.sp,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 12.h,
                            ),
                          ),
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    GestureDetector(
                      onTap: () {
                        final name = textController.text.trim();
                        if (name.isEmpty) {
                          Get.snackbar("提示", "请输入文件夹名称");
                          return;
                        }
                        // 检查是否已存在同名文件夹
                        final exists = controller.folders.any(
                          (f) => f.name == name,
                        );
                        if (exists) {
                          Get.snackbar("提示", "已存在同名文件夹");
                          return;
                        }
                        controller.createFolder(name);
                        textController.clear();
                        // 聚焦 TextField 关闭键盘
                        FocusScope.of(context).unfocus();
                      },
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
              ),

              // 确认按钮
              Padding(
                padding: EdgeInsets.all(20.r),
                child: SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: () {
                      if (selectedIds.isEmpty) {
                        Get.snackbar("提示", "请选择至少一个文件夹");
                        return;
                      }
                      Get.back();
                      controller.setJourneyFolders(
                        journey.journeyId,
                        selectedIds.toList(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF009688),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "确认归类 (${selectedIds.length})",
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
        ),
      ),
    );
  }

  /// 优化的新建文件夹弹窗
  void _showCreateFolderDialog({
    required Function(String) onConfirm,
  }) {
    final textController = TextEditingController();
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题行
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFF009688).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.create_new_folder_outlined,
                      color: const Color(0xFF009688),
                      size: 24.r,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    "新建文件夹",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              // 输入框
              TextField(
                controller: textController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "输入文件夹名称",
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14.sp,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide(
                      color: const Color(0xFF009688),
                      width: 1.5,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                ),
                style: TextStyle(fontSize: 15.sp),
                onSubmitted: (value) {
                  final name = value.trim();
                  if (name.isNotEmpty) {
                    onConfirm(name);
                    Get.back();
                  }
                },
              ),
              SizedBox(height: 24.h),
              // 底部按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey,
                    ),
                    child: Text(
                      "取消",
                      style: TextStyle(fontSize: 15.sp),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  ElevatedButton(
                    onPressed: () {
                      final name = textController.text.trim();
                      if (name.isEmpty) {
                        Get.snackbar("提示", "请输入文件夹名称");
                        return;
                      }
                      onConfirm(name);
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF009688),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      elevation: 0,
                      padding: EdgeInsets.symmetric(
                        horizontal: 28.w,
                        vertical: 14.h,
                      ),
                    ),
                    child: Text(
                      "确定创建",
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 行程长按菜单
  void _showJourneyOptions(JourneyModel journey) {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text("重命名行程"),
              onTap: () {
                Get.back();
                _showInputDialog(
                  title: "重命名行程",
                  initialValue: journey.title,
                  onConfirm: (newName) =>
                      controller.renameJourney(journey.journeyId, newName),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_open_outlined),
              title: const Text("归类到文件夹"),
              onTap: () {
                Get.back();
                _showClassifyBottomSheet(journey);
              },
            ),
            if (journey.getAllFolderIds().isNotEmpty)
              ListTile(
                leading: const Icon(Icons.folder_off_outlined,
                    color: Colors.orange),
                title: const Text("从所有文件夹移出",
                    style: TextStyle(color: Colors.orange)),
                onTap: () {
                  Get.back();
                  controller.setJourneyFolders(journey.journeyId, []);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title:
                  const Text("删除行程", style: TextStyle(color: Colors.red)),
              onTap: () {
                Get.back();
                controller.deleteJourney(journey.journeyId);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined, size: 80.r, color: Colors.grey.shade200),
          SizedBox(height: 16.h),
          const Text("这里空空如也，快去开启一段旅程吧",
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // 文件夹管理弹窗
  void _showFolderOptions(String folderId, String currentName) {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text("重命名文件夹"),
              onTap: () {
                Get.back();
                _showInputDialog(
                  title: "重命名文件夹",
                  initialValue: currentName,
                  onConfirm: (newName) =>
                      controller.renameFolder(folderId, newName),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text("删除文件夹",
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Get.back();
                Get.defaultDialog(
                  title: "确认删除",
                  middleText: "删除文件夹不会删除其中的行程，确定吗？",
                  textConfirm: "确定",
                  textCancel: "取消",
                  confirmTextColor: Colors.white,
                  buttonColor: Colors.red,
                  onConfirm: () {
                    controller.deleteFolder(folderId);
                    Get.back();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showInputDialog({
    required String title,
    String initialValue = "",
    required Function(String) onConfirm,
  }) {
    final textController = TextEditingController(text: initialValue);
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: textController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "请输入名称",
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14.sp,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide(
                      color: const Color(0xFF009688),
                      width: 1.5,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                ),
                style: TextStyle(fontSize: 15.sp),
                onSubmitted: (value) {
                  final name = value.trim();
                  if (name.isNotEmpty) {
                    onConfirm(name);
                    Get.back();
                  }
                },
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey,
                    ),
                    child: Text(
                      "取消",
                      style: TextStyle(fontSize: 15.sp),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  ElevatedButton(
                    onPressed: () {
                      final name = textController.text.trim();
                      if (name.isEmpty) {
                        Get.snackbar("提示", "请输入名称");
                        return;
                      }
                      onConfirm(name);
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF009688),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      elevation: 0,
                      padding: EdgeInsets.symmetric(
                        horizontal: 28.w,
                        vertical: 14.h,
                      ),
                    ),
                    child: Text(
                      "确定",
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}