part of 'journey_detail_page.dart';

class MomentBottomSheet {
  /// 统一的弹出方法入口
  static void _show({
    required String title,
    required Widget child,
    bool isScrollControlled = true,
  }) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 统一的标题行
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close, size: 20.r),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            // 业务具体的内容
            child,
            SizedBox(height: 12.h),
          ],
        ),
      ),
      isScrollControlled: isScrollControlled,
    );
  }

  /// 动作按钮
  static Widget _buildActionButton(
    String text,
    VoidCallback? onPressed, {
    bool isEnabled = true,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled
              ? AppColors.primary
              : Colors.grey.shade300,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  static void showTextEditor(JourneyDetailController controller) {
    final textController = TextEditingController();
    _show(
      title: "记录此刻感悟",
      child: Column(
        children: [
          TextField(
            controller: textController,
            maxLines: 5,
            autofocus: true,
            decoration: InputDecoration(
              hintText: "写点什么吧...",
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          _buildActionButton("保存瞬间", () {
            controller.onUploadText(textController.text);
            Get.back();
          }),
        ],
      ),
    );
  }

  static void showImagePicker(JourneyDetailController controller) {
    final Rx<ImageSource?> selectedSource = Rx<ImageSource?>(null);

    _show(
      title: "记录这一刻的光影",
      child: Column(
        children: [
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: _buildSelectableCard(
                    icon: Icons.camera_alt_rounded,
                    label: "现场拍照",
                    isSelected: selectedSource.value == ImageSource.camera,
                    onTap: () => selectedSource.value = ImageSource.camera,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildSelectableCard(
                    icon: Icons.photo_library_rounded,
                    label: "从相册选",
                    isSelected: selectedSource.value == ImageSource.gallery,
                    onTap: () => selectedSource.value = ImageSource.gallery,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 32.h),
          Obx(
            () => _buildActionButton(
              "进入记录",
              selectedSource.value == null
                  ? null
                  : () {
                      Get.back();
                      controller.onUploadImage(selectedSource.value!);
                    },
              isEnabled: selectedSource.value != null,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildSelectableCard({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 24.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryOpacity005
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2.w,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32.r,
              color: isSelected ? AppColors.primary : Colors.grey,
            ),
            SizedBox(height: 12.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void showAudioRecorder(JourneyDetailController controller) {
    final mediaUtil = controller.mediaUtil;

    final RxBool isRecording = false.obs;
    final RxBool isFinished = false.obs;

    String? audioPath;

    Get.bottomSheet(
      Obx(
        () => PopScope(
          canPop: !isRecording.value,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isRecording.value ? "正在记录您的感悟" : "记录现在的声音",
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (!isRecording.value) {
                          Get.back();
                        }
                      },
                      icon: Icon(Icons.close, size: 20.r),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  isRecording.value
                      ? "AI 正在倾听..."
                      : (isFinished.value ? "录制完成，点击识别" : "准备好了吗？"),
                  style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                ),

                SizedBox(height: 48.h),

                GestureDetector(
                  onTap: () async {
                    if (!isRecording.value) {
                      bool hasPermission =
                          await PermissionUtil.requestMicrophone();
                      if (!hasPermission) return;

                      await mediaUtil.startRecording();
                      isRecording.value = true;
                      isFinished.value = false;
                    } else {
                      audioPath = await mediaUtil.stopRecording();
                      isRecording.value = false;
                      isFinished.value = true;
                    }
                  },
                  child: _buildMicAnimation(mediaUtil, isRecording.value),
                ),

                SizedBox(height: 48.h),

                _buildActionButton(
                  isFinished.value ? "开始 AI 识别" : "等待录音",
                  isFinished.value
                      ? () {
                          Get.back();
                          if (audioPath != null) {
                            controller.onUploadAudio(audioPath!);
                          }
                        }
                      : null,
                  isEnabled: isFinished.value,
                ),
              ],
            ),
          ),
        ),
      ),
      isDismissible: true,
      enableDrag: false,
    );
  }

  static Widget _buildMicAnimation(MediaUtil mediaUtil, bool active) {
    return StreamBuilder(
      stream: active ? mediaUtil.getAmplitudeStream() : null,
      builder: (context, snapshot) {
        double amp = (snapshot.data?.current ?? -60.0).clamp(-60.0, 0.0);
        double pulseScale = 1.0 + (active ? (amp + 60) / 100 : 0.0);

        return SizedBox(
          width: 140.w,
          height: 140.h,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              AnimatedScale(
                scale: pulseScale,
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeOutCubic,
                child: Container(
                  width: 110.w,
                  height: 110.h,
                  decoration: BoxDecoration(
                    color: (active ? AppColors.danger : AppColors.primary)
                        .withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 100.w,
                height: 100.h,
                decoration: BoxDecoration(
                  color: active ? AppColors.danger400 : AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (active ? AppColors.danger : AppColors.primary)
                          .withOpacity(0.3),
                      blurRadius: 20.r,
                      offset: Offset(0, 8.h),
                    ),
                  ],
                ),
                child: Icon(
                  active ? Icons.stop_rounded : Icons.mic_rounded,
                  color: Colors.white,
                  size: 48.r,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static void showLocationMarker(JourneyDetailController controller) {
    controller.prepareLocationMark();

    _show(
      title: "位置打卡",
      child: Column(
        children: [
          Container(
            height: 200.h,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Obx(() {
                if (!controller.isMapReadyInSheet.value ||
                    controller.currentPos == null) {
                  return Center(
                    child: CircularProgressIndicator(strokeWidth: 2.r),
                  );
                }

                return IgnorePointer(
                  child: MapView(
                    center: controller.currentPos,
                    points: const [],
                  ),
                );
              }),
            ),
          ),

          SizedBox(height: 20.h),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, color: AppColors.primary, size: 20.r),
                SizedBox(width: 12.w),
                Expanded(
                  child: Obx(
                    () => Text(
                      controller.currentAddress.value,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 32.h),

          _buildActionButton("确认打卡", () {
            Get.back();
            controller.onUploadLocationMark();
          }),
        ],
      ),
    );
  }
}

class MomentCard {
  static Widget buildTypedContent(MomentModel moment) {
    switch (moment.type) {
      case "image":
        return _buildImageContent(moment);
      case "audio":
        return _buildAudioContent(moment);
      case "text":
        return _buildTextContent(moment);
      case "location":
        return _buildLocationContent(moment);
      default:
        return const SizedBox();
    }
  }

  static Widget _buildImageContent(MomentModel moment) {
    final controller = Get.find<JourneyDetailController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onLongPress: () => _showImageOptions(controller, moment.media!),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.network(
              moment.media!,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (c, e, s) => Container(
                height: 150.h,
                color: Colors.grey.shade100,
                child: const Icon(
                  Icons.broken_image_outlined,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ),
        if (moment.mediaDescription != null) ...[
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: AppColors.primaryOpacity005,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.primaryOpacity010,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("✨", style: TextStyle(fontSize: 14.sp)),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    moment.mediaDescription!,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.teal.shade800,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  static Widget _buildAudioContent(MomentModel moment) {
    if (moment.media == null || moment.media!.isEmpty) {
      return const Text("音频加载失败", style: TextStyle(color: Colors.grey));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AudioMomentPlayer(url: moment.media!),
        if (moment.mediaDescription != null &&
            moment.mediaDescription!.isNotEmpty) ...[
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: AppColors.primaryOpacity005,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.primaryOpacity010,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("✨", style: TextStyle(fontSize: 14.sp)),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    moment.mediaDescription!,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.teal.shade800,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  static Widget _buildTextContent(MomentModel moment) {
    return Text(
      moment.context ?? "",
      style: TextStyle(
        fontSize: 15.sp,
        height: 1.6,
        color: Colors.black87,
        letterSpacing: 0.2,
      ),
    );
  }

  static Widget _buildLocationContent(MomentModel moment) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.location_on, color: Colors.blue, size: 24.r),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                moment.location.name ?? "未知地点",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp),
              ),
              SizedBox(height: 2.h),
              Text(
                "${moment.location.lat}, ${moment.location.lon}",
                style: TextStyle(fontSize: 11.sp, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static void _showImageOptions(
    JourneyDetailController controller,
    String imageUrl,
  ) {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text("设为行程封面"),
              onTap: () {
                Get.back();
                controller.setAsJourneyCover(imageUrl);
              },
            ),
            ListTile(
              leading: const Icon(Icons.download_outlined),
              title: const Text("保存图片到相册"),
              onTap: () {
                Get.back();
                Get.snackbar("提示", "正在开发中...");
              },
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}

class AudioMomentPlayer extends StatefulWidget {
  final String url;
  const AudioMomentPlayer({super.key, required this.url});

  @override
  State<AudioMomentPlayer> createState() => _AudioMomentPlayerState();
}

class _AudioMomentPlayerState extends State<AudioMomentPlayer> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _hasError = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _isPlaying = state == PlayerState.playing);
      }
    });

    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          _duration = newDuration;
          print("Now Duration:$_duration");
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) setState(() => _position = newPosition);
    });

    _audioPlayer.onLog.listen((msg) {
      if (msg.contains("error")) {
        _handleError();
      }
    });
  }

  void _handleError() {
    if (mounted) {
      setState(() {
        _hasError = true;
        _isLoading = false;
        _isPlaying = false;
      });
      Get.snackbar(
        "播放失败",
        "无法加载音频资源",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _togglePlay() async {
    if (_hasError) {
      setState(() => _hasError = false);
      setState(() => _isPlaying = false);
    }

    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        setState(() => _isLoading = true);
        await _audioPlayer
            .play(UrlSource(widget.url))
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () => throw TimeoutException("连接超时"),
            );
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _handleError();
      debugPrint("音频播放出错: $e");
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    Widget playIcon;
    if (_hasError) {
      playIcon = Icon(Icons.error_outline, color: Colors.red, size: 32.r);
    } else if (_isLoading) {
      playIcon = SizedBox(
        width: 32.w,
        height: 32.w,
        child: Padding(
          padding: EdgeInsets.all(4.r),
          child: CircularProgressIndicator(
            strokeWidth: 2.r,
            color: Colors.orange,
          ),
        ),
      );
    } else {
      playIcon = Icon(
        _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
        color: Colors.orange,
        size: 32.r,
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: _hasError ? Colors.red.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          GestureDetector(onTap: _togglePlay, child: playIcon),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _hasError ? "资源加载失败" : "录音",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: _hasError ? Colors.red : Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: List.generate(15, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(right: 2.w),
                      width: 3.w,
                      height: _isPlaying
                          ? (index % 3 + 2) * (index.isEven ? 2.0 : 4.0)
                          : (index % 3 + 2) * 3.0,
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(
                          _isPlaying ? 0.8 : 0.4,
                        ),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          Text(
            _hasError
                ? "--:--"
                : _isPlaying
                ? _formatDuration(_position)
                : (_duration == Duration.zero
                      ? "00:00"
                      : _formatDuration(_duration)),
            style: TextStyle(
              fontSize: 12.sp,
              color: _hasError ? Colors.grey : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}