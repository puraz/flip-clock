import 'package:get/get.dart';
import 'package:flutter/material.dart';

class AppConfigController extends GetxController {
  // 使用.obs使变量成为可观察的
  final RxBool showAppBar = true.obs;
  final Rx<Color> appBarColor = Colors.white.obs;
  final Rx<Color> bodyColor = Colors.orange.obs;
  
  // 切换标题栏显示状态
  void toggleAppBar() {
    showAppBar.value = !showAppBar.value;
  }
  
  // 更新标题栏颜色
  void updateAppBarColor(Color color) {
    appBarColor.value = color;
  }
  
  // 更新主体区域颜色
  void updateBodyColor(Color color) {
    bodyColor.value = color;
  }
} 