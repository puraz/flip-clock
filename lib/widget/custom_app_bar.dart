import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flipclock/constants/app_constants.dart';
import 'package:get/get.dart';
import '../controllers/app_config_controller.dart';
import 'app_context_menu.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(AppConstants.titleBarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> with SingleTickerProviderStateMixin {
  bool _editing = false;
  late FocusNode _focusNode;
  final TextEditingController _controller = TextEditingController();
  late AnimationController _marqueeController;
  late ScrollController _scrollController;
  bool _shouldScroll = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    final configController = Get.find<AppConfigController>();
    _controller.text = configController.titleText.value;

    _marqueeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20), // 调整滚动速度
    );

    _scrollController = ScrollController();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() {
          _editing = false;
        });
        _saveText();
      }
    });

    // 检查是否需要滚动并启动动画
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfNeedsScroll();
    });
  }

  void _checkIfNeedsScroll() {
    final configController = Get.find<AppConfigController>();
    final text = configController.titleText.value;
    _shouldScroll = text.length > 22;

    if (_shouldScroll) {
      _startScrolling();
    } else {
      _marqueeController.stop();
    }
  }

  void _startScrolling() {
    _marqueeController.repeat();
    _marqueeController.addListener(() {
      if (_scrollController.hasClients) {
        final maxExtent = _scrollController.position.maxScrollExtent;
        final currentPos = _marqueeController.value * maxExtent;
        _scrollController.jumpTo(currentPos);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    _marqueeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _saveText() {
    setState(() {
      _editing = false;
    });
    final configController = Get.find<AppConfigController>();
    configController.updateTitleText(_controller.text);
    _checkIfNeedsScroll(); // 保存文本后检查是否需要滚动
  }

  @override
  Widget build(BuildContext context) {
    Color titleTextColor = Colors.white;
    final configController = Get.find<AppConfigController>();

    return GetX<AppConfigController>(
      builder: (controller) => Visibility(
        visible: controller.showAppBar.value,
        maintainState: true,
        maintainSize: true,
        maintainAnimation: true,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onPanStart: (_) => windowManager.startDragging(),
            onDoubleTap: () {
              setState(() {
                _editing = true;
                _focusNode.requestFocus();
              });
            },
            onSecondaryTapUp: (details) {
              final contextMenu = AppContextMenu(
                configController: Get.find<AppConfigController>(),
              );
              contextMenu.show(context, details.globalPosition);
            },
            child: Container(
              height: AppConstants.titleBarHeight,
              color: controller.appBarColor.value,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              alignment: Alignment.center,
              child: _editing
                  ? TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: true,
                maxLength: AppConstants.maxTitleLength,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 17, color: Colors.white),
                onSubmitted: (_) => _saveText(),
                onEditingComplete: _saveText,
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  counterText: "",
                ),
              )
                  : Obx(() {
                final text = configController.titleText.value;
                if (text.length <= 22) {
                  return Text(
                    text,
                    style: TextStyle(
                      color: titleTextColor,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );
                }

                return ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      colors: [
                        controller.appBarColor.value,
                        Colors.white,
                        Colors.white,
                        controller.appBarColor.value,
                      ],
                      stops: const [0.0, 0.15, 0.85, 1.0],
                    ).createShader(bounds);
                  },
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: _scrollController,
                    physics: const NeverScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Row(
                        children: [
                          Text(
                            text,
                            style: TextStyle(
                              color: titleTextColor,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(width: 40),
                          Text(
                            text,
                            style: TextStyle(
                              color: titleTextColor,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}