import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../../components/map_view.dart';
import 'home_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Scaffold(
      key: controller.scaffoldKey,
      backgroundColor: Colors.white,
      drawer: _buildLeftDrawer(), // 侧拉菜单
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _buildTopBar(), // Header
              const SizedBox(height: 20),
              _buildWelcomeSection(), // 欢迎语
              const SizedBox(height: 16),
              _buildContextSection(), // 环境信息
              const SizedBox(height: 24),
              _buildHeroCard(), // 行程状态信息
              const SizedBox(height: 32),
              _buildRecentTripsTitle(), // 最近行程标题
              const SizedBox(height: 16),
              _buildRecentTripsSection(), // 最近行程信息
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          // 侧边栏头部：用户信息
          _buildDrawerHeader(),
          // 菜单列表
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // _buildDrawerItem(
                //   Icons.person_outline,
                //   "个人主页",
                //   () => controller.handleMenuClick('/profile'),
                // ),
                _buildDrawerItem(
                  Icons.location_on_outlined,
                  "全部行程",
                  () => controller.handleMenuClick('/list'),
                ),
                // _buildDrawerItem(
                //   Icons.calendar_today_outlined,
                //   "行程计划",
                //   () => controller.handleMenuClick('/plans'),
                // ),
                // _buildDrawerItem(
                //   Icons.favorite_outline,
                //   "我的收藏",
                //   () => controller.handleMenuClick('/favorites'),
                // ),
                // _buildDrawerItem(
                //   Icons.share_outlined,
                //   "分享动态",
                //   () => controller.handleMenuClick('/share'),
                // ),
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
          const SizedBox(height: 32),
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
        padding: const EdgeInsets.fromLTRB(24, 80, 24, 32),
        color: const Color(0xFF009688),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white24,
                  backgroundImage: NetworkImage(
                    hasValidAvatar ? avatarUrl : defaultAvatar,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.currentUser?.username ?? "探索者",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "ID: ${controller.currentUser?.userId ?? "CityTracer"}",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
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
        style: TextStyle(color: color ?? Colors.black87, fontSize: 16),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20),
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
                  radius: 24,
                  backgroundImage: NetworkImage(
                    controller.currentUser?.avatar ??
                        "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png",
                  ),
                ),
                if (!controller.isLoggedIn) ...[
                  const SizedBox(width: 12),
                  const Text(
                    "未登录",
                    style: TextStyle(
                      fontSize: 18,
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
          offset: const Offset(0, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onSelected: (value) {
            if (value == 'about') {
              // 如果点击的是关于我们，就跳转
              Get.toNamed('/about');
            } else {
              // 其他项暂时还是弹个窗
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
          Icon(icon, size: 20, color: Colors.black87),
          const SizedBox(width: 12),
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
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const Text(
            "今天准备去哪里留下印记？",
            style: TextStyle(fontSize: 18, color: Colors.grey),
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
          const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
          const SizedBox(width: 4),
          Text(
            controller.locationDisplay.value,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(width: 16),
          const Icon(Icons.wb_cloudy_outlined, size: 18, color: Colors.grey),
          const SizedBox(width: 4),
          Text(
            controller.weatherDisplay.value,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
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
      height: 240,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: const Color(0xFF009688), // 使用主题色作为背景
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF009688).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "当前正在行程中",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const Spacer(),
          const Text(
            "漫游探索城市中...",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Obx(
            () => Text(
              "已持续：${controller.duration}",
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontFamily: 'monospace',
              ),
              // 使用 monospace 字体可以防止数字变动时文字左右跳动
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => controller.handleJourneyCardClick(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF009688),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
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
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF009688),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.map_outlined,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "尚未开始行程",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text("点击下方按钮并开始探索你的足迹", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildRecentTripsTitle() {
    return const Text(
      "最近的旅程",
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
        return const SizedBox(
          height: 150,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
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
        height: 220,
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
      height: 150,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
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
        width: 140,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: "journey_cover_$journeyId", // 确保 tag 全局唯一且两页一致
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  trip['img']!,
                  height: 140,
                  width: 140,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) {
                    return Container(
                      height: 140,
                      width: 140,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey.shade300,
                        size: 40,
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 140,
                      width: 140,
                      color: Colors.grey.shade50,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              trip['title']!,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 1, // 防止标题过长撑开布局
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              trip['date']!,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainFab() {
    HomeController controller = Get.find<HomeController>();
    return Obx(() {
      // 如果是行程中状态，不显示FAB（透明）
      if (controller.isInJourney) {
        return Hero(
          tag: "journey_fab",
          child: Container(
            width: 48,
            height: 48,
            color: Colors.transparent, // 透明
          ),
        );
      }

      return FloatingActionButton.large(
        heroTag: "journey_fab",
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
        backgroundColor: const Color(0xFF009688),
        shape: const CircleBorder(),
        child: const Icon(
          Icons.play_arrow_rounded,
          color: Colors.white,
          size: 48,
        ),
      );
    });
  }

  Widget _buildConfirmBottomSheet() {
    HomeController controller = Get.find<HomeController>();
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 弹窗高度自适应
        children: [
          const Text(
            "准备好出发了吗？",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // 弹窗内的地图预览区
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Obx(() {
                if (!controller.isMapReadyInSheet.value ||
                    controller.currentPos == null) {
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }

                return ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: MapView(center: controller.currentPos),
                );
              }),
            ),
          ),

          const SizedBox(height: 24),

          // 立即出发按钮
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => controller.onStartJourneyConfirmed(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF009688),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                "立即出发",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
