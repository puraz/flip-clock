import 'dart:math';
import 'package:flutter/material.dart';

class AppearanceUtils {
  static Map<String, Color> generateRandomColors() {
    final random = Random();
    
    // 生成基础色相 (0-360)
    // 为了获得更悦目的颜色，我们可以限制基础色相的范围
    // 避开一些可能产生不够美观的色相区间
    double baseHue;
    do {
      baseHue = random.nextDouble() * 360;
    } while ((baseHue > 60 && baseHue < 90) || // 避开偏黄色系
             (baseHue > 120 && baseHue < 180)); // 避开某些青色系
    
    // 生成标题栏颜色
    // 使用较深但不太饱和的颜色，提高专业感
    final appBarColor = HSVColor.fromAHSV(
      1.0,
      baseHue,
      0.45 + random.nextDouble() * 0.15,  // saturation: 0.45-0.6
      0.75 + random.nextDouble() * 0.15,  // value: 0.75-0.9
    ).toColor();
    
    // 生成背景颜色
    // 使用同色系但更浅更柔和的颜色
    final bodyColor = HSVColor.fromAHSV(
      1.0,
      baseHue,
      0.08 + random.nextDouble() * 0.12,  // saturation: 0.08-0.2
      0.95 + random.nextDouble() * 0.05,  // value: 0.95-1.0
    ).toColor();
    
    // 生成时钟背景颜色
    // 使用分离互补色，而不是直接使用互补色
    // 这样可以创造出更和谐的配色方案
    final clockBgColor = HSVColor.fromAHSV(
      1.0,
      (baseHue + 150 + random.nextDouble() * 60) % 360, // 分离互补色
      0.25 + random.nextDouble() * 0.15,  // saturation: 0.25-0.4
      0.85 + random.nextDouble() * 0.15,  // value: 0.85-1.0
    ).toColor();

    return {
      'appBarColor': appBarColor,
      'bodyColor': bodyColor,
      'clockBackgroundColor': clockBgColor,
    };
  }
  
  // 可选：添加一个方法来检查颜色之间的对比度
  static bool hasGoodContrast(Color color1, Color color2) {
    final double luminance1 = color1.computeLuminance();
    final double luminance2 = color2.computeLuminance();
    
    final double contrast = (max(luminance1, luminance2) + 0.05) /
                          (min(luminance1, luminance2) + 0.05);
                          
    return contrast >= 2.0; // WCAG AA 标准的最小对比度
  }
}