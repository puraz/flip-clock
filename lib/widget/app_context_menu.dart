import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';
import '../controllers/app_config_controller.dart';
import '../constants/app_constants.dart';
import '../controllers/todo_controller.dart';
import '../navigation/app_router.dart';

/// Context menu shown on right-click / secondary tap.
///
/// Designed as a plain utility class rather than a Widget — its only
/// public surface is [show], which displays a [PopupMenu].  The old
/// version extended StatelessWidget but its `build()` returned an empty
/// Container, violating the widget contract.
class AppContextMenu {
  final AppConfigController configController;

  AppContextMenu({required this.configController});

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        titlePadding: const EdgeInsets.fromLTRB(14, 6, 8, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 0, 16, 0),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 8, 6),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.access_time, size: 18),
            SizedBox(width: 8),
            Text(
              AppConstants.appName,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 200,
            maxHeight: 150,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'v${AppConstants.version}',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 1),
                Text(
                  AppConstants.description,
                  style: TextStyle(fontSize: 12),
                ),
                const Divider(height: 1),
                Text(
                  '开发者: ${AppConstants.developer}',
                  style: TextStyle(fontSize: 12),
                ),
                Text(
                  AppConstants.copyright,
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定', style: TextStyle(fontSize: 12)),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
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
          height: 32,
          child: Obx(() => Row(
            mainAxisSize: MainAxisSize.min,
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
          height: 32,
          child: Row(
            mainAxisSize: MainAxisSize.min,
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
          onTap: () => AppRouter.openSettings(configController),
        ),
        PopupMenuItem<void>(
          height: 32,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.checklist,
                size: 18,
                color: Colors.grey.shade700,
              ),
              const SizedBox(width: 8),
              const Text('待办事项'),
            ],
          ),
          onTap: () => AppRouter.openTodo(Get.find<TodoController>()),
        ),
        const PopupMenuDivider(height: 8),
        PopupMenuItem<void>(
          height: 32,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.close,
                size: 18,
                color: Colors.grey.shade700,
              ),
              const SizedBox(width: 8),
              const Text('退出'),
            ],
          ),
          onTap: () => windowManager.close(),
        ),
        const PopupMenuDivider(height: 8),
        PopupMenuItem<void>(
          height: 32,
          child: Row(
            mainAxisSize: MainAxisSize.min,
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
          onTap: () => Future(() => _showAboutDialog(context)),
        ),
      ],
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
