import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../../core/utils/permission_util.dart';
import '../../models/journey_model.dart';
import '../../models/moment_model.dart';
import '../../services/context_service.dart';
import '../../services/journey_management/journey_service.dart';
import '../../services/journey_management/moment_service.dart';
import '../../controllers/map_trace_controller.dart';
import '../../core/utils/media_util.dart';
import '../home/home_controller.dart';

class JourneyDetailController extends GetxController {
  // 依赖注入
  final MapTraceController _mapController = Get.find<MapTraceController>();
  final JourneyService _journeyService = JourneyService();
  final MomentService _momentService = MomentService();
  final ContextService _contextService = ContextService();
  final MediaUtil _mediaUtil = MediaUtil();

  // 响应式变量
  final Rx<JourneyModel?> journey = Rx<JourneyModel?>(null);
  final RxList<MomentModel> moments = <MomentModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isRecording = false.obs;
  final RxDouble amplitude = (-60.0).obs;
  final RxString currentAddress = "正在获取位置信息...".obs;
  final RxBool isMapReadyInSheet = false.obs;

  // 接收从上个页面传来的行程 ID
  late String journeyId;

  // Getter 方法
  MediaUtil get mediaUtil => _mediaUtil;
  bool get isEnded => journey.value?.status == "ended";
  bool get hasMoments => moments.isNotEmpty;
  LatLng? get currentPos => _mapController.currentPos.value;

  @override
  void onInit() {
    super.onInit();
    // 获取路由参数
    journeyId = Get.arguments ?? "";
    // 加载数据
    fetchData();
  }

  // 逻辑处理

  /// 获取行程及其关联的所有瞬间
  Future<void> fetchData() async {
    if (journeyId.isEmpty) return;
    isLoading.value = true;
    try {
      final journeyData = await _journeyService.getJourneyDetail(journeyId);
      if (journeyData != null) {
        journey.value = journeyData;
        await _fetchMomentsDetails(journeyData.moments);
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// 请求瞬间详情
  Future<void> _fetchMomentsDetails(List<String>? momentIds) async {
    if (momentIds == null || momentIds.isEmpty) return;
    moments.clear();
    // 目前循环请求，未来考虑异步并发，或由后端提供批量请求接口
    for (String id in momentIds) {
      final detail = await _momentService.getMomentDetail(id);
      if (detail != null) moments.add(detail);
    }
    moments.sort((a, b) => a.time.compareTo(b.time)); // 按时间正序排列，最新的在最下
  }

  void goToNotePage() {
    Get.toNamed('/note', arguments: journeyId);
  }

  /// 结束行程
  Future<void> onEndJourney() async {
    final success = await _journeyService.endJourney(journeyId);
    if (success) {
      _mapController.stopJourney();
      await fetchData(); // 刷新页面状态
      Get.snackbar("行程结束", "您可以点击右上角生成 AI 游记了");
    }
  }

  /// 处理图片上传
  Future<void> onUploadImage(ImageSource source) async {
    bool hasPermission = source == ImageSource.camera
        ? await PermissionUtil.requestCamera()
        : await PermissionUtil.requestPhotos();
    if (!hasPermission) return;

    String? path = await _mediaUtil.pickImage(source);
    if (path == null) return;

    _processUpload(
      type: "image",
      filePath: path,
      title: source == ImageSource.camera ? "现场实拍" : "相册导入",
    );
  }

  /// 处理音频上传
  Future<void> onUploadAudio(String filePath) async {
    _processUpload(type: "audio", filePath: filePath, title: "语音胶囊");
  }

  /// 处理文本上传
  Future<void> onUploadText(String content) async {
    _processUpload(type: "text", context: content, title: "心情随笔");
  }

  /// 处理位置标记点上传
  Future<void> onUploadLocationMark() async {
    _processUpload(type: "location", title: "打卡记录");
  }

  /// 统一瞬间上传方法
  Future<void> _processUpload({
    required String type,
    String? filePath,
    String? context,
    String? title,
  }) async {
    // 获取位置信息
    final pos = _mapController.currentPos.value;
    if (pos == null) {
      Get.snackbar("提示", "尚未获取到位置信号，无法将位置信息挂载到瞬间");
      return;
    }

    // Loading 动画
    _showLoading();

    // 请求逆地理编码，更新位置信息
    final geo = await _contextService.getGeoInfo(pos.latitude, pos.longitude);
    if (geo != null) {
      // 地址格式：上海市 · 黄浦区 · 外滩
      currentAddress.value =
          "${geo.city} · ${geo.district} · ${geo.name ?? geo.address ?? ''}";
    } else {
      currentAddress.value = "未知地点";
    }

    final newMoment = await _momentService.uploadMoment(
      journeyId: journeyId,
      type: type,
      lat: pos.latitude.toString(),
      lon: pos.longitude.toString(),
      filePath: filePath,
      context: context,
      title: title,
      locationName: currentAddress.value,
    );

    Get.back(); // 隐藏 Loading
    if (newMoment != null) {
      moments.insert(0, newMoment);
      Get.snackbar("成功", "瞬间已成功存入行程");
    }
  }

  void _showLoading() {
    Get.dialog(
      const Center(child: CircularProgressIndicator(color: Colors.white)),
      barrierDismissible: false,
    );
  }

  Future<void> prepareLocationMark() async {
    isMapReadyInSheet.value = false;
    currentAddress.value = "正在定位...";

    final pos = _mapController.currentPos.value;
    if (pos == null) return;

    Future.delayed(
      const Duration(milliseconds: 400),
      () => isMapReadyInSheet.value = true,
    );

    // 请求逆地理编码
    final geo = await _contextService.getGeoInfo(pos.latitude, pos.longitude);
    if (geo != null) {
      // 地址格式：上海市 · 黄浦区 · 外滩
      currentAddress.value =
          "${geo.city} · ${geo.district} · ${geo.name ?? geo.address ?? ''}";
    } else {
      currentAddress.value = "未知地点";
    }
  }

  Future<void> setAsJourneyCover(String imageUrl) async {
    if (journey.value == null) return;

    // 显示加载中
    _showLoading();

    try {
      // 调用更新接口
      final updatedJourney = await _journeyService.updateJourney(
        journeyId,
        cover: imageUrl,
      );

      Get.back(); // 关闭 Loading

      if (updatedJourney != null) {
        journey.value = updatedJourney;
        Get.snackbar("设置成功", "已将此瞬间设为行程封面");
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().loadRecentTrips();
        }
      } else {
        Get.snackbar("设置失败", "请稍后重试");
      }
    } catch (e) {
      Get.back();
      Get.snackbar("错误", "网络连接异常");
    }
  }

  /// 获取显示时长
  String get displayDuration {
    if (journey.value == null) return "00:00:00";

    // 如果行程已结束，计算固定的时间差
    if (isEnded) {
      DateTime start = DateTime.parse(journey.value!.startTime);
      DateTime end = DateTime.parse(journey.value!.endTime!);
      Duration diff = end.difference(start);
      return _formatDuration(diff);
    }

    // 如果行程进行中，使用计时器的值
    return _mapController.durationStr.value;
  }

  /// 格式化 Duration
  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String hours = twoDigits(d.inHours);
    String minutes = twoDigits(d.inMinutes.remainder(60));
    String seconds = twoDigits(d.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }
}
