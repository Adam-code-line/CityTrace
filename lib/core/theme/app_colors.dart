import 'package:flutter/material.dart';

/// CityTrace 全局主题色定义
/// 所有颜色值统一在此管理，避免在代码中硬编码色值
class AppColors {
  AppColors._();

  // ============ 主色调 ============
  /// 品牌主色 - 翠绿色
  static const int _primaryValue = 0xFF009688;
  static const Color primary = Color(_primaryValue);

  /// 品牌主色深色变体
  static const int _primaryDarkValue = 0xFF00695C;
  static const Color primaryDark = Color(_primaryDarkValue);

  /// 品牌主色更深色变体
  static const int _primaryDarkerValue = 0xFF004D40;
  static const Color primaryDarker = Color(_primaryDarkerValue);

  /// 品牌主色浅色变体
  static const int _primaryLightValue = 0xFF80CBC4;
  static const Color primaryLight = Color(_primaryLightValue);

  // ============ 快捷透明度 ============
  /// 主色 5% 透明度
  static Color get primaryOpacity005 => primary.withOpacity(0.05);

  /// 主色 10% 透明度
  static Color get primaryOpacity010 => primary.withOpacity(0.1);

  /// 主色 15% 透明度
  static Color get primaryOpacity015 => primary.withOpacity(0.15);

  /// 主色 30% 透明度
  static Color get primaryOpacity030 => primary.withOpacity(0.3);

  /// 主色 40% 透明度
  static Color get primaryOpacity040 => primary.withOpacity(0.4);

  /// 深色主色 30% 透明度
  static Color get primaryDarkOpacity030 => primaryDark.withOpacity(0.3);

  // ============ 功能色 ============
  /// 危险色 - 红色
  static const Color danger = Colors.red;

  /// 危险色 400
  static const Color danger400 = Colors.redAccent;

  /// 危险色 15% 透明度
  static Color get dangerOpacity015 => danger.withOpacity(0.15);

  /// 危险色 30% 透明度
  static Color get dangerOpacity030 => danger.withOpacity(0.3);

  // ============ 灰度色 ============
  static const Color textGrey = Color(0xFF6B7280);
  static const Color textBlack = Colors.black87;
  static const Color white = Colors.white;
  static const Color grey50 = Colors.grey;
  static const Color greyShade50 = Color(0xFFF5F5F5);
  static const Color greyShade100 = Color(0xFFE0E0E0);
  static const Color greyShade300 = Color(0xFFBDBDBD);
}