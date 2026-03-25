import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'profile_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // 顶部背景区域和头像（头像在最上层）
          SliverToBoxAdapter(child: _buildHeaderWithAvatarSection()),
          // 统计数据卡片
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0), // 增加顶部间距
              child: _buildStatsCard(),
            ),
          ),
          // 功能列表
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: _buildFunctionList(),
            ),
          ),
          // 退出登录按钮
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: _buildSignOutButton(),
            ),
          ),
          // 底部空白区域
          const SliverToBoxAdapter(child: SizedBox(height: 60)),
        ],
      ),
    );
  }

  /// 顶部背景区域和头像（头像在最上层）
  Widget _buildHeaderWithAvatarSection() {
    final controller = Get.find<ProfileController>();

    return Obx(() {
      final user = controller.currentUser;

      return Container(
        width: double.infinity,
        height: 250, // 总高度包含背景和头像区域
        child: Stack(
          children: [
            // 背景区域（在底层）
            Container(
              width: double.infinity,
              height: 200, // 背景高度
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF00695C), // 深绿色
                    const Color(0xFF004D40), // 更深的绿色
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // 装饰性图案
                  Positioned(
                    bottom: -20,
                    right: -20,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 30,
                    left: -50,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                  // 用户昵称在右下角
                  Positioned(
                    bottom: 10,
                    right: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          user?.username ?? "探索者",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 8,
                                color: Colors.black26,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                        // 修改个人信息按钮
                        GestureDetector(
                          onTap: () {
                            _showEditProfileDialog();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              "修改个人信息",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.8),
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // 用户头像（在最上层，覆盖在背景上）
            Positioned(
              top: 140, // 头像底部与背景底部对齐
              left: 24,
              child: GestureDetector(
                onTap: () {
                  final controller = Get.find<ProfileController>();
                  controller.updateAvatar();
                },
                child: Container(
                  width: 95,
                  height: 95,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: Colors.white,
                        backgroundImage: NetworkImage(
                          user?.avatar ??
                              "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png",
                        ),
                      ),
                      // 头像编辑图标
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFF009688),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // 返回按钮（左上角）
            Positioned(
              top: 50,
              left: 16,
              child: GestureDetector(
                onTap: () {
                  Get.back(); // 返回上级页面
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(120, 192, 192, 192),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 20,
                    color: Color(0xFF00695C),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  /// 统计数据卡片
  Widget _buildStatsCard() {
    final controller = Get.find<ProfileController>();

    return Obx(() {
      if (controller.isLoadingStats.value) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: CircularProgressIndicator(color: Color(0xFF009688)),
          ),
        );
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF00695C), // 深绿色
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00695C).withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(
                  "总里程",
                  "${(controller.totalMileage.value / 1000).toStringAsFixed(2)} km",
                  Icons.map_outlined,
                ),
                // 第一条竖线分割线
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withOpacity(0.3),
                ),
                _buildStatItem(
                  "足迹点",
                  "${controller.totalPoints.value} 个",
                  Icons.location_on_outlined,
                ),
                // 第二条竖线分割线
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withOpacity(0.3),
                ),
                _buildStatItem(
                  "总时长",
                  _formatDurationToHours(controller.totalDuration.value),
                  Icons.timer_outlined,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  /// 将时长格式化为小时计
  String _formatDurationToHours(String durationString) {
    try {
      // 假设时长格式为 "X小时Y分钟" 或 "Y分钟"
      if (durationString.contains("小时")) {
        // 已经是小时格式，直接返回
        return durationString;
      } else if (durationString.contains("分钟")) {
        // 只有分钟，转换为小时
        final minutes =
            int.tryParse(durationString.replaceAll("分钟", "").trim()) ?? 0;
        final hours = minutes / 60;
        if (hours >= 1) {
          final remainingMinutes = minutes % 60;
          if (remainingMinutes > 0) {
            return "${hours.toInt()}小时${remainingMinutes}分钟";
          } else {
            return "${hours.toInt()}小时";
          }
        } else {
          return durationString; // 不足1小时保持原样
        }
      }
      return durationString;
    } catch (e) {
      return durationString; // 出错时返回原字符串
    }
  }

  /// 统计项
  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white70, size: 16), // 图标用次淡白色
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70, // 文字用次淡白色
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white, // 数据用白色
          ),
        ),
      ],
    );
  }

  /// 功能列表
  Widget _buildFunctionList() {
    return Column(
      children: [
        _buildFunctionItem(
          Icons.book_outlined,
          "我的游记",
          "查看和管理AI生成的游记",
          Icons.edit_outlined,
          () => Get.toNamed('/note'),
        ),
        const SizedBox(height: 16),
        _buildFunctionItem(
          Icons.favorite_outline,
          "收藏瞬间",
          "查看收藏的精彩瞬间",
          Icons.edit_outlined,
          () => Get.snackbar("提示", "功能开发中"),
        ),
      ],
    );
  }

  /// 功能项
  Widget _buildFunctionItem(
    IconData leftIcon,
    String title,
    String subtitle,
    IconData rightIcon,
    VoidCallback onTap,
  ) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
            decoration: const BoxDecoration(color: Colors.white),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF009688).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(leftIcon, color: const Color(0xFF009688)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(rightIcon, color: Colors.grey.shade400),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade300,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        // 下分割线
        Container(height: 1, color: Colors.grey.shade200),
      ],
    );
  }

  /// 显示修改个人信息对话框
  void _showEditProfileDialog() {
    final controller = Get.find<ProfileController>();
    final user = controller.currentUser;
    final TextEditingController usernameController = TextEditingController(
      text: user?.username ?? '',
    );

    Get.defaultDialog(
      title: "修改个人信息",
      content: Column(
        children: [
          const SizedBox(height: 16),
          TextField(
            controller: usernameController,
            decoration: const InputDecoration(
              labelText: "昵称",
              border: OutlineInputBorder(),
              hintText: "请输入新的昵称",
            ),
            maxLength: 20,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.black87,
                ),
                child: const Text("取消"),
              ),
              ElevatedButton(
                onPressed: () {
                  final newUsername = usernameController.text.trim();
                  if (newUsername.isEmpty) {
                    Get.snackbar("提示", "昵称不能为空");
                    return;
                  }
                  if (newUsername.length > 20) {
                    Get.snackbar("提示", "昵称不能超过20个字符");
                    return;
                  }

                  // 调用控制器更新昵称
                  controller.updateUsername(newUsername);
                  Get.back();
                  Get.snackbar("成功", "昵称修改成功");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00695C),
                  foregroundColor: Colors.white,
                ),
                child: const Text("保存"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 退出登录按钮
  Widget _buildSignOutButton() {
    final controller = Get.find<ProfileController>();

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          // 显示确认对话框
          Get.defaultDialog(
            title: "确认退出",
            middleText: "确定要退出登录吗？",
            textConfirm: "确定",
            textCancel: "取消",
            confirmTextColor: Colors.white,
            buttonColor: Colors.red,
            cancelTextColor: Colors.black54,
            onConfirm: () {
              controller.logout();
              Get.back();
            },
            onCancel: () {
              Get.back();
            },
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: Colors.red.withOpacity(0.3),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, size: 20),
            SizedBox(width: 8),
            Text(
              "Sign Out",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
