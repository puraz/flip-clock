import 'package:flipclock/widget/flip_countdown_clock.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:get/get.dart';
import '../controllers/app_config_controller.dart';
import '../widget/custom_app_bar.dart';
import '../widget/app_context_menu.dart';
import 'package:flipclock/constants/app_constants.dart';
import 'dart:math';

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
    // 确保在首页时重置设置页面标志
    configController.isInSettingsPage.value = false;
    _contextMenu = AppContextMenu(configController: configController);
  }

  // Widget _flipClock(ColorScheme colors) => Container(
  //   decoration: BoxDecoration(
  //     color: colors.onPrimary,
  //     borderRadius: const BorderRadius.all(Radius.circular(5.0)),
  //   ),
  //   padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 2.0),
  //   // 添加约束
  //   constraints: const BoxConstraints(
  //     maxHeight: 90.0, // height(72) + vertical padding(5*2)
  //   ),
  //   child: Center(  // 添加Center确保内容居中
  //     child: FlipClock(
  //       digitSize: 58.0,
  //       width: 54.0,
  //       height: 72.0,
  //       separatorColor: colors.primary,
  //       hingeColor: Colors.grey,
  //       showBorder: true,
  //       hingeWidth: 0.8,
  //       separatorWidth: 13.0,
  //       // 调整数字间距，避免溢出
  //       digitSpacing: const EdgeInsets.symmetric(horizontal: 2.0),
  //       // 添加边框圆角，与容器保持一致
  //       borderRadius: const BorderRadius.all(Radius.circular(4.0)),
  //     ),
  //   ),
  // );

  Widget _flipClock(ColorScheme colors) => AnimatedSize(
    duration: const Duration(milliseconds: 300),
    child: LayoutBuilder(
      builder: (context, constraints) {
        // debugPrint('constraints: ${constraints.maxHeight}');
        // 监听时钟背景颜色
        final clockBackgroundColor = configController.clockBackgroundColor.value;
        return Container(
          // 使用 constraints 来确保高度不会超出可用空间
          constraints: BoxConstraints(
            maxHeight: constraints.maxHeight,
            minHeight: 0,
          ),
          decoration: BoxDecoration(
            color: configController.bodyColor.value,
            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
          child: FlipClock(
            // 根据可用空间动态计算尺寸
            digitSize: min(54.0, constraints.maxHeight * 0.7),
            width: min(54.0, constraints.maxWidth * 0.15),
            height: min(68.0, constraints.maxHeight * 0.9),
            separatorColor: clockBackgroundColor,
            hingeColor: clockBackgroundColor,
            showBorder: true,
            hingeWidth: 0.9,
            separatorWidth: 13.0,
            flipDirection: AxisDirection.down,
            backgroundColor: configController.clockBackgroundColor.value,
            key: ValueKey('clock-$clockBackgroundColor'),
          ),
        );
      },
    ),
  );

  Widget _flipCountDownClock(ColorScheme colors) => AnimatedSize(
    duration: const Duration(milliseconds: 300),
    child: LayoutBuilder(
      builder: (context, constraints) {
        // 同时监听倒计时分钟数的变化
        final minutes = configController.countdownMinutes.value;
        // 还要监听时钟背景颜色
        final clockBackgroundColor = configController.clockBackgroundColor.value;
        return Container(
          // 使用 constraints 来确保高度不会超出可用空间
          constraints: BoxConstraints(
            maxHeight: constraints.maxHeight,
            minHeight: 0,
          ),
          decoration: BoxDecoration(
            color: configController.bodyColor.value,
            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
          child: FlipCountdownClock(
            // 根据可用空间动态计算尺寸
            digitSize: min(54.0, constraints.maxHeight * 0.7),
            width: min(54.0, constraints.maxWidth * 0.15),
            height: min(68.0, constraints.maxHeight * 0.9),
            separatorColor: clockBackgroundColor,
            hingeColor: clockBackgroundColor,
            showBorder: true,
            hingeWidth: 0.9,
            separatorWidth: 13.0,
            duration: Duration(minutes: minutes),
            // 使用组合键，包含重置标志和分钟数
            flipDirection: AxisDirection.down,
            backgroundColor: clockBackgroundColor,
            key: ValueKey("${clockBackgroundColor.value}-$minutes"),
          ),
        );
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
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
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      // padding: EdgeInsets.symmetric(
                      //   vertical: configController.showAppBar.value ? 10.0 : 8.0,
                      // ),
                      child: configController.isCountdownMode.value
                          ? _flipCountDownClock(colors)
                          : _flipClock(colors),
                    ),
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