import 'package:get/get.dart';
import '../pages/settings_page.dart';
import '../pages/todo_page.dart';
import '../controllers/app_config_controller.dart';
import '../controllers/todo_controller.dart';

/// Thin navigation facade that centralises transition configuration.
///
/// Before this module, the transition type, duration, and page constructors
/// were duplicated across HotkeyManager, TodoController, and AppContextMenu.
/// Now every caller says `AppRouter.openXxx(…)` — one place to change.
class AppRouter {
  AppRouter._();

  static void openSettings(AppConfigController configController) {
    Get.to(
      () => SettingsPage(configController: configController),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 250),
    );
  }

  static void openTodo(TodoController todoController) {
    Get.to(
      () => TodoPage(todoController: todoController),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 250),
    );
  }

  static void goBack() {
    Get.back();
  }
}
