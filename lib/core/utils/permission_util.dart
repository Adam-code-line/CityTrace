import 'package:citytrace/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';

class PermissionUtil {
  /// 统一检查并请求权限方法
  /// [permission] 权限类型
  /// [label] 权限的中文名称，用于弹窗展示
  /// [reason] 为什么要这个权限的解释
  static Future<bool> checkAndRequest(
    Permission permission, {
    required String label,
    required String reason,
  }) async {
    // 检查当前状态
    PermissionStatus status = await permission.status;

    // 如果已经授权，直接返回 true
    if (status.isGranted || status.isLimited) return true;

    // 发起请求
    PermissionStatus result = await permission.request();

    // 如果请求后允许
    if (result.isGranted || result.isLimited) {
      return true;
    }

    // 如果被永久拒绝，引导到设置页
    if (result.isPermanentlyDenied) {
      _showGoSettingsDialog(label, reason);
      return false;
    }

    // 如果仅本次拒绝，弹窗提醒
    if (result.isDenied) {
      Get.snackbar(
        "权限提醒",
        "由于您拒绝了$label权限，相关功能将无法使用",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        margin: const EdgeInsets.all(16),
      );
      return false;
    }

    return false;
  }

  /// 引导去系统设置的对话框
  static void _showGoSettingsDialog(String label, String reason) {
    Get.defaultDialog(
      title: "需要$label权限",
      middleText: "$reason\n\n请在系统设置中开启权限。",
      textConfirm: "去设置",
      textCancel: "取消",
      confirmTextColor: Colors.white,
      buttonColor: AppColors.primary,
      onConfirm: () {
        Get.back();
        openAppSettings();
      },
    );
  }

  // 具体权限请求方法

  /// 请求精确定位
  static Future<bool> requestLocation() => checkAndRequest(
    Permission.location,
    label: "定位",
    reason: "CityTrace需要获取您的实时坐标，以记录您的足迹。",
  );

  /// 请求相机
  static Future<bool> requestCamera() => checkAndRequest(
    Permission.camera,
    label: "相机",
    reason: "CityTrace需要获取访问您的相机的权限，以便您随时使用相机拍摄沿途风景。",
  );

  /// 请求麦克风
  static Future<bool> requestMicrophone() => checkAndRequest(
    Permission.microphone,
    label: "麦克风",
    reason: "CityTrace需要获取访问您的麦克风的权限，以便您记录当下的声音。",
  );

  /// 请求相册
  static Future<bool> requestPhotos() => checkAndRequest(
    Permission.photos,
    label: "相册",
    reason: "CityTrace需要获取访问您的相册的权限，以便您上传图片。",
  );
}
