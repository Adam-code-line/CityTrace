import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "关于我们",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 50),

            // 1. Logo 区域
            Center(
              child: Image.asset(
                'assets/images/citytrace app.jpg',
                width: 180,
                height: 180,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.map_rounded,
                    color: Color(0xFF009688),
                    size: 100,
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "留下你的城市印记",
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                letterSpacing: 0.5,
              ),
            ),

            const Spacer(), // 自动推开间距
            // 2. 项目介绍
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  _buildSloganLine("AI 无界，创见未来。"),
                  const SizedBox(height: 8), // 两行之间的间距
                  _buildSloganLine("CityTrace 陪你深入城市肌理，"),
                  const SizedBox(height: 8),
                  _buildSloganLine("把瞬间凝结成永恒。"),
                ],
              ),
            ),

            const Spacer(),

            // 3. 底部信息
            _buildFooterSection(),

            const SizedBox(height: 40),
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
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF009688), // 使用 CityTrace 主题色
        letterSpacing: 1.2,
        height: 1.5,
      ),
    );
  }

  Widget _buildFooterSection() {
    return const Column(
      children: [
        Text(
          "版本号: 1.0.0",
          style: TextStyle(color: Colors.black45, fontSize: 13),
        ),
        SizedBox(height: 15),
        Text(
          "Copyright © TraceMakers 迹录者",
          style: TextStyle(color: Colors.black38, fontSize: 12),
        ),
        Text(
          "All Rights Reserved",
          style: TextStyle(color: Colors.black26, fontSize: 11),
        ),
      ],
    );
  }
}
