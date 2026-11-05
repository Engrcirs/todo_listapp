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
    this.completedAt,
  });

  final int id;
  final String title;
  final String notes;
  final Priority priority;
  final TaskList list;
  final DateTime? dueAt;
  final bool isDone;
  final DateTime? completedAt;

  Task copyWith({
    String? title,
    String? notes,
    Priority? priority,
    TaskList? list,
    DateTime? dueAt,
    bool? isDone,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) =>
      Task(
        id: id,
        title: title ?? this.title,
        notes: notes ?? this.notes,
        priority: priority ?? this.priority,
        list: list ?? this.list,
        dueAt: dueAt ?? this.dueAt,
        isDone: isDone ?? this.isDone,
        completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'notes': notes,
        'priority': priority.name,
        'list': list.name,
        'dueAt': dueAt?.toIso8601String(),
        'isDone': isDone,
        'completedAt': completedAt?.toIso8601String(),
      };

  factory Task.fromJson(Map<String, dynamic> j) => Task(
        id: j['id'] as int,
        title: j['title'] as String,
        notes: (j['notes'] as String?) ?? '',
        priority: Priority.values.byName(j['priority'] as String),
        list: TaskList.values.byName(j['list'] as String),
        dueAt: j['dueAt'] == null ? null : DateTime.parse(j['dueAt'] as String),
        isDone: j['isDone'] as bool,
        completedAt: j['completedAt'] == null ? null : DateTime.parse(j['completedAt'] as String),
      );
}