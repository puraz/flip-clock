import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

import '../controllers/app_config_controller.dart';
import '../pages/settings_page.dart';
import '../utils/appearance_utils.dart';

class HotkeyManager {
  // 单例模式
  static final HotkeyManager _instance = HotkeyManager._internal();
  factory HotkeyManager() => _instance;
  HotkeyManager._internal();

  // 初始化快捷键
  Future<void> initializeHotkeys() async {
    await hotKeyManager.unregisterAll();
    
    final appConfigController = Get.find<AppConfigController>();
    
    for (final config in appConfigController.hotkeyConfigs) {
      if (config.hotKey == null) continue;
      
      await hotKeyManager.register(
        config.hotKey!,
        keyDownHandler: (_) => _executeHotkeyAction(config.id),
      );
    }
  }

  void _executeHotkeyAction(String id) {
    final appConfigController = Get.find<AppConfigController>();
    
    switch (id) {
      case 'toggleAppBar':
        appConfigController.toggleAppBar();
        break;
      case 'toggleClockMode':
        appConfigController.toggleCountdownMode();
        break;
      case 'openSettings':
        Get.to(
          () => SettingsPage(configController: appConfigController),
          transition: Transition.rightToLeft,
          duration: const Duration(milliseconds: 250),
        );
        break;
      case 'randomAppearance':
        final colors = AppearanceUtils.generateRandomColors();
        appConfigController.updateAppBarColor(colors['appBarColor']!);
        appConfigController.updateBodyColor(colors['bodyColor']!);
        appConfigController.updateClockBackgroundColor(colors['clockBackgroundColor']!);
        break;
      case 'closeApp':
        windowManager.close();
        break;
    }
  }

  // 注销所有快捷键
  Future<void> dispose() async {
    await hotKeyManager.unregisterAll();
  }
}