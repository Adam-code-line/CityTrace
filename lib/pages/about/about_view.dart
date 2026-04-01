import 'package:citytrace/core/utils/metadata_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "关于我们",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20.r),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 50.h),

            // 1. Logo 区域
            Center(
              child: Image.asset(
                'assets/images/citytrace_app_icon.jpg',
                width: 180.w,
                height: 180.w,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.map_rounded,
                    color: Color(0xFF009688),
                    size: 100.r,
                  );
                },
              ),
            ),

            SizedBox(height: 10.h),

            Text(
              "留下你的城市印记",
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.grey,
                letterSpacing: 0.5,
              ),
            ),

            const Spacer(), // 自动推开间距
            // 2. 项目介绍
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w),
              child: Column(
                children: [
                  _buildSloganLine("AI 无界，创见未来。"),
                  SizedBox(height: 8.h), // 两行之间的间距
                  _buildSloganLine("CityTrace 陪你深入城市肌理，"),
                  SizedBox(height: 8.h),
                  _buildSloganLine("把瞬间凝结成永恒。"),
                ],
              ),
            ),

            const Spacer(),

            // 3. 底部信息
            _buildFooterSection(),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  // 辅助方法：构建居中的 Slogan 文本行
  Widget _buildSloganLine(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: Color(0xFF009688), // 使用 CityTrace 主题色
        letterSpacing: 1.2,
        height: 1.5,
      ),
    );
  }

  Widget _buildFooterSection() {
    return Column(
      children: [
        Text(
          "版本号: ${MetadataUtil.version}",
          style: TextStyle(color: Colors.black45, fontSize: 13.sp),
        ),
        SizedBox(height: 15.h),
        Text(
          "Copyright © TraceMakers 迹录者",
          style: TextStyle(color: Colors.black38, fontSize: 12.sp),
        ),
        Text(
          "All Rights Reserved",
          style: TextStyle(color: Colors.black26, fontSize: 11.sp),
        ),
      ],
    );
  }
}
