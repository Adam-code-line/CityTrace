import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../services/ai_service.dart';

class NoteController extends GetxController {
  final AIService _aiService = AIService();

  // 接收参数
  late String journeyId;

  // --- 响应式变量 ---
  final RxString selectedStyle = "moments".obs; // 默认：朋友圈风格
  final RxString customPrompt = "".obs;
  final RxString generatedTitle = "".obs;
  final RxString generatedBody = "".obs;
  final RxList<String> hashtags = <String>[].obs;
  final RxBool isGenerating = false.obs;
  final RxBool isEditing = false.obs; // 是否处于编辑模式

  // 用于流式打字机效果 -- 界面上实际绑定的内容
  final RxString displayedTitle = "".obs;
  final RxString displayedBody = "".obs;

  // 用于编辑的 TextEditingController
  late TextEditingController titleEditController;
  late TextEditingController bodyEditController;

  // 内部流式控制
  Timer? _typeTimer;

  // 预设风格选项 (对应 API 文档)
  final List<Map<String, String>> styleOptions = [
    {"id": "moments", "name": "文艺朋友圈", "desc": "优美、抒情，充满意境"},
    {"id": "command", "name": "小📕种草", "desc": "活泼、推荐，自带emoji"},
    {"id": "diary", "name": "个人随笔", "desc": "简洁、客观，记录真实"},
    {"id": "custom", "name": "自定义风格", "desc": "输入你想要的语调"},
  ];

  @override
  void onInit() {
    super.onInit();
    journeyId = Get.arguments ?? "";
    titleEditController = TextEditingController();
    bodyEditController = TextEditingController();
  }

  @override
  void onClose() {
    _typeTimer?.cancel();
    titleEditController.dispose();
    bodyEditController.dispose();
    super.onClose();
  }

  /// 执行生成逻辑
  Future<void> startGenerating() async {
    if (journeyId.isEmpty) return;

    if (selectedStyle.value == "custom" && customPrompt.value.trim().isEmpty) {
      Get.snackbar("提示", "请输入您想要的风格描述");
      return;
    }

    isGenerating.value = true;
    // 重置显示内容
    displayedTitle.value = "";
    displayedBody.value = "";
    hashtags.clear();

    final result = await _aiService.generateNote(
      journeyId: journeyId,
      style: selectedStyle.value,
      prompt: selectedStyle.value == "custom" ? customPrompt.value : null,
    );

    if (result != null) {
      generatedTitle.value = result['title'] ?? "未命名旅程";
      generatedBody.value = result['body'] ?? "";
      if (result['tags'] != null) {
        hashtags.value = List<String>.from(result['tags']);
      }
      // 开始打字机效果
      _startTypingEffect();
    } else {
      // API 失败，恢复非生成状态
      isGenerating.value = false;
    }
  }

  /// 流式打字机效果：逐字将 generatedBody 展示到 displayedBody
  void _startTypingEffect() {
    _typeTimer?.cancel();

    // 先瞬间显示标题（标题短，无需逐字）
    displayedTitle.value = generatedTitle.value;

    final String fullBody = generatedBody.value;
    if (fullBody.isEmpty) {
      isGenerating.value = false;
      return;
    }

    int charIndex = 0;
    const int charsPerTick = 3; // 每次添加 3 个字符，模拟流式速度
    const Duration tickDuration = Duration(milliseconds: 30);

    _typeTimer = Timer.periodic(tickDuration, (timer) {
      if (charIndex >= fullBody.length) {
        timer.cancel();
        _typeTimer = null;
        isGenerating.value = false;
        return;
      }

      int endIndex = charIndex + charsPerTick;
      if (endIndex > fullBody.length) {
        endIndex = fullBody.length;
      }
      displayedBody.value = fullBody.substring(0, endIndex);
      charIndex = endIndex;
    });
  }

  /// 进入编辑模式
  void enterEditMode() {
    titleEditController.text = displayedTitle.value;
    bodyEditController.text = displayedBody.value;
    isEditing.value = true;
    // 停止正在进行的打字机效果
    _typeTimer?.cancel();
    _typeTimer = null;
    // 将完整内容直接显示
    displayedTitle.value = generatedTitle.value;
    displayedBody.value = generatedBody.value;
  }

  void saveEdits() {
    generatedTitle.value = titleEditController.text;
    generatedBody.value = bodyEditController.text;
    displayedTitle.value = titleEditController.text;
    displayedBody.value = bodyEditController.text;
    isEditing.value = false;
  }

  /// 分享逻辑：复制到剪贴板
  void shareToClipboard() {
    String shareText =
        "${generatedTitle.value}\n\n"
        "${generatedBody.value}\n\n"
        "${hashtags.map((e) => "#$e").join(" ")}";

    Clipboard.setData(ClipboardData(text: shareText)).then((_) {
      Get.snackbar(
        "已复制",
        "文案已复制到剪贴板，去社交平台分享吧！",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
    });
  }
}