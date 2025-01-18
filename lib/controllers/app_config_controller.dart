import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../constants/app_constants.dart';

class AppConfigController extends GetxController {
  // 使用.obs使变量成为可观察的
  final RxBool showAppBar = true.obs;
  final Rx<Color> appBarColor = Colors.white.obs;
  final Rx<Color> bodyColor = Colors.white.obs;
  final RxString titleText = AppConstants.defaultTitleText.obs;
  
  // 添加一个标志来跟踪是否在设置页面
  final RxBool isInSettingsPage = false.obs;

  // 切换标题栏显示状态
  void toggleAppBar() {
    showAppBar.value = !showAppBar.value;
  }
  
  // 添加一个新方法，只改变标题栏状态而不调整窗口大小
  void toggleAppBarWithoutResize(bool value) {
    showAppBar.value = value;
  }

  // 更新标题栏颜色
  void updateAppBarColor(Color color) {
    appBarColor.value = color;
  }
  
  // 更新主体区域颜色
  void updateBodyColor(Color color) {
    bodyColor.value = color;
  }

  // 更新标题文本
  void updateTitleText(String text) {
    titleText.value = text;
  }

  // 监听标题栏显示状态的变化
  void _onShowAppBarChanged() async {
    Size currentSize = await windowManager.getSize();
    debugPrint('currentSize: $currentSize');
    
    // 如果在设置页面，直接计算额外高度
    if (isInSettingsPage.value) {
      double extraHeight = currentSize.height - baseWindowHeight; // 计算额外的高度（比如设置页面的高度）
      debugPrint('extraHeight: $extraHeight');

      if (showAppBar.value) {
        windowManager.setSize(Size(
          AppConstants.windowWidth,
          AppConstants.windowHeight + AppConstants.titleBarHeight + extraHeight
        ));
      } else {
        windowManager.setSize(Size(
          AppConstants.windowWidth,
          AppConstants.windowHeight + extraHeight
        ));
      }
    } else {
      // 在首页时的逻辑
      if (showAppBar.value) {
        windowManager.setSize(Size(
          AppConstants.windowWidth,
          AppConstants.windowHeight + AppConstants.titleBarHeight
        ));
      } else {
        windowManager.setSize(Size(
          AppConstants.windowWidth,
          AppConstants.windowHeight
        ));
      }
    }
  }

  double get baseWindowHeight {
    return showAppBar.value 
        ? AppConstants.windowHeight + AppConstants.titleBarHeight
        : AppConstants.windowHeight;
  }

  @override
  void onInit() {
    super.onInit();
    // 添加监听器
    ever(showAppBar, (_) => _onShowAppBarChanged());
  }
} 