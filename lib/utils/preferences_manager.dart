import 'package:shared_preferences/shared_preferences.dart';

class PreferencesManager {
  static late SharedPreferences _prefs;
  
  // 初始化
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 存储配置项
  static Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }
  
  static Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  static Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  // 读取配置项
  static String getString(String key, {String defaultValue = ''}) {
    return _prefs.getString(key) ?? defaultValue;
  }
  
  static bool getBool(String key, {bool defaultValue = false}) {
    return _prefs.getBool(key) ?? defaultValue;
  }

  static int getInt(String key, {int defaultValue = 0}) {
    return _prefs.getInt(key) ?? defaultValue;
  }

  // 删除配置项
  static Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  // 清空所有配置
  static Future<bool> clear() async {
    return await _prefs.clear();
  }
} 