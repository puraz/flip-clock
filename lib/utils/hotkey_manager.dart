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
    // 确保在应用启动时初始化
    await hotKeyManager.unregisterAll();
    
    // 显示/隐藏标题栏 (CTRL + SHIFT + T)
    await hotKeyManager.register(
      HotKey(
        key: PhysicalKeyboardKey.keyT,
        modifiers: [HotKeyModifier.control, HotKeyModifier.shift],
        scope: HotKeyScope.inapp,
      ),
      keyDownHandler: (_) {
        // 获取 AppConfigController 实例并切换标题栏显示状态
        final appConfigController = Get.find<AppConfigController>();
        appConfigController.toggleAppBar();
      },
    );

    // 随机外观 (CTRL + SHIFT + R)
    await hotKeyManager.register(
      HotKey(
        key: PhysicalKeyboardKey.keyR,
        modifiers: [HotKeyModifier.control, HotKeyModifier.shift],
        scope: HotKeyScope.inapp,
      ),
      keyDownHandler: (_) {
        final appConfigController = Get.find<AppConfigController>();
        final colors = AppearanceUtils.generateRandomColors();
        
        appConfigController.updateAppBarColor(colors['appBarColor']!);
        appConfigController.updateBodyColor(colors['bodyColor']!);
        appConfigController.updateClockBackgroundColor(colors['clockBackgroundColor']!);
      },
    );

    // 关闭应用程序 (CTRL + Q)
    await hotKeyManager.register(
      HotKey(
        key: PhysicalKeyboardKey.keyQ,
        modifiers: [HotKeyModifier.control],
        scope: HotKeyScope.inapp,
      ),
      keyDownHandler: (_) async {
        await windowManager.close();
      },
    );

    // 切换时钟/倒计时模式 (CTRL + T)
    await hotKeyManager.register(
      HotKey(
        key: PhysicalKeyboardKey.keyT,
        modifiers: [HotKeyModifier.control],
        scope: HotKeyScope.inapp,
      ),
      keyDownHandler: (_) {
        final appConfigController = Get.find<AppConfigController>();
        appConfigController.toggleCountdownMode();
      },
    );

    // 打开设置页面 (CTRL + S)
    await hotKeyManager.register(
      HotKey(
        key: PhysicalKeyboardKey.keyS,
        modifiers: [HotKeyModifier.control],
        scope: HotKeyScope.inapp,
      ),
      keyDownHandler: (_) {
        final appConfigController = Get.find<AppConfigController>();
        Get.to(
          () => SettingsPage(configController: appConfigController),
            transition: Transition.rightToLeft,
            duration: const Duration(milliseconds: 250),
        );
      },
    );
  }

  // 注销所有快捷键
  Future<void> dispose() async {
    await hotKeyManager.unregisterAll();
  }
}