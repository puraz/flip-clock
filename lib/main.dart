import 'package:flipclock/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flipclock/constants/app_constants.dart';
import 'package:get/get.dart';
import 'package:flipclock/controllers/app_config_controller.dart';
import 'package:flipclock/utils/preferences_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化 SharedPreferences
  await PreferencesManager.init();
  // await PreferencesManager.clear();
  // 必须加上这一行。
  await windowManager.ensureInitialized();

  // 获取配置控制器
  final configController = Get.put(AppConfigController());

  WindowOptions windowOptions = WindowOptions(
    size: Size(
      AppConstants.windowWidth,
      // 根据标题栏显示状态设置初始窗口高度
      AppConstants.windowHeight + (configController.showAppBar.value ? AppConstants.titleBarHeight : 0)
    ),
    center: true,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setOpacity(1);
    // await windowManager.setIcon('assets/icon.png');
  });

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WindowListener {

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    super.dispose();
    windowManager.removeListener(this);
  }


  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}