import 'dart:convert';
import 'package:get/get.dart';
import '../models/todo_item.dart';
import '../pages/todo_page.dart';
import '../utils/preferences_manager.dart';

class TodoController extends GetxController {
  final RxList<TodoItem> todos = <TodoItem>[].obs;
  final RxBool showTodoPanel = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTodos();
  }

  void toggleTodoPanel() {
    showTodoPanel.value = !showTodoPanel.value;
     Get.to(
      () => TodoPage(todoController: this),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 250),
    );
  }

  void addTodo(String title) {
    if (title.trim().isEmpty) return;
    
    final todo = TodoItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      createdAt: DateTime.now(),
    );
    
    todos.add(todo);
    _saveTodos();
  }

  void toggleTodo(String id) {
    final index = todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      todos[index].isCompleted = !todos[index].isCompleted;
      todos.refresh();
      _saveTodos();
    }
  }

  void removeTodo(String id) {
    todos.removeWhere((todo) => todo.id == id);
    _saveTodos();
  }

  void _loadTodos() {
    try {
      final String? todosJson = PreferencesManager.getString('todos');
      if (todosJson != null && todosJson.isNotEmpty) {
        final List<dynamic> decoded = json.decode(todosJson);
        todos.value = decoded.map((item) => TodoItem.fromJson(item)).toList();
      } else {
        todos.value = [];  // 确保使用空列表作为默认值
      }
    } catch (e) {
      print('加载待办事项时出错: $e');
      todos.value = [];  // 发生错误时使用空列表
      // 清除可能损坏的数据
      PreferencesManager.remove('todos');
    }
  }

  void _saveTodos() {
    final String encoded = json.encode(todos.map((todo) => todo.toJson()).toList());
    PreferencesManager.setString('todos', encoded);
  }
} 