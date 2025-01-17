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
  late Offset _tapPosition;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    _focusNode = FocusNode();
    _controller.text = AppConstants.defaultTitleText;

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() {
          _editing = false;
        });
      }
    });

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: -70, end: 70)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
    ]).animate(_animationController);

    _animationController.repeat(reverse: true);

    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color titleBgColor = Colors.lightBlue;
    Color titleTextColor = Colors.white;

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
              color: titleBgColor,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              alignment: Alignment.center,
              child: _editing
                  ? TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      autofocus: true,
                      maxLength: AppConstants.maxTitleLength,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                      onSubmitted: (value) {
                        setState(() {
                          _editing = false;
                        });
                      },
                      decoration: const InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        counterText: "",
                      ),
                    )
                  : Text(
                      AppConstants.defaultTitleText,
                      style: TextStyle(
                        color: titleTextColor,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
