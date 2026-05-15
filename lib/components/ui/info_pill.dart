import 'package:citytrace/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const InfoPill({Key? key, required this.icon, required this.text})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // 控制胶囊内部的留白 (上下小，左右大)
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // 满圆角，形成胶囊形状
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04), // 非常柔和的阴影，提升精致感
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // 关键：让 Row 的宽度紧贴内容，而不是撑满屏幕
        children: [
          Icon(
            icon,
            size: 14, // 图标尺寸要小，显得精致
            color: AppColors.primary,
          ),
          const SizedBox(width: 6), // 图标与文字的间距
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500, // 中等字重
              color: AppColors.textGrey,
              height: 1.2, // 调整行高让文字垂直居中更好看
            ),
          ),
        ],
      ),
    );
  }
}
