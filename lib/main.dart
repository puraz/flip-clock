import 'package:flipclock/pages/main_page.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flipclock/constants/app_constants.dart';
import 'package:get/get.dart';
import 'package:flipclock/controllers/app_config_controller.dart';
import 'package:flipclock/geometry/window_geometry.dart';
import 'package:flipclock/utils/appearance_utils.dart';
import 'package:flipclock/navigation/app_router.dart';
import 'package:flipclock/models/hotkey_action.dart';
import 'package:flipclock/utils/preferences_manager.dart';
import './utils/hotkey_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferencesManager.init();
  await windowManager.ensureInitialized();

  final configController = Get.put(AppConfigController());

  // Wire hotkey actions — registers each domain action with the registry
  // so HotkeyManager stays decoupled from pages and controllers.
  final registry = HotkeyActionRegistry();
  registry.register('toggleAppBar', () => configController.toggleAppBar());
  registry.register('toggleClockMode', () => configController.toggleCountdownMode());
  registry.register('openSettings', () => AppRouter.openSettings(configController));
  registry.register('randomAppearance', () {
    final colors = AppearanceUtils.generateRandomColors();
    configController.updateAppBarColor(colors['appBarColor']!);
    configController.updateBodyColor(colors['bodyColor']!);
    configController.updateClockBackgroundColor(colors['clockBackgroundColor']!);
  });
  registry.register('closeApp', () => windowManager.close());
  HotkeyManager().attachRegistry(registry);
  await HotkeyManager().initializeHotkeys(configController.hotkeyConfigs);

  // Use WindowGeometry for initial window size
  final initialSize = WindowGeometry.sizeForPage(
    showAppBar: configController.showAppBar.value,
  );
  WindowOptions windowOptions = WindowOptions(
    size: initialSize,
    center: true,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setOpacity(1);
    await windowManager.setIcon('assets/icons/app_icon.ico');
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
      home: const MainPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}