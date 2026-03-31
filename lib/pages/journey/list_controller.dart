import 'package:get/get.dart';

import '../../services/journey_management/journey_service.dart';
import '../../services/journey_management/folder_service.dart';
import '../../models/journey_model.dart';
import '../../models/folder_model.dart';
import '../home/home_controller.dart';

class ListController extends GetxController {
  final JourneyService _journeyService = JourneyService();
  final FolderService _folderService = FolderService();

  // --- 响应式数据 ---
  final RxList<FolderModel> folders = <FolderModel>[].obs;
  final RxList<JourneyModel> journeys = <JourneyModel>[].obs;

  final RxString selectedFolderId = "all".obs; // "all" 表示显示全部
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    initData();
  }

  /// 初始加载
  Future<void> initData() async {
    isLoading.value = true;
    // 请求文件夹和首屏行程
    await Future.wait([_fetchFolders(), _fetchJourneys()]);
    isLoading.value = false;
  }

  /// 获取所有文件夹
  Future<void> _fetchFolders() async {
    final list = await _folderService.getAllFolders();
    folders.assignAll(list);
  }

  /// 获取行程列表 (支持按文件夹过滤)
  Future<void> _fetchJourneys() async {
    // 如果是 "all"，则为空字符串
    String filterId = selectedFolderId.value == "all"
        ? ""
        : selectedFolderId.value;

    final list = await _journeyService.getJourneyList(
      page: 1,
      size: 20,
      folderId: filterId,
    );
    final completedList = list.where((e) => e.status != "ongoing").toList();
    journeys.assignAll(completedList);
  }

  /// 切换文件夹逻辑
  void onFolderChanged(String folderId) {
    if (selectedFolderId.value == folderId) return;

    selectedFolderId.value = folderId;
    _fetchJourneys();
  }

  /// 重命名行程
  Future<void> renameJourney(String journeyId, String newTitle) async {
    if (newTitle.isEmpty) return;

    final updatedJourney = await _journeyService.updateJourney(
      journeyId,
      title: newTitle,
    );

    if (updatedJourney != null) {
      // 找到本地列表中的 index 并替换，触发 Obx 刷新
      int index = journeys.indexWhere((j) => j.journeyId == journeyId);
      if (index != -1) {
        journeys[index] = updatedJourney;
        journeys.refresh(); // 通知 RxList 更新
      }
      // 主页更新
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().loadRecentTrips();
      }
      Get.snackbar("成功", "行程已重命名");
    } else {
      Get.snackbar("错误", "重命名失败，请重试");
    }
  }

  /// 移动行程到指定文件夹
  Future<void> moveJourney(String journeyId, String targetFolderId) async {
    // 调用 folderService 中已有的 moveJourneyToFolder
    final success = await _folderService.moveJourneyToFolder(
      targetFolderId,
      journeyId,
    );

    if (success) {
      Get.snackbar("成功", "行程已移动");
      // 移动后，为了保证当前文件夹显示的列表准确，重新获取一次列表
      _fetchJourneys();
    } else {
      Get.snackbar("错误", "移动失败，请重试");
    }
  }

  /// 删除行程逻辑
  Future<void> deleteJourney(String id) async {
    final success = await _journeyService.deleteJourney(id);
    if (success) {
      journeys.removeWhere((item) => item.journeyId == id);
      // 主页更新
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().loadRecentTrips();
      }
      Get.snackbar("提示", "行程已移除");
    }
  }

  /// 创建文件夹
  Future<void> createFolder(String name) async {
    if (name.isEmpty) return;
    final newFolder = await _folderService.createFolder(name, "");
    if (newFolder != null) {
      folders.add(newFolder);
      Get.snackbar("成功", "文件夹已创建");
    }
  }

  /// 重命名文件夹
  Future<void> renameFolder(String folderId, String newName) async {
    if (newName.isEmpty) return;
    final updated = await _folderService.updateFolder(folderId, newName, "");
    if (updated != null) {
      // 找到本地列表中的 index 并替换
      int index = folders.indexWhere((f) => f.folderId == folderId);
      if (index != -1) {
        folders[index] = updated;
        folders.refresh(); // 通知 UI 更新
      }
      Get.snackbar("成功", "重命名成功");
    }
  }

  /// 删除文件夹
  Future<void> deleteFolder(String folderId) async {
    final success = await _folderService.deleteFolder(folderId);
    if (success) {
      // 如果当前选中的是被删除的文件夹，切回 "all"
      if (selectedFolderId.value == folderId) {
        selectedFolderId.value = "all";
        _fetchJourneys();
      }
      folders.removeWhere((f) => f.folderId == folderId);
      Get.snackbar("提示", "文件夹已移除");
    }
  }
}
