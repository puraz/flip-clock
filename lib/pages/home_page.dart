import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:get/get.dart';
import '../controllers/app_config_controller.dart';
import '../widget/custom_app_bar.dart';
import '../widget/app_context_menu.dart';
import 'package:flipclock/constants/app_constants.dart';

import '../widget/flip_clock.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 获取配置控制器
  final AppConfigController configController = Get.put(AppConfigController());

  late final AppContextMenu _contextMenu;

  @override
  void initState() {
    super.initState();
    _contextMenu = AppContextMenu(configController: configController);
  }

  Widget _flipClock(ColorScheme colors) =>
      Container(
        decoration: BoxDecoration(
          color: colors.onPrimary,
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        ),
        padding: const EdgeInsets.all(16.0),
        child: FlipClock(
          digitSize: 54.0,
          width: 54.0,
          height: 84.0,
          separatorColor: colors.primary,
          hingeColor: Colors.black,
          showBorder: true,
          hingeWidth: 0.8,
        ),
      );

  @override
  Widget build(BuildContext context) {
    // 获取当前主题的 ColorScheme
    final colors = Theme.of(context).colorScheme;
    
    return Obx(() => Scaffold(
      // 直接使用 configController.showAppBar.value 来控制
      appBar: configController.showAppBar.value
          ? PreferredSize(
        preferredSize: Size.fromHeight(AppConstants.titleBarHeight),
        child: const CustomAppBar(),
      )
          : null,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        // 根据标题栏显示状态决定是否允许拖动
        // onPanStart: configController.showAppBar.value
        //     ? null
        //     : (_) => windowManager.startDragging(),
        onPanStart: (_) => windowManager.startDragging(),
        onSecondaryTapUp: (details) {
          _contextMenu.show(context, details.globalPosition);
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: configController.bodyColor.value,
          child: Column(
            children: [
              Flexible(
                child: Container(
                  color: configController.bodyColor.value,
                  child:  Center(
                    child: _flipClock(colors),
                    // child: Text('body')
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    ));
  }
}