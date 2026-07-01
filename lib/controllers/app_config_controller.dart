import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:convert';

import '../constants/app_constants.dart';
import '../persistence/config_persistence.dart';
import '../geometry/window_geometry.dart';
import '../utils/hotkey_manager.dart';
import '../models/hotkey_config.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

class AppConfigController extends GetxController {
  // 使用.obs使变量成为可观察的
  final RxBool showAppBar = true.obs;
  // 默认颜色，淡蓝色
  final Rx<Color> appBarColor = Color(0XFF007AFF).obs;
  // 默认颜色，白色
  final Rx<Color> bodyColor = Color(0XFFFFFFFF).obs;
  final RxString titleText = AppConstants.defaultTitleText.obs;

  /// Extra height contributed by a sub-page (settings, todo) beyond the
  /// main page baseline.  Replaces the old `isNotInMainPage`:
  /// communicates the *dimension* directly rather than a lifecycle flag.
  final RxDouble pageExtraHeight = 0.0.obs;

  // 添加时钟样式和定时器时间的配置
  final RxBool isCountdownMode = false.obs;
  final RxInt countdownMinutes = 1.obs;

  // 添加时钟卡片背景颜色配置
  final Rx<Color> clockBackgroundColor = const Color(0XFFFFA500).obs; // 默认橙色

  // 快捷键配置列表
  final RxList<HotkeyConfig> hotkeyConfigs = <HotkeyConfig>[].obs;

  // 切换标题栏显示状态
  void toggleAppBar() {
    showAppBar.value = !showAppBar.value;
  }

  // 只改变标题栏状态而不调整窗口大小
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

  // 更新时钟卡片背景颜色
  void updateClockBackgroundColor(Color color) {
    clockBackgroundColor.value = color;
  }

  /// Recalculate window size when app bar visibility changes.
  ///
  /// Delegates to [WindowGeometry] instead of inline arithmetic.
  /// [pageExtraHeight] preserves the sub-page height if one is active.
  Future<void> _onShowAppBarChanged() async {
    final size = WindowGeometry.sizeForPage(
      showAppBar: showAppBar.value,
      pageExtraHeight: pageExtraHeight.value,
    );
    await windowManager.setSize(size);
  }

  @override
  void onInit() {
    super.onInit();
    _loadSavedConfig();

    // 监听器，状态变化时自动保存
    ever(showAppBar, (_) {
      _onShowAppBarChanged();
      _saveShowAppBar();
    });

    ever(appBarColor, (_) => _saveAppBarColor());
    ever(bodyColor, (_) => _saveBodyColor());
    ever(titleText, (_) => _saveTitleText());

    ever(isCountdownMode, (_) => _saveIsCountdownMode());
    ever(countdownMinutes, (_) => _saveCountdownMinutes());
    ever(clockBackgroundColor, (_) => _saveClockBackgroundColor());
    _loadHotKeys();
  }

  /// 加载保存的配置 — delegates to [ConfigPersistence]
  void _loadSavedConfig() {
    showAppBar.value = ConfigPersistence.loadShowAppBar();
    appBarColor.value = ConfigPersistence.loadAppBarColor();
    bodyColor.value = ConfigPersistence.loadBodyColor();
    titleText.value = ConfigPersistence.loadTitleText();
    isCountdownMode.value = ConfigPersistence.loadIsCountdownMode();
    countdownMinutes.value = ConfigPersistence.loadCountdownMinutes();
    clockBackgroundColor.value = ConfigPersistence.loadClockBackgroundColor();
  }

  // 保存各个配置项 — delegates to [ConfigPersistence]
  void _saveShowAppBar() => ConfigPersistence.saveShowAppBar(showAppBar.value);
  void _saveAppBarColor() => ConfigPersistence.saveAppBarColor(appBarColor.value);
  void _saveBodyColor() => ConfigPersistence.saveBodyColor(bodyColor.value);
  void _saveTitleText() => ConfigPersistence.saveTitleText(titleText.value);
  void _saveIsCountdownMode() => ConfigPersistence.saveIsCountdownMode(isCountdownMode.value);
  void _saveCountdownMinutes() => ConfigPersistence.saveCountdownMinutes(countdownMinutes.value);
  void _saveClockBackgroundColor() => ConfigPersistence.saveClockBackgroundColor(clockBackgroundColor.value);

  void toggleCountdownMode() {
    isCountdownMode.value = !isCountdownMode.value;
  }

  // 更新快捷键
  Future<void> updateHotKey(String id, HotKey? newHotKey) async {
    final index = hotkeyConfigs.indexWhere((config) => config.id == id);
    if (index != -1) {
      hotkeyConfigs[index] = hotkeyConfigs[index].copyWith(hotKey: newHotKey);
      await _saveHotKeys();
      await HotkeyManager().initializeHotkeys(hotkeyConfigs);
    }
  }

  // 加载快捷键配置
  Future<void> _loadHotKeys() async {
    final List<HotkeyConfig> loadedConfigs = [];

    for (final defaultConfig in HotkeyConfig.defaultConfigs) {
      final String? savedHotKeyStr = PreferencesManager.getString('hotkey_${defaultConfig.id}');

      if (savedHotKeyStr != null) {
        try {
          final Map<String, dynamic> json = jsonDecode(savedHotKeyStr);
          loadedConfigs.add(HotkeyConfig.fromJson(json));
        } catch (e) {
          debugPrint('Error loading hotkey for ${defaultConfig.id}: $e');
          loadedConfigs.add(defaultConfig);
        }
      } else {
        loadedConfigs.add(defaultConfig);
      }
    }

    hotkeyConfigs.value = loadedConfigs;
  }

  // 保存快捷键配置
  Future<void> _saveHotKeys() async {
    for (final config in hotkeyConfigs) {
      await PreferencesManager.setString(
        'hotkey_${config.id}',
        jsonEncode(config.toJson()),
      );
    }
  }
}
