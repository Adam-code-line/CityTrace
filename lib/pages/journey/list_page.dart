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
                    _buildJourneyCard(controller.journeys[index]),
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
            // “全部”选项
            _buildFilterChip("全部", "all"),
            // 动态加载的文件夹
            ...controller.folders.map(
              (f) => _buildFilterChip(f.name, f.folderId, isDynamic: true),
            ),
            Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: GestureDetector(
                onTap: () => _showInputDialog(
                  title: "新建文件夹",
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

  /// 行程卡片
  Widget _buildJourneyCard(JourneyModel journey) {
    return GestureDetector(
      onTap: () => Get.toNamed('/journey', arguments: journey.journeyId),
      onLongPress: () => _showJoueneyOptions(journey), // 长按弹出删除/移动菜单
      child: Container(
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        journey.title,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        journey.startTime.split('T')[0],
                        style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                      ),
                    ],
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showJoueneyOptions(JourneyModel journey) {
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
              title: const Text("移动到文件夹"),
              onTap: () {
                Get.back();
                _showMoveFolderPicker(journey);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text("删除行程", style: TextStyle(color: Colors.red)),
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
          const Text("这里空空如也，快去开启一段旅程吧", style: TextStyle(color: Colors.grey)),
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
              title: const Text("删除文件夹", style: TextStyle(color: Colors.red)),
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
      AlertDialog(
        title: Text(title),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: const InputDecoration(hintText: "请输入名称"),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("取消")),
          ElevatedButton(
            onPressed: () {
              onConfirm(textController.text.trim());
              Get.back();
            },
            child: const Text("确定"),
          ),
        ],
      ),
    );
  }

  /// 弹出文件夹选择列表
  void _showMoveFolderPicker(JourneyModel journey) {
    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(maxHeight: Get.height * 0.6), // 防止文件夹过多撑满屏幕
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(20.r),
              child: Text(
                "移动到文件夹",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ),
            Divider(height: 1.h),
            Expanded(
              child: Obx(() {
                if (controller.folders.isEmpty) {
                  return const Center(
                    child: Text(
                      "暂无可选文件夹",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: controller.folders.length,
                  itemBuilder: (context, index) {
                    final folder = controller.folders[index];
                    return ListTile(
                      leading: const Icon(
                        Icons.folder_shared_outlined,
                        color: Colors.teal,
                      ),
                      title: Text(folder.name),
                      onTap: () {
                        Get.back();
                        controller.moveJourney(
                          journey.journeyId,
                          folder.folderId,
                        );
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
