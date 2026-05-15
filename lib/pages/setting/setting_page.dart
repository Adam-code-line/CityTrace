import 'package:citytrace/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.pageBackground,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            margin: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: const Color.fromARGB(120, 192, 192, 192),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20.r,
              color: AppColors.primaryDark,
            ),
          ),
        ),
        title: Text(
          "设置",
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        children: [
          // ============ 通用设置 ============
          _buildSectionTitle("通用"),
          SizedBox(height: 12.h),
          _buildSettingItem(
            icon: Icons.notifications_outlined,
            title: "消息通知",
            subtitle: "管理推送通知和提醒",
            trailing: Switch(
              value: true,
              activeColor: AppColors.primary,
              onChanged: (value) {
                Get.snackbar("提示", "消息通知设置已切换");
              },
            ),
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.language_outlined,
            title: "语言",
            subtitle: "中文（简体）",
            onTap: () {
              Get.snackbar("提示", "语言切换功能开发中");
            },
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.dark_mode_outlined,
            title: "深色模式",
            subtitle: "跟随系统设置",
            trailing: Switch(
              value: false,
              activeColor: AppColors.primary,
              onChanged: (value) {
                Get.snackbar("提示", "深色模式设置已切换");
              },
            ),
          ),

          SizedBox(height: 32.h),

          // ============ 隐私与安全 ============
          _buildSectionTitle("隐私与安全"),
          SizedBox(height: 12.h),
          _buildSettingItem(
            icon: Icons.lock_outline,
            title: "隐私设置",
            subtitle: "管理位置共享和个人信息",
            onTap: () {
              Get.snackbar("提示", "隐私设置功能开发中");
            },
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.map_outlined,
            title: "位置服务",
            subtitle: "应用使用位置信息的权限",
            trailing: Switch(
              value: true,
              activeColor: AppColors.primary,
              onChanged: (value) {
                Get.snackbar("提示", "位置服务设置已切换");
              },
            ),
          ),

          SizedBox(height: 32.h),

          // ============ 缓存与存储 ============
          _buildSectionTitle("缓存与存储"),
          SizedBox(height: 12.h),
          _buildSettingItem(
            icon: Icons.cleaning_services_outlined,
            title: "清除缓存",
            subtitle: "当前缓存大小: 128 MB",
            onTap: () {
              Get.defaultDialog(
                title: "清除缓存",
                middleText: "确定要清除所有缓存数据吗？",
                textConfirm: "确定",
                textCancel: "取消",
                confirmTextColor: Colors.white,
                buttonColor: AppColors.primary,
                onConfirm: () {
                  Get.back();
                  Get.snackbar("提示", "缓存已清除");
                },
              );
            },
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.download_outlined,
            title: "离线地图管理",
            subtitle: "已下载 0 个城市地图",
            onTap: () {
              Get.snackbar("提示", "离线地图管理功能开发中");
            },
          ),

          SizedBox(height: 32.h),

          // ============ 其他 ============
          _buildSectionTitle("其他"),
          SizedBox(height: 12.h),
          _buildSettingItem(
            icon: Icons.info_outline,
            title: "关于应用",
            subtitle: "版本 1.0.0",
            onTap: () {
              Get.toNamed('/about');
            },
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.description_outlined,
            title: "用户协议",
            subtitle: "查看服务条款和隐私政策",
            onTap: () {
              Get.snackbar("提示", "用户协议功能开发中");
            },
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.star_outline,
            title: "给我们评分",
            subtitle: "在应用商店给我们好评",
            onTap: () {
              Get.snackbar("提示", "评分功能开发中");
            },
          ),

          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: AppColors.primaryOpacity010,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22.r),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
            if (onTap != null && trailing == null)
              Icon(Icons.chevron_right, color: Colors.grey.shade300, size: 24.r),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 1.h, color: Colors.grey.shade200);
  }
}