import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class HeadTitle extends StatefulWidget {
  const HeadTitle({super.key});


  @override
  State<HeadTitle> createState() => _HeadTitleState();
}

class _HeadTitleState extends State<HeadTitle> with SingleTickerProviderStateMixin {
   bool _editing = false;
  late FocusNode _focusNode;
  final TextEditingController _controller = TextEditingController();
  late Offset _tapPosition;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    _focusNode = FocusNode();
    _controller.text = '天下万物生于有，有生于无';

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

  // void _handleFocusChange(AppState appState) {
  //   if (!_focusNode.hasFocus) {
  //     setState(() {
  //       _editing = false;
  //     });
  //     appState.updateHeadTitle(_controller.text);
  //   }
  // }

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
        // 当用户在这个区域按下鼠标时，调用 WindowManager.startDragging
        onPanStart: (_) => windowManager.startDragging(),
        onDoubleTap: () {
          setState(() {
            _editing = true;
            _focusNode.requestFocus();
            // 调用requestFocus来强制文本字段获取焦点
            // FocusScope.of(context).requestFocus(_focusNode);
          });
        },
        onSecondaryTapDown: (TapDownDetails details) {
          setState(() {
            _tapPosition = details.globalPosition;
          });
        },
        onSecondaryTap: () {
          // 在此处显示弹出菜单
          final RenderBox overlay =
              Overlay.of(context).context.findRenderObject() as RenderBox;
          showMenu<Color>(
            context: context,
            position: RelativeRect.fromRect(
              _tapPosition & const Size(48, 48), // 小方块大小作为点击区域
              Offset.zero & overlay.size, // 不设置偏移
            ),
            items: [
              PopupMenuItem<Color>(
                value: Colors.red,
                onTap: () {
                  // SystemNavigator.pop(); // 调用此方法关闭应用程序
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
            // 装饰你的自定义标题栏
            color: titleBgColor,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            alignment: Alignment.center,
            child: _editing
                ? TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    autofocus: true,
                    maxLength: 36,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                    onSubmitted: (value) {
                      setState(() {
                        _editing = false;
                      });
                      // appState.updateHeadTitle(value);
                    },
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      counterText: "", // 隐藏TextField右下角的计数器
                    ),
                  )
                :
                /*AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(_animation.value, 0),
                        child: Text(
                          '天下万物生于有，有生于无',
                          style: TextStyle(
                            color: titleTextColor,
                            fontSize: 20,
                          ),
                        ),
                      );
                    },
                  )*/
            Text(
              '天下万物生于有，有生于无',
              style: TextStyle(
                color: titleTextColor,
                fontSize: 16,
              ),
            )
        ),
      ),
    );
  }
}