import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/app_config_controller.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class SettingsDialog extends StatelessWidget {
  final AppConfigController configController;

  const SettingsDialog({
    super.key,
    required this.configController,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 260,
          maxHeight: 180,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题行
              const Row(
                children: [
                  Icon(Icons.settings, size: 16),
                  SizedBox(width: 4),
                  Text('更多设置', style: TextStyle(fontSize: 13)),
                ],
              ),
              const SizedBox(height: 6),
              // 颜色设置部分
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildColorSection(
                        '标题栏颜色',
                        configController.appBarColor.value,
                            (color) => configController.updateAppBarColor(color),
                      ),
                      const SizedBox(height: 6),
                      _buildColorSection(
                        '背景颜色',
                        configController.bodyColor.value,
                            (color) => configController.updateBodyColor(color),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // 按钮行
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('确定', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ),
      ),
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
          Text(title, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 8),
          Expanded(
            child: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 280,
                        maxHeight: 360,
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
                                pickerColor: currentColor,
                                onColorChanged: onColorChanged,
                                pickerAreaHeightPercent: 0.7,
                                enableAlpha: false,
                                displayThumbColor: true,
                                paletteType: PaletteType.hsvWithHue,
                                labelTypes: const [],
                                pickerAreaBorderRadius: const BorderRadius.all(Radius.circular(6)),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('确定', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              child: Container(
                height: 24,
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