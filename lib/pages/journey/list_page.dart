import 'package:citytrace/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'list_controller.dart';
import '../../models/journey_model.dart';
import '../../components/journey_card.dart';
import '../../components/classify_sheet.dart';
import '../../components/app_dialog.dart';

class ListPage extends GetView<ListController> {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ListController());

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
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
          _buildFolderFilter(),
          Expanded(child: _buildJourneyList()),
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
            _buildFilterChip("全部", "all"),
            ...controller.folders.map(
              (f) => _buildFilterChip(f.name, f.folderId, isDynamic: true),
            ),
            Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: GestureDetector(
                onTap: () => _showCreateFolderDialog(),
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
            color: isSelected ? AppColors.primary : Colors.grey.shade100,
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

  /// 行程列表
  Widget _buildJourneyList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.journeys.isEmpty) {
        return const EmptyJourneyState();
      }
      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20.r, vertical: 0),
        itemCount: controller.journeys.length,
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsets.only(bottom: 30.h),
          child: _buildCard(controller.journeys[index]),
        ),
      );
    });
  }

  /// 单个卡片（使用 SwipeableJourneyCard 组件）
  Widget _buildCard(JourneyModel journey) {
    return SwipeableJourneyCard(
      journey: journey,
      folders: controller.folders,
      onTap: () => Get.toNamed('/journey', arguments: journey.journeyId),
      onLongPress: () => _showJourneyOptions(journey),
      onSwipeClassify: () => _showClassifySheet(journey),
    );
  }

  /// 弹出归类面板（使用 ClassifySheet 组件）
  void _showClassifySheet(JourneyModel journey) {
    ClassifySheet.show(
      journey: journey,
      folders: controller.folders,
      onCreateFolder: (name) => controller.createFolder(name),
      onConfirm: (journeyId, folderId) {
        if (folderId != null) {
          controller.moveJourney(journeyId, folderId);
        } else {
          controller.removeJourneyFromFolder(journeyId, journey.folderId ?? '');
        }
      },
    );
  }

  /// 优化的新建文件夹弹窗（使用 AppInputDialog 组件）
  void _showCreateFolderDialog() {
    AppInputDialog.show(
      title: "新建文件夹",
      icon: Icons.create_new_folder_outlined,
      hintText: "输入文件夹名称",
      confirmText: "确定创建",
      onConfirm: (name) => controller.createFolder(name),
    );
  }

  /// 行程长按菜单
  void _showJourneyOptions(JourneyModel journey) {
    final actions = <AppSheetAction>[
      AppSheetAction(
        icon: Icons.edit_outlined,
        label: "重命名行程",
        onTap: () => _showInputDialog(
          title: "重命名行程",
          initialValue: journey.title,
          onConfirm: (newName) =>
              controller.renameJourney(journey.journeyId, newName),
        ),
      ),
      AppSheetAction(
        icon: Icons.folder_open_outlined,
        label: "归类到文件夹",
        onTap: () => _showClassifySheet(journey),
      ),
      if (journey.folderId != null)
        AppSheetAction(
          icon: Icons.folder_off_outlined,
          label: "移出文件夹",
          color: Colors.orange,
          onTap: () => controller.removeJourneyFromFolder(
              journey.journeyId, journey.folderId!),
        ),
      AppSheetAction(
        icon: Icons.delete_outline,
        label: "删除行程",
        color: Colors.red,
        onTap: () => controller.deleteJourney(journey.journeyId),
      ),
    ];
    AppActionSheet.show(title: "行程操作", actions: actions);
  }

  /// 文件夹管理弹窗
  void _showFolderOptions(String folderId, String currentName) {
    final actions = <AppSheetAction>[
      AppSheetAction(
        icon: Icons.edit_outlined,
        label: "重命名文件夹",
        onTap: () => _showInputDialog(
          title: "重命名文件夹",
          initialValue: currentName,
          onConfirm: (newName) =>
              controller.renameFolder(folderId, newName),
        ),
      ),
      AppSheetAction(
        icon: Icons.delete_outline,
        label: "删除文件夹",
        color: Colors.red,
        onTap: () {
          AppConfirmDialog.show(
            title: "确认删除",
            message: "删除文件夹不会删除其中的行程，确定吗？",
            confirmText: "确定",
            cancelText: "取消",
            confirmColor: Colors.red,
            onConfirm: () => controller.deleteFolder(folderId),
          );
        },
      ),
    ];
    AppActionSheet.show(title: "文件夹操作", actions: actions);
  }

  /// 输入对话框（使用 AppInputDialog 组件）
  void _showInputDialog({
    required String title,
    String initialValue = "",
    required Function(String) onConfirm,
  }) {
    AppInputDialog.show(
      title: title,
      initialValue: initialValue,
      onConfirm: (value) => onConfirm(value),
    );
  }
}