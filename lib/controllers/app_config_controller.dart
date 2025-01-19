import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../constants/app_constants.dart';
import '../constants/preferences_keys.dart';
import '../utils/preferences_manager.dart';

class AppConfigController extends GetxController {
  // 使用.obs使变量成为可观察的
  final RxBool showAppBar = true.obs;
  // 默认颜色，淡蓝色
  final Rx<Color> appBarColor = Color(0XFF007AFF).obs;
  // 默认颜色，白色
  final Rx<Color> bodyColor = Color(0XFFFFFFFF).obs;
  final RxString titleText = AppConstants.defaultTitleText.obs;
  
  // 添加一个标志来跟踪是否在设置页面
  final RxBool isInSettingsPage = false.obs;

  // 添加时钟样式和定时器时间的配置
  final RxBool isCountdownMode = false.obs;
  final RxInt countdownMinutes = 1.obs;

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
    debugPrint('isInSettingsPage: ${isInSettingsPage.value}');
    
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
    _loadSavedConfig();  // 加载保存的配置
    
    // 添加监听器，状态变化时自动保存
    ever(showAppBar, (_) {
      _onShowAppBarChanged();
      _saveShowAppBar();
    });
    
    ever(appBarColor, (_) => _saveAppBarColor());
    ever(bodyColor, (_) => _saveBodyColor());
    ever(titleText, (_) => _saveTitleText());
    
    // 添加新的配置项监听
    ever(isCountdownMode, (_) => _saveIsCountdownMode());
    ever(countdownMinutes, (_) => _saveCountdownMinutes());
  }

  // 加载保存的配置
  void _loadSavedConfig() {
    showAppBar.value = PreferencesManager.getBool(
      PreferencesKeys.showAppBar, 
      defaultValue: true
    );
    
    appBarColor.value = Color(PreferencesManager.getInt(
      PreferencesKeys.appBarColor, 
      defaultValue: Color(0XFF007AFF).value
    ));
    
    bodyColor.value = Color(PreferencesManager.getInt(
      PreferencesKeys.bodyColor, 
      defaultValue: Color(0XFFFFFFFF).value
    ));
    
    titleText.value = PreferencesManager.getString(
      PreferencesKeys.titleText, 
      defaultValue: AppConstants.defaultTitleText
    );
    
    isCountdownMode.value = PreferencesManager.getBool(
      PreferencesKeys.isCountdownMode,
      defaultValue: false
    );
    
    countdownMinutes.value = PreferencesManager.getInt(
      PreferencesKeys.countdownMinutes,
      defaultValue: 1
    );
  }

  // 保存各个配置项
  void _saveShowAppBar() {
    PreferencesManager.setBool(PreferencesKeys.showAppBar, showAppBar.value);
  }

  void _saveAppBarColor() {
    PreferencesManager.setInt(PreferencesKeys.appBarColor, appBarColor.value.value);
  }

  void _saveBodyColor() {
    PreferencesManager.setInt(PreferencesKeys.bodyColor, bodyColor.value.value);
  }

  void _saveTitleText() {
    PreferencesManager.setString(PreferencesKeys.titleText, titleText.value);
  }

  void _saveIsCountdownMode() {
    PreferencesManager.setBool(PreferencesKeys.isCountdownMode, isCountdownMode.value);
  }

  void _saveCountdownMinutes() {
    PreferencesManager.setInt(PreferencesKeys.countdownMinutes, countdownMinutes.value);
  }

} 