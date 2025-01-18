import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/app_config_controller.dart';

class SettingsPage extends StatelessWidget {
  final AppConfigController configController;

  const SettingsPage({
    super.key,
    required this.configController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 在这里添加你的设置选项
          // 例如：
          Card(
            child: ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('显示标题栏'),
              trailing: Obx(
                () => Switch(
                  value: configController.showAppBar.value,
                  onChanged: (value) => configController.toggleAppBar(),
                ),
              ),
            ),
          ),
          // 添加更多设置项...
        ],
      ),
    );
  }
} 