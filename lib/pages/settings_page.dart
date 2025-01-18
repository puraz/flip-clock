import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import '../constants/app_constants.dart';
import '../controllers/app_config_controller.dart';
import 'package:window_manager/window_manager.dart';

class SettingsPage extends StatelessWidget {
  final AppConfigController configController;
  static const double settingsPageHeight = 400;

  const SettingsPage({
    super.key,
    required this.configController,
  });

  @override
  Widget build(BuildContext context) {
    // 在页面构建时增加窗口高度并设置标志
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      configController.isInSettingsPage.value = true;
      Size size = await windowManager.getSize();
      await windowManager.setSize(Size(
          size.width,
          size.height + settingsPageHeight
      ));
    });

    return WillPopScope(
      onWillPop: () async {
        Size size = await windowManager.getSize();
        double baseHeight = configController.showAppBar.value
            ? AppConstants.windowHeight + AppConstants.titleBarHeight
            : AppConstants.windowHeight;

        await windowManager.setSize(Size(
            size.width,
            baseHeight
        ));
        configController.isInSettingsPage.value = false;
        return true;
      },
      // 使用 Obx 包装整个 Scaffold
      child: Obx(() => Scaffold(
        appBar: AppBar(
          title: const Text('设置'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              Size size = await windowManager.getSize();
              double baseHeight = configController.showAppBar.value
                  ? AppConstants.windowHeight + AppConstants.titleBarHeight
                  : AppConstants.windowHeight;

              await windowManager.setSize(Size(
                  size.width,
                  baseHeight
              ));

              if (context.mounted) {
                Get.back();
                configController.isInSettingsPage.value = false;
              }
            },
          ),
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onPanStart: (_) => windowManager.startDragging(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.visibility),
                  title: const Text('显示标题栏'),
                  trailing: Switch(
                    value: configController.showAppBar.value,
                    onChanged: (value) => configController.toggleAppBarWithoutResize(value),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('外观设置',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                      ),
                      const SizedBox(height: 16),
                      _buildColorSection(
                        '标题颜色',
                        configController.appBarColor.value,
                            (color) => configController.updateAppBarColor(color),
                      ),
                      const SizedBox(height: 16),
                      _buildColorSection(
                        '背景颜色',
                        configController.bodyColor.value,
                            (color) => configController.updateBodyColor(color),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }

  Widget _buildColorSection(
      String title,
      Color currentColor,
      void Function(Color) onColorChanged,
      ) {
    return Builder(
      builder: (BuildContext context) => Row(
        children: [
          Text(title),
          const SizedBox(width: 16),
          Expanded(
            child: InkWell(
              onTap: () {
                Color pickerColor = currentColor;
                showDialog(
                  context: context,
                  builder: (context) => StatefulBuilder(
                    builder: (context, setState) => Dialog(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 250,
                          maxHeight: 380,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(title, style: const TextStyle(fontSize: 13)),
                              const SizedBox(height: 8),
                              Flexible(
                                child: ColorPicker(
                                  pickerColor: pickerColor,
                                  onColorChanged: (color) {
                                    setState(() => pickerColor = color);
                                  },
                                  pickerAreaHeightPercent: 0.7,
                                  enableAlpha: false,
                                  displayThumbColor: true,
                                  paletteType: PaletteType.hsvWithHue,
                                  labelTypes: const [],
                                  pickerAreaBorderRadius: const BorderRadius.all(Radius.circular(6)),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  onColorChanged(pickerColor);
                                  Navigator.of(context).pop();
                                },
                                child: const Text('确定'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
              child: Container(
                height: 32,
                decoration: BoxDecoration(
                  color: currentColor,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey.shade300),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}