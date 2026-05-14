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

  final RxString selectedFolderId = "all".obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    initData();
  }

  Future<void> initData() async {
    isLoading.value = true;
    await Future.wait([_fetchFolders(), _fetchJourneys()]);
    isLoading.value = false;
  }

  Future<void> _fetchFolders() async {
    final list = await _folderService.getAllFolders();
    folders.assignAll(list);
  }

  Future<void> _fetchJourneys() async {
    String filterId = selectedFolderId.value == "all"
        ? ""
        : selectedFolderId.value;

    final list = await _journeyService.getJourneyList(
      page: 1,
      size: 100,
      folderId: filterId,
    );
    final completedList = list.where((e) => e.status != "ongoing").toList();
    journeys.assignAll(completedList);
  }

  void onFolderChanged(String folderId) {
    if (selectedFolderId.value == folderId) return;
    selectedFolderId.value = folderId;
    _fetchJourneys();
  }

  Future<void> renameJourney(String journeyId, String newTitle) async {
    if (newTitle.isEmpty) return;

    final updatedJourney = await _journeyService.updateJourney(
      journeyId,
      title: newTitle,
    );

    if (updatedJourney != null) {
      int index = journeys.indexWhere((j) => j.journeyId == journeyId);
      if (index != -1) {
        journeys[index] = updatedJourney;
        journeys.refresh();
      }
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().loadRecentTrips();
      }
      Get.snackbar("成功", "行程已重命名");
    } else {
      Get.snackbar("错误", "重命名失败，请重试");
    }
  }

  /// 移动行程到指定文件夹（单分类，覆盖式）
  Future<void> moveJourney(String journeyId, String targetFolderId) async {
    final success = await _folderService.moveJourneyToFolder(
      targetFolderId,
      journeyId,
    );

    if (success) {
      Get.snackbar("成功", "行程已移动");
      _fetchJourneys();
    } else {
      Get.snackbar("错误", "移动失败，请重试");
    }
  }

  /// 将行程从指定文件夹移出
  Future<void> removeJourneyFromFolder(
    String journeyId,
    String folderId,
  ) async {
    final success = await _folderService.removeJourneyFromFolder(
      folderId,
      journeyId,
    );

    if (success) {
      Get.snackbar("提示", "已从文件夹移出");
      _fetchJourneys();
    } else {
      Get.snackbar("错误", "移出失败，请重试");
    }
  }

  Future<void> deleteJourney(String id) async {
    final success = await _journeyService.deleteJourney(id);
    if (success) {
      journeys.removeWhere((item) => item.journeyId == id);
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().loadRecentTrips();
      }
      Get.snackbar("提示", "行程已移除");
    }
  }

  Future<void> createFolder(String name) async {
    if (name.isEmpty) return;
    final newFolder = await _folderService.createFolder(name, "");
    if (newFolder != null) {
      folders.add(newFolder);
      Get.snackbar("成功", "文件夹已创建");
    }
  }

  Future<void> renameFolder(String folderId, String newName) async {
    if (newName.isEmpty) return;
    final updated = await _folderService.updateFolder(folderId, newName, "");
    if (updated != null) {
      int index = folders.indexWhere((f) => f.folderId == folderId);
      if (index != -1) {
        folders[index] = updated;
        folders.refresh();
      }
      Get.snackbar("成功", "重命名成功");
    }
  }

  Future<void> deleteFolder(String folderId) async {
    final success = await _folderService.deleteFolder(folderId);
    if (success) {
      if (selectedFolderId.value == folderId) {
        selectedFolderId.value = "all";
        _fetchJourneys();
      }
      folders.removeWhere((f) => f.folderId == folderId);
      Get.snackbar("提示", "文件夹已移除");
    }
  }
}