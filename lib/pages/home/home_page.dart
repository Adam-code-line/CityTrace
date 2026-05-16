import 'dart:ui' as ui;
import 'package:citytrace/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../../components/map_view.dart';
import '../../components/ui/info_pill.dart';
import 'home_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Scaffold(
      key: controller.scaffoldKey,
      backgroundColor: AppColors.pageBackground,
      drawer: _buildLeftDrawer(), // 侧拉菜单
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12.h),
              _buildTopBar(), // Header
              SizedBox(height: 20.h),
              _buildWelcomeSection(), // 欢迎语
              SizedBox(height: 16.h),
              _buildContextSection(), // 环境信息
              SizedBox(height: 24.h),
              _buildHeroCard(), // 行程状态信息
              SizedBox(height: 32.h),
              _buildRecentTripsTitle(), // 最近行程标题
              SizedBox(height: 16.h),
              _buildRecentTripsSection(), // 最近行程信息
              SizedBox(height: 48.h), // 留出 FAB 空间，避免遮挡行程信息
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildMainFab(), // 底部 FAB
    );
  }

  Widget _buildLeftDrawer() {
    HomeController controller = Get.find<HomeController>();
    return Drawer(
      width: Get.width * 0.8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(32.r),
          bottomRight: Radius.circular(32.r),
        ),
      ),
      child: Column(
        children: [
          // 侧边栏头部：用户信息
          _buildDrawerHeader(),
          // 菜单列表
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              children: [
                _buildDrawerItem(
                  Icons.person_outline,
                  "个人主页",
                  () => controller.handleMenuClick('/profile'),
                ),
                _buildDrawerItem(
                  Icons.location_on_outlined,
                  "全部行程",
                  () => controller.handleMenuClick('/list'),
                ),
              //_buildDrawerItem(
              //  Icons.calendar_today_outlined,
              //  "行程计划",
              //  () => controller.handleMenuClick('/plans'),
              // ),
              // _buildDrawerItem(
              //  Icons.favorite_outline,
              //  "我的收藏",
              //  () => controller.handleMenuClick('/favorites'),
              // ),
              // _buildDrawerItem(
              //  Icons.share_outlined,
              //  "分享动态",
              //  () => controller.handleMenuClick('/share'),
              //),  
              ],
            ),
          ),
          // 底部退出按钮
          const Divider(),
          _buildDrawerItem(
            Icons.logout,
            "退出登录",
            () => controller.logout(),
            color: Colors.red,
          ),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    HomeController controller = Get.find<HomeController>();
    return Obx(() {
      // 预设默认头像地址
      const String defaultAvatar =
          "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png";

      // 获取当前的头像地址，如果是 null 或空字符串则使用默认图
      String? avatarUrl = controller.currentUser?.avatar;
      bool hasValidAvatar = avatarUrl != null && avatarUrl.isNotEmpty;

      return Container(
        padding: EdgeInsets.fromLTRB(24.w, 80.h, 24.w, 32.h),
        color: AppColors.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 36.r,
                  backgroundColor: Colors.white24,
                  backgroundImage: NetworkImage(
                    hasValidAvatar ? avatarUrl : defaultAvatar,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.currentUser?.username ?? "探索者",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "ID: ${controller.currentUser?.userId ?? "CityTracer"}",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
          ],
        ),
      );
    });
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.black87),
      title: Text(
        title,
        style: TextStyle(color: color ?? Colors.black87, fontSize: 16.sp),
      ),
      trailing: Icon(Icons.chevron_right, size: 20.r),
      onTap: onTap,
    );
  }

  Widget _buildTopBar() {
    HomeController controller = Get.find<HomeController>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => controller.handleAvatarClick(),
          child: Obx(
            () => Row(
              children: [
                CircleAvatar(
                  radius: 24.r,
                  backgroundImage: NetworkImage(
                    controller.currentUser?.avatar ??
                        "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png",
                  ),
                ),
                if (!controller.isLoggedIn) ...[
                  SizedBox(width: 12.w),
                  Text(
                    "未登录",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_horiz, color: Colors.black54),
          offset: Offset(0, 50.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          onSelected: (value) {
            if (value == 'about') {
              Get.toNamed('/about');
            } else if (value == 'settings') {
              Get.toNamed('/setting');
            } else if (value == 'help') {
              Get.toNamed('/help');
            } else {
              Fluttertoast.showToast(msg: "点击了 $value");
            }
          },
          itemBuilder: (context) => [
            _buildPopupItem("设置", Icons.settings_outlined, "settings"),
            _buildPopupItem("帮助与反馈", Icons.help_outline, "help"),
            _buildPopupItem("关于我们", Icons.info_outline, "about"),
          ],
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupItem(
    String title,
    IconData icon,
    String value,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20.r, color: Colors.black87),
          SizedBox(width: 12.w),
          Text(title),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    HomeController controller = Get.find<HomeController>();
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hi, ${controller.currentUser?.username ?? '探索者'}",
            style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold),
          ),
          Text(
            "今天准备去哪里留下印记？",
            style: TextStyle(fontSize: 18.sp, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildContextSection() {
    HomeController controller = Get.find<HomeController>();
    return Obx(
      () => Row(
        children: [
          InfoPill(
            icon: Icons.location_on_outlined,
            text: controller.locationDisplay.value,
          ),
          SizedBox(width: 10.w),
          InfoPill(
            icon: Icons.wb_cloudy_outlined,
            text: controller.weatherDisplay.value,
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    HomeController controller = Get.find<HomeController>();
    return Obx(() {
      bool showActive = controller.isInJourney;
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 800),
        child: showActive
            ? _buildActiveJourneyCard() // 行程中的卡片样式
            : _buildEmptyJourneyCard(), // 尚未开始行程卡片样式
      );
    });
  }

  Widget _buildActiveJourneyCard() {
    HomeController controller = Get.find<HomeController>();
    return Container(
      key: const ValueKey("active_card"),
      width: double.infinity,
      height: 240.h,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32.r),
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryOpacity030,
            blurRadius: 15.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "当前正在行程中",
            style: TextStyle(color: Colors.white70, fontSize: 16.sp),
          ),
          const Spacer(),
          Text(
            "漫游探索城市中...",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Obx(
            () => Text(
              "已持续：${controller.duration}",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14.sp,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => controller.handleJourneyCardClick(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                elevation: 0,
              ),
              child: const Text(
                "返回行程详情",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyJourneyCard() {
    return Container(
      key: const ValueKey("empty_card"),
      width: double.infinity,
      height: 240.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.tealAccent.shade100.withOpacity(0.5), Colors.white],
        ),
        border: Border.all(color: Colors.tealAccent.shade100.withOpacity(0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(Icons.map_outlined, color: Colors.white, size: 40.r),
          ),
          SizedBox(height: 16.h),
          Text(
            "尚未开始行程",
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 4.h),
          const Text("点击下方按钮并开始探索你的足迹", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildRecentTripsTitle() {
    return Text(
      "最近的旅程",
      style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildRecentTripsSection() {
    HomeController controller = Get.find<HomeController>();
    return Obx(() {
      // 未登录状态
      if (!controller.isLoggedIn) {
        return _buildRecentTripPlaceholder(
          Icons.lock_person_outlined,
          "请先登录查看最近行程",
        );
      }

      if (controller.isLoadingRecent.value) {
        return SizedBox(
          height: 150.h,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2.r)),
        );
      }

      // 已登录但无行程
      if (controller.recentTrips.isEmpty) {
        return _buildRecentTripPlaceholder(
          Icons.map_outlined,
          "暂无行程，快去开启一段旅程吧",
        );
      }

      // 最近行程展示
      return SizedBox(
        height: 220.h,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.recentTrips.length,
          itemBuilder: (context, index) =>
              _buildTripCard(controller.recentTrips[index]),
        ),
      );
    });
  }

  Widget _buildRecentTripPlaceholder(IconData icon, String label) {
    return SizedBox(
      width: double.infinity,
      height: 150.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40.r, color: Colors.grey.shade300),
          SizedBox(height: 12.h),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(Map<String, String> trip) {
    final String journeyId = trip['id'] ?? "";
    return GestureDetector(
      onTap: () => Get.toNamed('/journey', arguments: journeyId),
      child: Container(
        width: 140.w,
        margin: EdgeInsets.only(right: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: "journey_cover_$journeyId",
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Image.network(
                  trip['img']!,
                  height: 140.w,
                  width: 140.w,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) {
                    return Container(
                      height: 140,
                      width: 140,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey.shade300,
                        size: 40.r,
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 140.h,
                      width: 140.h,
                      color: Colors.grey.shade50,
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2.r),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              trip['title']!,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              trip['date']!,
              style: TextStyle(color: Colors.grey, fontSize: 12.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainFab() {
    HomeController controller = Get.find<HomeController>();
    return Obx(() {
      if (controller.isInJourney) {
        return Hero(
          tag: "journey_fab",
          child: Container(
            width: 48.r,
            height: 48.r,
            color: Colors.transparent,
          ),
        );
      }

      return Padding(
        padding: EdgeInsets.only(bottom: 40.h),
        child: SizedBox(
          width: 160.w,
          height: 48.h,
          child: ElevatedButton(
            onPressed: () {
              if (controller.isLoggedIn) {
                controller.startMapLoadingTimer();
                Get.bottomSheet(
                  _buildConfirmBottomSheet(),
                  isScrollControlled: true,
                );
              } else {
                controller.handleUnlogFabClick();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 6,
              shadowColor: AppColors.primaryOpacity040,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.r),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.play_arrow_rounded, size: 28.r),
                SizedBox(width: 6.w),
                Text(
                  "开始行程",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildConfirmBottomSheet() {
    HomeController controller = Get.find<HomeController>();
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "准备好出发了吗？",
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20.h),

          Container(
            height: 200.h,
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

                return ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: MapView(center: controller.currentPos),
                );
              }),
            ),
          ),

          SizedBox(height: 24.h),

          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton(
              onPressed: () => controller.onStartJourneyConfirmed(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                elevation: 0,
              ),
              child: Text(
                "立即出发",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }
}