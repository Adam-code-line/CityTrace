import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:latlong2/latlong.dart';

import '../../controllers/user_controller.dart';
import '../../controllers/map_trace_controller.dart';
import '../../core/utils/storage_util.dart';
import '../../services/journey_management/journey_service.dart';
import '../../services/context_service.dart';
import '../../models/user_model.dart';

class HomeController extends GetxController {
  // 依赖注入
  final UserController _userController = Get.find<UserController>();
  final MapTraceController _mapController = Get.find<MapTraceController>();
  final JourneyService _journeyService = JourneyService();
  final ContextService _contextService = ContextService();

  // AdvancedDrawer 控制器
  final AdvancedDrawerController advancedDrawerController =
      AdvancedDrawerController();

  // 响应式变量
  final RxList<Map<String, String>> recentTrips = <Map<String, String>>[].obs;
  final RxBool isMapReadyInSheet = false.obs;
  final RxString locationDisplay = "定位中...".obs; // 显示格式：上海市·黄浦区
  final RxString weatherDisplay = "--°C".obs; // 显示格式：多云 · 22°C
  final RxBool isLoadingRecent = false.obs;

  // 记录变量控制请求频率
  LatLng? _lastFetchPos;
  DateTime? _lastFetchTime;

  // 对外提供 Getter 方法
  UserModel? get currentUser => _userController.user;
  bool get isLoggedIn => _userController.isLoggedIn;
  LatLng? get currentPos => _mapController.currentPos.value;
  bool get isInJourney => _mapController.isInJourney.value;
  String? get currentJourneyId => _mapController.currentJourneyId.value;
  String? get duration => _mapController.durationStr.value;

  // 页面初始化
  /// 加载最近行程并开启位置监听
  @override
  void onInit() {
    super.onInit();
    _loadOngoingJourney();
    loadRecentTrips();
    if (currentPos != null) {
      _handlePositionChange(currentPos!);
    }
    // 监听位置变化
    ever(_mapController.currentPos, (LatLng? pos) {
      if (pos != null) _handlePositionChange(pos);
    });
    // 监听登录状态变化
    ever(_userController.isLoggedInRx, (_) => loadRecentTrips());
    // 监听行程状态变化
    ever(_mapController.isInJourney, (bool isInJourney) {
      if (!isInJourney && isLoggedIn) {
        // 行程结束且已登录，刷新最近行程列表
        loadRecentTrips();
      }
    });
  }

  // 逻辑处理

  void _loadOngoingJourney() async {
    String? cachedId = StorageUtil.getJourneyId();

    if (cachedId == null || cachedId.isEmpty) return;

    try {
      // 向后端请求该行程的详情，验证是否真的"正在进行"
      final journeyDetail = await _journeyService.getJourneyDetail(cachedId);

      if (journeyDetail != null && journeyDetail.status == "ongoing") {
        // 如果后端确认状态依然是进行中，则同步修改全局控制器的状态
        // 传递后端返回的开始时间，以便恢复准确的计时器
        DateTime? startTime = DateTime.tryParse(journeyDetail.startTime);
        _mapController.startJourney(cachedId, time: startTime);
      } else {
        // 如果后端显示已结束或数据异常，则清除本地失效的缓存
        StorageUtil.removeJourneyId();
        _mapController.stopJourney(); // 确保 UI 回到初始态
      }
    } catch (e) {
      debugPrint("恢复行程状态失败: $e");
    }
  }

  void loadRecentTrips() async {
    if (!isLoggedIn) {
      recentTrips.clear();
      return;
    }

    isLoadingRecent.value = true;

    try {
      final list = await _journeyService.getJourneyList(page: 1, size: 6);
      if (list.isNotEmpty) {
        final completedList = list.where((e) => e.status != "ongoing").toList();
        recentTrips.assignAll(
          completedList
              .map(
                (e) => {
                  "id": e.journeyId,
                  "title": e.title,
                  "date": e.startTime.split('T')[0],
                  "img": e.cover,
                },
              )
              .toList(),
        );
      } else {
        recentTrips.clear();
      }
    } catch (e) {
      recentTrips.clear();
    } finally {
      isLoadingRecent.value = false;
    }
  }

  /// 开始行程
  Future<void> onStartJourneyConfirmed() async {
    // 调用后端创建行程
    final newJourney = await _journeyService.startJourney(
      title: "新行程 ${DateTime.now().hour}:${DateTime.now().minute}",
      description: "开启一段奇妙的城市寻迹",
    );

    if (newJourney != null) {
      // 启动轨迹录制
      _mapController.startJourney(
        newJourney.journeyId,
        time: DateTime.tryParse(newJourney.startTime),
        withOffset: true,
      );
      // UI 反馈
      Get.back(); // 关闭底栏
      Get.toNamed('/journey', arguments: newJourney.journeyId);
    }
  }

  /// 回到行程页
  void handleJourneyCardClick() {
    Get.toNamed('/journey', arguments: currentJourneyId);
  }

  /// 头像点击
  void handleAvatarClick() {
    isLoggedIn
        ? advancedDrawerController.showDrawer()
        : Get.toNamed('/login');
  }

  /// 汉堡菜单按钮点击
  void handleMenuButtonPressed() {
    advancedDrawerController.showDrawer();
  }

  /// 侧边栏菜单点击
  void handleMenuClick(String route) {
    if (isLoggedIn) {
      Get.toNamed(route);
    } else {
      // 记录目标页面，登录成功后跳转
      StorageUtil.setTargetRoute(route);
      Get.toNamed('/login');
    }
  }

  /// 未登录状态下悬浮按钮点击
  void handleUnlogFabClick() {
    Get.toNamed('/login');
  }

  /// Bottom Sheet 地图渲染计时器
  void startMapLoadingTimer() {
    isMapReadyInSheet.value = false;
    Future.delayed(
      const Duration(milliseconds: 400),
      () => isMapReadyInSheet.value = true,
    );
  }

  void logout() => _userController.logout();

  /// 处理位置变化，更新环境信息
  void _handlePositionChange(LatLng pos) async {
    // 频率控制：如果距离上次更新不到 500 米且时间不到 10 分钟，就不重复请求
    if (_lastFetchPos != null && _lastFetchTime != null) {
      double distance = const Distance().as(
        LengthUnit.Meter,
        _lastFetchPos!,
        pos,
      );
      if (distance < 500 &&
          DateTime.now().difference(_lastFetchTime!).inMinutes < 10) {
        return;
      }
    }

    // 获取地理位置详情
    final geoInfo = await _contextService.getGeoInfo(
      pos.latitude,
      pos.longitude,
    );
    if (geoInfo != null) {
      locationDisplay.value = "${geoInfo.city} · ${geoInfo.district}";

      // 根据城市/区获取天气
      final weather = await _contextService.getWeather(geoInfo.district);
      if (weather != null) {
        weatherDisplay.value =
            "${weather.condition} · ${weather.temp.toInt()}°C";
      }

      // 更新缓存标记
      _lastFetchPos = pos;
      _lastFetchTime = DateTime.now();
    }
  }
}