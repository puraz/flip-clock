import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../constants/app_constants.dart';

class AppConfigController extends GetxController {
  // 使用.obs使变量成为可观察的
  final RxBool showAppBar = true.obs;
  final Rx<Color> appBarColor = Colors.white.obs;
  final Rx<Color> bodyColor = Colors.white.obs;
  
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

  // 监听标题栏显示状态的变化
  void _onShowAppBarChanged() {
    if (showAppBar.value) {
      // 显示标题栏时，增加窗口高度
      windowManager.setSize(Size(
        AppConstants.windowWidth,
        AppConstants.windowHeight + AppConstants.titleBarHeight
      ));
    } else {
      // 隐藏标题栏时，减少窗口高度
      windowManager.setSize(Size(
        AppConstants.windowWidth,
        AppConstants.windowHeight
      ));
    }
  }

  @override
  void onInit() {
    super.onInit();
    // 添加监听器
    ever(showAppBar, (_) => _onShowAppBarChanged());
  }
} 