import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';
import '../controllers/todo_controller.dart';
import '../models/todo_item.dart';
import '../constants/app_constants.dart';
import '../controllers/app_config_controller.dart';

class TodoPage extends StatefulWidget {
  final TodoController todoController;
  static const double todoPageHeight = 400;

  const TodoPage({
    super.key,
    required this.todoController,
  });

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final TextEditingController _textController = TextEditingController();
  final AppConfigController configController = Get.find<AppConfigController>();

  @override
  void initState() {
    super.initState();
    configController.isNotInMainPage.value = true;
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Size size = await windowManager.getSize();
      await windowManager.setSize(Size(
        size.width,
        size.height + TodoPage.todoPageHeight
      ));
    });
  }

  @override
  void dispose() {
    configController.isNotInMainPage.value = false;
    _textController.dispose();
    super.dispose();
  }

  void _setTodoAsTitle(TodoItem todo) {
    for (var item in widget.todoController.todos) {
      item.isCurrentTitle = item.id == todo.id;
    }
    configController.updateTitleText(todo.title);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Size size = await windowManager.getSize();
        await windowManager.setSize(Size(
          size.width,
          size.height - TodoPage.todoPageHeight
        ));
        configController.isNotInMainPage.value = false;
        return true;
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanStart: (_) => windowManager.startDragging(),
            child: AppBar(
              title: const Text('待办事项', style: TextStyle(fontSize: 14)),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () async {
                  Size size = await windowManager.getSize();
                  await windowManager.setSize(Size(
                    size.width,
                    size.height - TodoPage.todoPageHeight
                  ));
                  configController.isNotInMainPage.value = false;
                  if (context.mounted) {
                    Get.back();
                  }
                },
              ),
            ),
          ),
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onPanStart: (_) => windowManager.startDragging(),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          decoration: const InputDecoration(
                            hintText: '添加新的待办事项...',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (_textController.text.isNotEmpty) {
                            widget.todoController.addTodo(_textController.text);
                            _textController.clear();
                          }
                        },
                        child: const Text('添加'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Obx(() => ListView.builder(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    itemCount: widget.todoController.todos.length,
                    itemBuilder: (context, index) {
                      final TodoItem todo = widget.todoController.todos[index];
                      return ListTile(
                        leading: Checkbox(
                          value: todo.isCompleted,
                          onChanged: (_) => widget.todoController.toggleTodo(todo.id),
                        ),
                        title: Text(
                          todo.title,
                          style: TextStyle(
                            fontSize: 14,
                            decoration: todo.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: todo.isCompleted
                                ? Colors.grey
                                : null,
                          ),
                        ),
                        subtitle: Text(
                          todo.createdAt.toString().substring(0, 16),
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.title,
                                color: todo.isCurrentTitle && configController.titleText.value == todo.title 
                                    ? Colors.blue 
                                    : null,
                              ),
                              onPressed: () => _setTodoAsTitle(todo),
                              tooltip: (todo.isCurrentTitle && configController.titleText.value == todo.title)
                                  ? '当前标题' 
                                  : '设为标题',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => widget.todoController.removeTodo(todo.id),
                            ),
                          ],
                        ),
                      );
                    },
                  )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 