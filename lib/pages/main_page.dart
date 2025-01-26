import 'package:flipclock/widget/flip_countdown_clock.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:get/get.dart';
import '../controllers/app_config_controller.dart';
import '../controllers/todo_controller.dart';
import '../widget/custom_app_bar.dart';
import '../widget/app_context_menu.dart';
import 'package:flipclock/constants/app_constants.dart';
import 'dart:math';

import '../widget/flip_clock.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // 获取配置控制器
  final AppConfigController configController = Get.put(AppConfigController());
  final TodoController todoController = Get.put(TodoController());

  late final AppContextMenu _contextMenu;

  // 重置触发器
  late var _resetTrigger = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    // 确保在首页时重置标志
    configController.isNotInMainPage.value = false;
    _contextMenu = AppContextMenu(configController: configController);
    _resetTrigger = ValueNotifier<int>(0);
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
    child: ValueListenableBuilder(
      valueListenable: _resetTrigger,
      builder: (context, resetCount, child) {
        return LayoutBuilder(
            builder: (context, constraints) {
          // debugPrint('constraints: ${constraints.maxHeight}');
          // 监听时钟背景颜色
          final clockBackgroundColor = configController.clockBackgroundColor.value;
          final clockMode = configController.isCountdownMode;
          final digitSize = min(54.0, constraints.maxHeight * 0.7);
          final width = min(54.0, constraints.maxWidth * 0.15);
          final height = min(68.0, constraints.maxHeight * 0.9);
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
              digitSize: digitSize,
              width: width,
              height: height,
              separatorColor: clockBackgroundColor,
              hingeColor: clockBackgroundColor,
              showBorder: true,
              hingeWidth: 0.8,
              separatorWidth: 7.0,
              flipDirection: AxisDirection.down,
              backgroundColor: configController.clockBackgroundColor.value,
              digitSpacing: const EdgeInsets.fromLTRB(0, 0, 5, 0),
              // key: ValueKey('clock-$clockMode-$clockMode-$clockBackgroundColor-$resetCount'),
              key: UniqueKey()
            ),
          );
        });
      },
    ),
  );

  Widget _flipCountDownClock(ColorScheme colors) => AnimatedSize(
    duration: const Duration(milliseconds: 300),
    child: ValueListenableBuilder<int>(
      valueListenable: _resetTrigger,
      builder: (context, resetCount, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final minutes = configController.countdownMinutes.value;
            final clockBackgroundColor = configController.clockBackgroundColor.value;
            final clockMode = configController.isCountdownMode;
            final digitSize = min(54.0, constraints.maxHeight * 0.7);
            final width = min(54.0, constraints.maxWidth * 0.15);
            final height = min(68.0, constraints.maxHeight * 0.9);
            return Container(
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
                digitSize: digitSize,
                width: width,
                height: height,
                separatorColor: clockBackgroundColor,
                hingeColor: clockBackgroundColor,
                showBorder: true,
                hingeWidth: 0.8,
                separatorWidth: 7.0,
                duration: Duration(minutes: minutes),
                flipDirection: AxisDirection.down,
                backgroundColor: clockBackgroundColor,
                digitSpacing: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                // key: ValueKey("$clockMode-$minutes-$clockBackgroundColor-$resetCount"),
                key: UniqueKey()
              ),
            );
          },
        );
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    
    return Obx(() => Scaffold(
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
        // 添加双击手势
        onDoubleTap: () {
          // 只在倒计时模式下重置
          if (configController.isCountdownMode.value) {
            // 增加重置计数以触发重建
            _resetTrigger.value++;
          }
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
      // floatingActionButton: Opacity(
      //   opacity: 0.8,  // 设置透明度为0.8，可以根据需要调整（0.0到1.0之间）
      //   child: FloatingActionButton(
      //     mini: true,
      //     child: Icon(
      //       todoController.showTodoPanel.value ? Icons.checklist_rtl : Icons.checklist,
      //     ),
      //     onPressed: () => todoController.toggleTodoPanel(),
      //   ),
      // ),
    ));
  }

  // 在 dispose 中释放
  @override
  void dispose() {
    _resetTrigger.dispose();
    super.dispose();
  }
}