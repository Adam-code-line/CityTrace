import 'package:citytrace/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

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
          "帮助与反馈",
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
          // ============ 常见问题 ============
          _buildSectionTitle("常见问题"),
          SizedBox(height: 12.h),
          _buildQaItem(
            "如何开始一段行程？",
            "点击首页底部的「开始」按钮，确认当前位置后即可开始记录你的城市足迹。",
          ),
          _buildDivider(),
          _buildQaItem(
            "如何查看我的行程记录？",
            "在侧边菜单或个人主页中点击「全部行程」，即可查看所有历史记录。",
          ),
          _buildDivider(),
          _buildQaItem(
            "如何修改个人信息？",
            "进入个人主页，点击右上角的「修改个人信息」即可修改昵称和头像。",
          ),
          _buildDivider(),
          _buildQaItem(
            "行程数据会丢失吗？",
            "所有行程数据会同步至云端，更换设备后登录同一账号即可恢复数据。",
          ),

          SizedBox(height: 32.h),

          // ============ 联系我们 ============
          _buildSectionTitle("联系我们"),
          SizedBox(height: 12.h),
          _buildActionItem(
            icon: Icons.bug_report_outlined,
            title: "提交 Bug",
            subtitle: "在 GitHub 提交 Issue 反馈问题",
            onTap: () => _launchUrl("https://github.com/Limpid-8818/CityTrace/issues/new"),
          ),
          _buildDivider(),
          _buildActionItem(
            icon: Icons.lightbulb_outline,
            title: "功能建议",
            subtitle: "告诉我们你的想法和建议",
            onTap: () => _launchUrl("https://github.com/Limpid-8818/CityTrace/issues/new"),
          ),
          _buildDivider(),
          _buildActionItem(
            icon: Icons.code_outlined,
            title: "GitHub 仓库",
            subtitle: "查看项目源码及贡献代码",
            onTap: () => _launchUrl("https://github.com/Limpid-8818/CityTrace"),
          ),
          _buildDivider(),
          _buildActionItem(
            icon: Icons.mail_outline,
            title: "邮件联系",
            subtitle: "发送邮件至开发者邮箱",
            onTap: () => _launchUrl("mailto:limpid.dev@example.com"),
          ),

          SizedBox(height: 32.h),

          // ============ 关于应用 ============
          _buildSectionTitle("关于应用"),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: AppColors.primaryOpacity005,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColors.primaryOpacity015,
              ),
            ),
            child: Column(
              children: [
                Text(
                  "CityTrace",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "版本 1.0.0",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  "CityTrace 是一款记录城市足迹的应用，帮助你发现和记录在城市中的每一次探索。\n\n"
                  "如果你有任何问题或建议，欢迎在 GitHub 上提 Issue 或 Pull Request 参与项目贡献。",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black87,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
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

  Widget _buildQaItem(String question, String answer) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Q: ",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              Expanded(
                child: Text(
                  question,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "A: ",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500,
                ),
              ),
              Expanded(
                child: Text(
                  answer,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
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
            Icon(Icons.open_in_new, color: Colors.grey.shade300, size: 18.r),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 1.h, color: Colors.grey.shade200);
  }

  Future<void> _launchUrl(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      Get.snackbar("提示", "无法打开链接");
    }
  }
}