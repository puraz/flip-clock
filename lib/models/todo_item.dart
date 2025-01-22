class TodoItem {
  final String id;
  final String title;
  bool isCompleted;
  final DateTime createdAt;
  bool isCurrentTitle;

  TodoItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.createdAt,
    this.isCurrentTitle = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'],
      title: json['title'],
      isCompleted: json['isCompleted'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
} 