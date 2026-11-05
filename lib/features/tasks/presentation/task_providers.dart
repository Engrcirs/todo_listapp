import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_listapp/features/tasks/domain/task.dart';

DateTime _today(int hour, int minute) {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day, hour, minute);
}

class TaskNotifier extends Notifier<List<Task>> {
  int _nextId = 6;

  @override
  List<Task> build() => [
        Task(id: 1, title: 'Review lecture notes', priority: Priority.medium, list: TaskList.school, dueAt: _today(9, 0)),
        Task(id: 2, title: 'Reply to client emails', priority: Priority.low, list: TaskList.work, dueAt: _today(11, 30)),
        Task(id: 3, title: 'Buy groceries', priority: Priority.low, list: TaskList.personal, dueAt: _today(17, 0)),
        Task(id: 4, title: 'Draft project proposal', priority: Priority.high, list: TaskList.work, dueAt: _today(20, 0)),
        Task(id: 5, title: 'Morning workout', priority: Priority.low, list: TaskList.personal, dueAt: _today(7, 0), isDone: true),
      ];

  void add(String title, Priority priority, TaskList list) {
    state = [...state, Task(id: _nextId++, title: title, priority: priority, list: list)];
  }

  void toggle(int id) {
    state = [
      for (final t in state)
        if (t.id == id) t.copyWith(isDone: !t.isDone) else t,
    ];
  }

  void remove(int id) {
    state = state.where((t) => t.id != id).toList();
  }
}

final tasksProvider = NotifierProvider<TaskNotifier, List<Task>>(TaskNotifier.new);

class FilterNotifier extends Notifier<TaskList?> {
  @override
  TaskList? build() => null;

  void select(TaskList? list) => state = list;
}

final filterProvider = NotifierProvider<FilterNotifier, TaskList?>(FilterNotifier.new);

final visibleTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(tasksProvider);
  final filter = ref.watch(filterProvider);
  return filter == null ? tasks : tasks.where((t) => t.list == filter).toList();
});