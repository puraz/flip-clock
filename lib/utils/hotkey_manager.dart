import 'package:hotkey_manager/hotkey_manager.dart';

import '../models/hotkey_action.dart';

/// Manages registration and lifecycle of OS-level hotkeys.
///
/// No longer knows about pages, controllers, or window_manager.
/// Actions are wired via [HotkeyActionRegistry] — the caller provides
/// the binding between hotkey id and the concrete domain action.
class HotkeyManager {
  static final HotkeyManager _instance = HotkeyManager._internal();
  factory HotkeyManager() => _instance;
  HotkeyManager._internal();

  HotkeyActionRegistry? _registry;

  /// Attach the action registry. Must be called before [initializeHotkeys].
  void attachRegistry(HotkeyActionRegistry registry) {
    _registry = registry;
  }

  /// Register all hotkeys from the given configs with the OS.
  ///
  /// [configs] is a list of [HotkeyConfig] objects — typically from
  /// `AppConfigController.hotkeyConfigs`.
  Future<void> initializeHotkeys(Iterable<dynamic> configs) async {
    await hotKeyManager.unregisterAll();
    final registry = _registry;
    if (registry == null) return;

    for (final config in configs) {
      // Duck-type the hotkey fields since we avoid coupling to config types
      final hotKey = _hotKeyOf(config);
      final id = _idOf(config);
      if (hotKey == null || id == null) continue;
      final action = registry.get(id);
      if (action == null) continue;

      await hotKeyManager.register(
        hotKey,
        keyDownHandler: (_) => action(),
      );
    }
  }

  // Extract fields by convention to stay decoupled.
  // These match the HotkeyConfig model shape.
  dynamic _hotKeyOf(dynamic config) {
    try {
      return config.hotKey;
    } catch (_) {
      return null;
    }
  }

  String? _idOf(dynamic config) {
    try {
      return config.id as String?;
    } catch (_) {
      return null;
    }
  }

  /// 注销所有快捷键
  Future<void> dispose() async {
    await hotKeyManager.unregisterAll();
  }
}
