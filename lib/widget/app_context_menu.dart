import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/app_config_controller.dart';

class AppContextMenu extends StatelessWidget {
  final AppConfigController configController;
  
  const AppContextMenu({
    super.key,
    required this.configController,
  });

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  void show(BuildContext context, Offset position) {
    showMenu<void>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: <PopupMenuEntry<void>>[
        PopupMenuItem<void>(
          child: Obx(() => Row(
            children: [
              Icon(
                configController.showAppBar.value 
                    ? Icons.visibility 
                    : Icons.visibility_off,
                size: 18,
                color: Colors.grey.shade700,
              ),
              const SizedBox(width: 8),
              Text(configController.showAppBar.value 
                  ? '隐藏标题栏' 
                  : '显示标题栏'),
            ],
          )),
          onTap: () => configController.toggleAppBar(),
        ),
        PopupMenuItem<void>(
          child: Row(
            children: [
              Icon(
                Icons.settings,
                size: 18,
                color: Colors.grey.shade700,
              ),
              const SizedBox(width: 8),
              const Text('更多设置'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<void>(
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 18,
                color: Colors.grey.shade700,
              ),
              const SizedBox(width: 8),
              const Text('关于'),
            ],
          ),
        ),
      ],
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

} 