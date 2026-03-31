import 'dart:async';

import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../core/utils/location_util.dart';
import '../core/utils/storage_util.dart';

class MapTraceController extends GetxController {
  // 响应式数据
  final RxList<LatLng> tracePoints = <LatLng>[].obs;
  final Rx<LatLng?> currentPos = Rx<LatLng?>(null);
  final RxBool isRecording = false.obs;
  final RxBool isInJourney = false.obs;
  final RxString currentJourneyId = "".obs;
  final Rx<DateTime?> startTime = Rx<DateTime?>(null); // 行程开始时间
  final RxString durationStr = "00:00:00".obs;

  Duration _serverTimeOffset = Duration.zero;
  StreamSubscription<Position>? _positionStream;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _startLocationListening();
  }

  /// 开启持续定位监听
  void _startLocationListening() async {
    if (_positionStream != null) return;

    bool hasPermission = await LocationUtil.checkPermission();
    if (!hasPermission) return;

    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: LocationUtil.getLocationSettings(),
        ).listen((Position position) {
          LatLng point = LatLng(position.latitude, position.longitude);

          // 更新当前全局坐标
          currentPos.value = point;

          // 如果正在录制，则追加点到轨迹
          if (isRecording.value) {
            tracePoints.add(point);
          }
        });
  }

  /// 开始行程录制
  void startJourney(String id, {DateTime? time, bool withOffset = false}) {
    tracePoints.clear();
    isRecording.value = true;
    isInJourney.value = true;
    currentJourneyId.value = id;

    if (withOffset) {
      if (time != null) {
        startTime.value = time;
        _serverTimeOffset = time.difference(DateTime.now());
      } else {
        startTime.value = DateTime.now();
        _serverTimeOffset = Duration.zero;
      }
    } else {
      startTime.value = time ?? DateTime.now();
      _serverTimeOffset = Duration.zero;
    }

    _startTimer();

    StorageUtil.setJourneyId(id);
  }

  /// 结束行程录制
  void stopJourney() {
    isRecording.value = false;
    isInJourney.value = false;
    currentJourneyId.value = "";

    // 停止并清理计时器
    _timer?.cancel();
    _timer = null;
    durationStr.value = "00:00:00";
    startTime.value = null;

    StorageUtil.removeJourneyId();
  }

  @override
  void onClose() {
    _positionStream?.cancel();
    _timer?.cancel();
    super.onClose();
  }

  void _startTimer() {
    _timer?.cancel(); // 确保没有重复的计时器
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateDuration();
    });
  }

  /// 计算并更新时长字符串
  void _updateDuration() {
    if (startTime.value == null) return;

    final now = DateTime.now();
    final calibratedNow = now.add(_serverTimeOffset);
    final difference = calibratedNow.difference(startTime.value!);

    // 防止因为微小的误差出现负数显示
    if (difference.isNegative) {
      durationStr.value = "00:00:00";
      return;
    }

    // 格式化为 HH:mm:ss
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String hours = twoDigits(difference.inHours);
    String minutes = twoDigits(difference.inMinutes.remainder(60));
    String seconds = twoDigits(difference.inSeconds.remainder(60));

    durationStr.value = "$hours:$minutes:$seconds";
  }
}
