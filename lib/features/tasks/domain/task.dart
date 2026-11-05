enum Priority { low, medium, high }

enum TaskList { work, personal, school }

extension PriorityLabel on Priority {
  String get label => switch (this) {
        Priority.low => 'Low',
        Priority.medium => 'Medium',
        Priority.high => 'High',
      };
}

extension TaskListLabel on TaskList {
  String get label => switch (this) {
        TaskList.work => 'Work',
        TaskList.personal => 'Personal',
        TaskList.school => 'School',
      };
}

class Task {
  const Task({
    required this.id,
    required this.title,
    required this.priority,
    required this.list,
    this.notes = '',
    this.dueAt,
    this.isDone = false,
  });

  final int id;
  final String title;
  final String notes;
  final Priority priority;
  final TaskList list;
  final DateTime? dueAt;
  final bool isDone;

  Task copyWith({
    String? title,
    String? notes,
    Priority? priority,
    TaskList? list,
    DateTime? dueAt,
    bool? isDone,
  }) =>
      Task(
        id: id,
        title: title ?? this.title,
        notes: notes ?? this.notes,
        priority: priority ?? this.priority,
        list: list ?? this.list,
        dueAt: dueAt ?? this.dueAt,
        isDone: isDone ?? this.isDone,
      );
}