import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:get/get.dart';
import '../controllers/app_config_controller.dart';
import '../widget/custom_app_bar.dart';
import '../widget/app_context_menu.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 修改 appBar 的实现方式
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: Obx(() => configController.showAppBar.value 
          ? const CustomAppBar()
          : Container()),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: (_) => windowManager.startDragging(),
        onSecondaryTapUp: (details) {
          _contextMenu.show(context, details.globalPosition);
        },
        // 使用Obx监听bodyColor的变化
        child: Obx(() => Container(
          color: configController.bodyColor.value,
          child: Column(
            children: [
              Flexible(
                child: Container(
                  color: configController.bodyColor.value,
                  child: const Center(
                    child: Text('body'),
                  ),
                ),
              )
            ],
          ),
        )),
      ),
    );
  }
}