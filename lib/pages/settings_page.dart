import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import '../constants/app_constants.dart';
import '../controllers/app_config_controller.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:math';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class SettingsPage extends StatefulWidget {
  final AppConfigController configController;
  static const double settingsPageHeight = 400;

  const SettingsPage({
    super.key,
    required this.configController,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _countdownController;
  // 获取配置控制器
  final AppConfigController configController = Get.put(AppConfigController());

  @override
  void initState() {
    super.initState();
    // 初始化时创建 controller 并设置初始值
    _countdownController = TextEditingController(
        text: configController.countdownMinutes.value.toString()
    );
  }

  @override
  void dispose() {
    // 记得在页面销毁时释放 controller
    _countdownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 在页面构建时增加窗口高度并设置标志
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      widget.configController.isNotInMainPage.value = true;
      Size size = await windowManager.getSize();
      await windowManager.setSize(Size(
          size.width,
          size.height + SettingsPage.settingsPageHeight
      ));
    });

    return WillPopScope(
      onWillPop: () async {
        Size size = await windowManager.getSize();
        double baseHeight = widget.configController.showAppBar.value
            ? AppConstants.windowHeight + AppConstants.titleBarHeight
            : AppConstants.windowHeight;

        await windowManager.setSize(Size(
            size.width,
            baseHeight
        ));
        widget.configController.isNotInMainPage.value = false;
        return true;
      },
      // 使用 Obx 包装整个 Scaffold
      child: Obx(() => Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanStart: (_) => windowManager.startDragging(),
            child: AppBar(
              title: const Text('设置'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () async {
                  Size size = await windowManager.getSize();
                  double baseHeight = widget.configController.showAppBar.value
                      ? AppConstants.windowHeight + AppConstants.titleBarHeight
                      : AppConstants.windowHeight;

                  await windowManager.setSize(Size(
                      size.width,
                      baseHeight
                  ));

                  if (context.mounted) {
                    Get.back();
                    widget.configController.isNotInMainPage.value = false;
                  }
                },
              ),
            ),
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
                    value: widget.configController.showAppBar.value,
                    onChanged: (value) => widget.configController.toggleAppBarWithoutResize(value),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('外观设置',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                          ),
                          TextButton.icon(
                            onPressed: () {
                              final random = Random();
                              
                              // 生成基础色相 (0-360)
                              final baseHue = random.nextDouble() * 360;
                              
                              // 生成标题栏颜色 - 使用较深的颜色
                              final appBarColor = HSVColor.fromAHSV(
                                1.0,                    // alpha
                                baseHue,               // hue
                                0.6 + random.nextDouble() * 0.2,  // saturation: 0.6-0.8
                                0.8 + random.nextDouble() * 0.2,  // value: 0.8-1.0
                              ).toColor();
                              
                              // 生成背景颜色 - 使用较浅的颜色
                              final bodyColor = HSVColor.fromAHSV(
                                1.0,
                                (baseHue + 30) % 360,  // 稍微偏移色相
                                0.1 + random.nextDouble() * 0.2,  // saturation: 0.1-0.3
                                0.9 + random.nextDouble() * 0.1,  // value: 0.9-1.0
                              ).toColor();
                              
                              // 生成时钟背景颜色 - 使用互补或相近色
                              final clockBgColor = HSVColor.fromAHSV(
                                1.0,
                                (baseHue + 180) % 360, // 互补色
                                0.3 + random.nextDouble() * 0.3,  // saturation: 0.3-0.6
                                0.8 + random.nextDouble() * 0.2,  // value: 0.8-1.0
                              ).toColor();
                              
                              // 更新颜色
                              widget.configController.updateAppBarColor(appBarColor);
                              widget.configController.updateBodyColor(bodyColor);
                              widget.configController.updateClockBackgroundColor(clockBgColor);
                            },
                            icon: const Icon(Icons.shuffle, size: 20),
                            label: const Text('随机外观'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildColorSection(
                        '标题颜色',
                        widget.configController.appBarColor.value,
                            (color) => widget.configController.updateAppBarColor(color),
                      ),
                      const SizedBox(height: 16),
                      _buildColorSection(
                        '背景颜色',
                        widget.configController.bodyColor.value,
                            (color) => widget.configController.updateBodyColor(color),
                      ),
                      const SizedBox(height: 16),
                      _buildColorSection(
                        '时钟背景颜色',
                        widget.configController.clockBackgroundColor.value,
                        (color) => widget.configController.updateClockBackgroundColor(color),
                      ),
                    ],
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
                      const Text('时钟设置',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text('显示模式'),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButton<bool>(
                              value: widget.configController.isCountdownMode.value,
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(
                                  value: false,
                                  child: Text('时钟'),
                                ),
                                DropdownMenuItem(
                                  value: true,
                                  child: Text('倒计时'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  widget.configController.isCountdownMode.value = value;
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (widget.configController.isCountdownMode.value) ...[
                        Row(
                          children: [
                            const Text('倒计时时间（分钟）'),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                controller: _countdownController,
                                onChanged: (value) {
                                  final minutes = int.tryParse(value);
                                  if (minutes != null && minutes > 0) {
                                    widget.configController.countdownMinutes.value = minutes;
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
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
          SizedBox(
            width: 100,
            child: Text(title),
          ),
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