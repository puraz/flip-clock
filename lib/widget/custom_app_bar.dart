import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flipclock/constants/app_constants.dart';

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

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onPanStart: (_) => windowManager.startDragging(),
        onDoubleTap: () {
          setState(() {
            _editing = true;
            _focusNode.requestFocus();
          });
        },
        onSecondaryTapDown: (TapDownDetails details) {
          setState(() {
            _tapPosition = details.globalPosition;
          });
        },
        onSecondaryTap: () {
          final RenderBox overlay =
              Overlay.of(context).context.findRenderObject() as RenderBox;
          showMenu<Color>(
            context: context,
            position: RelativeRect.fromRect(
              _tapPosition & const Size(48, 48),
              Offset.zero & overlay.size,
            ),
            items: [
              PopupMenuItem<Color>(
                value: Colors.red,
                onTap: () {
                  windowManager.close();
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.close, color: Colors.black),
                    Text('关闭')
                  ],
                ),
              ),
            ],
          );
        },
        child: Container(
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
    );
  }
}
