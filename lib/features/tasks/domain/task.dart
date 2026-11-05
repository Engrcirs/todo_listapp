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
    this.dueAt,
    this.isDone = false,
  });

  final int id;
  final String title;
  final Priority priority;
  final TaskList list;
  final DateTime? dueAt;
  final bool isDone;

  Task copyWith({bool? isDone}) => Task(
        id: id,
        title: title,
        priority: priority,
        list: list,
        dueAt: dueAt,
        isDone: isDone ?? this.isDone,
      );
}