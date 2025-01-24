import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

class HotkeyConfig {
  final String id;          // 快捷键唯一标识
  final String name;        // 快捷键名称
  final String description; // 快捷键描述
  final HotKey? hotKey;     // 快捷键组合

  const HotkeyConfig({
    required this.id,
    required this.name,
    required this.description,
    this.hotKey,
  });

  // 从JSON转换为对象
  factory HotkeyConfig.fromJson(Map<String, dynamic> json) {
    return HotkeyConfig(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      hotKey: json['hotKey'] == null ? null : _hotKeyFromJson(json['hotKey']),
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'hotKey': hotKey == null ? null : _hotKeyToJson(hotKey!),
    };
  }

  // 创建副本并更新快捷键
  HotkeyConfig copyWith({HotKey? hotKey}) {
    return HotkeyConfig(
      id: id,
      name: name,
      description: description,
      hotKey: hotKey ?? this.hotKey,
    );
  }

  // HotKey 转 JSON
  static Map<String, dynamic> _hotKeyToJson(HotKey hotKey) {
    return hotKey.toJson();
    // return {
    //   'keyId': keyboardKey.keyId,
    //   'modifiers': hotKey.modifiers?.map((m) => m.index).toList(),
    // };
  }

  // JSON 转 HotKey
  static HotKey _hotKeyFromJson(Map<String, dynamic> json) {
    return HotKey.fromJson(json);
    // return HotKey(
    //   key: LogicalKeyboardKey(json['keyId']),
    //   modifiers: (json['modifiers'] as List)
    //       .map((i) => HotKeyModifier.values[i as int])
    //       .toList(),
    // );
  }

  // 预定义的快捷键配置
  static List<HotkeyConfig> defaultConfigs = [
    HotkeyConfig(
      id: 'toggleAppBar',
      name: '切换标题栏',
      description: '显示或隐藏应用标题栏',
      hotKey: HotKey(
        key: PhysicalKeyboardKey.keyT,
        modifiers: [HotKeyModifier.control, HotKeyModifier.shift],
        scope: HotKeyScope.inapp
      ),
    ),
    HotkeyConfig(
      id: 'toggleClockMode',
      name: '切换时钟模式',
      description: '在时钟和倒计时模式之间切换',
      hotKey: HotKey(
        key: PhysicalKeyboardKey.keyT,
        modifiers: [HotKeyModifier.control],
        scope: HotKeyScope.inapp
      ),
    ),
    HotkeyConfig(
      id: 'openSettings',
      name: '打开设置',
      description: '打开设置页面',
      hotKey: HotKey(
        key: PhysicalKeyboardKey.keyS,
        modifiers: [HotKeyModifier.control],
        scope: HotKeyScope.inapp
      ),
    ),
    HotkeyConfig(
      id: 'randomAppearance',
      name: '随机外观',
      description: '随机更改应用外观',
      hotKey: HotKey(
        key: PhysicalKeyboardKey.keyR,
        modifiers: [HotKeyModifier.control, HotKeyModifier.shift],
        scope: HotKeyScope.inapp
      ),
    ),
    HotkeyConfig(
      id: 'closeApp',
      name: '关闭应用',
      description: '关闭应用程序',
      hotKey: HotKey(
        key: PhysicalKeyboardKey.keyQ,
        modifiers: [HotKeyModifier.control],
        scope: HotKeyScope.inapp
      ),
    ),
  ];

  // 添加一个方法来格式化快捷键显示
  String getHotkeyDisplayString() {
    if (hotKey == null) return '未设置';
    
    final List<String> parts = [];
    
    // 添加修饰键
    if (hotKey!.modifiers != null) {
      for (final modifier in hotKey!.modifiers!) {
        switch (modifier) {
          case HotKeyModifier.alt:
            parts.add('Alt');
          case HotKeyModifier.control:
            parts.add('Ctrl');
          case HotKeyModifier.shift:
            parts.add('Shift');
          case HotKeyModifier.meta:
            parts.add('Meta');
          case HotKeyModifier.capsLock:
            parts.add('CapsLock');
          case HotKeyModifier.fn:
            parts.add('Fn');
        }
      }
    }
    
    // 添加主键
    String keyLabel = '';
    final key = hotKey!.key;
    
    if (key is PhysicalKeyboardKey) {
      // 处理物理键
      keyLabel = _getPhysicalKeyLabel(key);
    } else {
      // 处理逻辑键
      keyLabel = _getLogicalKeyLabel(key as LogicalKeyboardKey);
    }
    
    parts.add(keyLabel);
    
    return parts.join(' + ');
  }

  // 获取物理键标签
  String _getPhysicalKeyLabel(PhysicalKeyboardKey key) {
    // 常用按键映射
    Map<PhysicalKeyboardKey, String> keyLabels = {
      PhysicalKeyboardKey.keyA: 'A',
      PhysicalKeyboardKey.keyB: 'B',
      PhysicalKeyboardKey.keyC: 'C',
      PhysicalKeyboardKey.keyD: 'D',
      PhysicalKeyboardKey.keyE: 'E',
      PhysicalKeyboardKey.keyF: 'F',
      PhysicalKeyboardKey.keyG: 'G',
      PhysicalKeyboardKey.keyH: 'H',
      PhysicalKeyboardKey.keyI: 'I',
      PhysicalKeyboardKey.keyJ: 'J',
      PhysicalKeyboardKey.keyK: 'K',
      PhysicalKeyboardKey.keyL: 'L',
      PhysicalKeyboardKey.keyM: 'M',
      PhysicalKeyboardKey.keyN: 'N',
      PhysicalKeyboardKey.keyO: 'O',
      PhysicalKeyboardKey.keyP: 'P',
      PhysicalKeyboardKey.keyQ: 'Q',
      PhysicalKeyboardKey.keyR: 'R',
      PhysicalKeyboardKey.keyS: 'S',
      PhysicalKeyboardKey.keyT: 'T',
      PhysicalKeyboardKey.keyU: 'U',
      PhysicalKeyboardKey.keyV: 'V',
      PhysicalKeyboardKey.keyW: 'W',
      PhysicalKeyboardKey.keyX: 'X',
      PhysicalKeyboardKey.keyY: 'Y',
      PhysicalKeyboardKey.keyZ: 'Z',
      PhysicalKeyboardKey.space: 'Space',
      PhysicalKeyboardKey.enter: 'Enter',
      PhysicalKeyboardKey.escape: 'Esc',
      PhysicalKeyboardKey.backspace: 'Backspace',
      PhysicalKeyboardKey.delete: 'Delete',
      PhysicalKeyboardKey.tab: 'Tab',
    };

    return keyLabels[key] ?? key.debugName ?? 'Unknown';
  }

  // 获取逻辑键标签
  String _getLogicalKeyLabel(LogicalKeyboardKey key) {
    // 常用按键映射
    const Map<int, String> keyLabels = {
      0x00000020: 'Space',
      0x0000000d: 'Enter',
      0x0000001b: 'Esc',
      0x00000008: 'Backspace',
      0x0000007f: 'Delete',
      0x00000009: 'Tab',
    };

    // 检查是否是字母键
    if (key.keyId >= 0x00000061 && key.keyId <= 0x0000007a) {
      // 将小写字母转换为大写
      return String.fromCharCode(key.keyId - 32);
    }

    return keyLabels[key.keyId] ?? key.debugName ?? 'Unknown';
  }
}