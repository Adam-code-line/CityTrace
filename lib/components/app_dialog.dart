import 'package:citytrace/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// 应用级通用对话框组件
/// 统一的 teal 主题风格，圆角设计

/// 带输入框的对话框
class AppInputDialog extends StatelessWidget {
  final String title;
  final IconData? icon;
  final String hintText;
  final String initialValue;
  final String confirmText;
  final Future<void> Function(String value)? onConfirm;
  final bool Function(String value)? validator;

  const AppInputDialog({
    super.key,
    required this.title,
    this.icon,
    this.hintText = "请输入名称",
    this.initialValue = "",
    this.confirmText = "确定",
    this.onConfirm,
    this.validator,
  });

  /// 快捷弹出输入对话框
  static Future<void> show({
    required String title,
    IconData? icon,
    String hintText = "请输入名称",
    String initialValue = "",
    String confirmText = "确定",
    Future<void> Function(String value)? onConfirm,
    bool Function(String value)? validator,
  }) {
    return Get.dialog(
      AppInputDialog(
        title: title,
        icon: icon,
        hintText: hintText,
        initialValue: initialValue,
        confirmText: confirmText,
        onConfirm: onConfirm,
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController(text: initialValue);
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题行
            if (icon != null) ...[
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: AppColors.primaryOpacity010,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      icon,
                      color: AppColors.primary,
                      size: 24.r,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
            ] else ...[
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),
            ],
            // 输入框
            TextField(
              controller: textController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14.sp,
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 14.h,
                ),
              ),
              style: TextStyle(fontSize: 15.sp),
              onSubmitted: (value) => _handleSubmit(value, context),
            ),
            SizedBox(height: 24.h),
            // 底部按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey,
                  ),
                  child: Text(
                    "取消",
                    style: TextStyle(fontSize: 15.sp),
                  ),
                ),
                SizedBox(width: 12.w),
                ElevatedButton(
                  onPressed: () => _handleSubmit(textController.text.trim(), context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                      horizontal: 28.w,
                      vertical: 14.h,
                    ),
                  ),
                  child: Text(
                    confirmText,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmit(String value, BuildContext context) {
    final name = value.trim();
    if (name.isEmpty) {
      Get.snackbar("提示", "请输入内容");
      return;
    }
    if (validator != null && !validator!(name)) {
      return;
    }
    if (onConfirm != null) {
      onConfirm!(name);
    }
    Get.back();
  }
}

/// 选项模型
class AppSheetAction {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const AppSheetAction({
    required this.icon,
    required this.label,
    this.color,
    required this.onTap,
  });
}

/// 应用级操作菜单 BottomSheet
class AppActionSheet extends StatelessWidget {
  final String title;
  final List<AppSheetAction> actions;

  const AppActionSheet({
    super.key,
    required this.title,
    required this.actions,
  });

  /// 快捷弹出操作菜单
  static Future<void> show({
    required String title,
    required List<AppSheetAction> actions,
  }) {
    return Get.bottomSheet(
      AppActionSheet(title: title, actions: actions),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖拽指示条
          Container(
            margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          // 标题
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Divider(height: 1.h, color: Colors.grey.shade200),
          ...actions.map((action) => _buildActionItem(action)),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  Widget _buildActionItem(AppSheetAction action) {
    return ListTile(
      leading: Icon(
        action.icon,
        color: action.color ?? Colors.black87,
        size: 22.r,
      ),
      title: Text(
        action.label,
        style: TextStyle(
          fontSize: 15.sp,
          color: action.color ?? Colors.black87,
        ),
      ),
      onTap: () {
        Get.back();
        action.onTap();
      },
    );
  }
}

/// 确认对话框
class AppConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final Color? confirmColor;
  final VoidCallback? onConfirm;

  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = "确定",
    this.cancelText = "取消",
    this.confirmColor,
    this.onConfirm,
  });

  /// 快捷弹出确认对话框
  static Future<void> show({
    required String title,
    required String message,
    String confirmText = "确定",
    String cancelText = "取消",
    Color? confirmColor,
    VoidCallback? onConfirm,
  }) {
    return Get.dialog(
      AppConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmColor: confirmColor,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 图标
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: (confirmColor ?? Colors.red).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: confirmColor ?? Colors.red,
                size: 32.r,
              ),
            ),
            SizedBox(height: 16.h),
            // 标题
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            // 消息
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 24.h),
            // 按钮
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: Text(
                      cancelText,
                      style: TextStyle(fontSize: 15.sp),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      onConfirm?.call();
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmColor ?? Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: Text(
                      confirmText,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}