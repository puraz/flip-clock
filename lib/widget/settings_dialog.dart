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
    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(14, 6, 8, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 8, 6),
      title: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.settings, size: 18),
          SizedBox(width: 8),
          Text('更多设置', style: TextStyle(fontSize: 14)),
        ],
      ),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildColorSection(
              '标题栏颜色',
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
    );
  }

  Widget _buildColorSection(
    String title,
    Color currentColor,
    void Function(Color) onColorChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            Get.dialog(
              AlertDialog(
                title: Text(title),
                content: SingleChildScrollView(
                  child: ColorPicker(
                    pickerColor: currentColor,
                    onColorChanged: onColorChanged,
                    pickerAreaHeightPercent: 0.8,
                    enableAlpha: false,
                    displayThumbColor: true,
                    paletteType: PaletteType.hsvWithHue,
                    labelTypes: const [],
                    pickerAreaBorderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('确定'),
                  ),
                ],
              ),
            );
          },
          child: Container(
            width: double.infinity,
            height: 36,
            decoration: BoxDecoration(
              color: currentColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }
} 