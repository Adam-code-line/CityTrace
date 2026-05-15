import 'package:citytrace/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'login_controller.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 注入控制器
    final controller = Get.put(LoginController());

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(backgroundColor: AppColors.pageBackground, elevation: 0),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(32.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            // 标题
            Obx(
              () => Text(
                controller.isLogin.value ? "欢迎回来" : "加入城市寻迹",
                style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "用AI丈量城市，让记忆自动成书",
              style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
            ),
            SizedBox(height: 48.h),

            // 表单区域
            Form(
              child: Column(
                children: [
                  // 注册模式下显示用户名输入框
                  Obx(
                    () => controller.isLogin.value
                        ? const SizedBox.shrink()
                        : _buildTextField(
                            controller: controller.usernameController,
                            hint: "用户名",
                            icon: Icons.person_outline,
                            validator: (value) => controller.validateUsername(),
                          ),
                  ),
                  SizedBox(height: 16.h),
                  _buildTextField(
                    controller: controller.accountController,
                    hint: "账号 / 手机号",
                    icon: Icons.alternate_email,
                    validator: (value) => controller.validateAccount(),
                  ),
                  SizedBox(height: 16.h),
                  Obx(
                    () => _buildTextField(
                      controller: controller.passwordController,
                      hint: "密码",
                      icon: Icons.lock_outline,
                      isPassword: true,
                      obscureText: controller.obscureText.value,
                      onSuffixIconPressed: () =>
                          controller.obscureText.toggle(),
                      validator: (value) => controller.validatePassword(),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),

            // 登录/注册 按钮
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.submit(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    elevation: 0,
                  ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          controller.isLogin.value ? "登录" : "立即注册",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // 切换模式链接
            Center(
              child: TextButton(
                onPressed: () => controller.toggleMode(),
                child: Obx(
                  () => Text(
                    controller.isLogin.value ? "没有账号？点击注册" : "已有账号？返回登录",
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 封装输入框通用样式
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onSuffixIconPressed,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      inputFormatters: isPassword
          ? [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9_]'))]
          : null,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: onSuffixIconPressed,
              )
            : null,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
