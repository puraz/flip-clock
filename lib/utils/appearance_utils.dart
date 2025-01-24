import 'dart:math';
import 'package:flutter/material.dart';

class AppearanceUtils {
  static Map<String, Color> generateRandomColors() {
    final random = Random();
    
    // 生成基础色相 (0-360)
    final baseHue = random.nextDouble() * 360;
    
    // 生成标题栏颜色 - 使用较深的颜色
    final appBarColor = HSVColor.fromAHSV(
      1.0,                    // alpha
      baseHue,               // hue
      0.6 + random.nextDouble() * 0.2,  // saturation: 0.6-0.8
      0.8 + random.nextDouble() * 0.2,  // value: 0.8-1.0
    ).toColor();
    
    // 生成背景颜色 - 使用较浅的颜色
    final bodyColor = HSVColor.fromAHSV(
      1.0,
      (baseHue + 30) % 360,  // 稍微偏移色相
      0.1 + random.nextDouble() * 0.2,  // saturation: 0.1-0.3
      0.9 + random.nextDouble() * 0.1,  // value: 0.9-1.0
    ).toColor();
    
    // 生成时钟背景颜色 - 使用互补或相近色
    final clockBgColor = HSVColor.fromAHSV(
      1.0,
      (baseHue + 180) % 360, // 互补色
      0.3 + random.nextDouble() * 0.3,  // saturation: 0.3-0.6
      0.8 + random.nextDouble() * 0.2,  // value: 0.8-1.0
    ).toColor();

    return {
      'appBarColor': appBarColor,
      'bodyColor': bodyColor,
      'clockBackgroundColor': clockBgColor,
    };
  }
} 