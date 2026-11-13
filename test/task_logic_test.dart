import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_listapp/features/tasks/data/task_repository.dart';
import 'package:todo_listapp/features/tasks/domain/task.dart';
import 'package:todo_listapp/features/tasks/presentation/task_providers.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('TaskRepository', () {
    test('load returns null on first launch', () async {
      final repo = TaskRepository(await SharedPreferences.getInstance());
      expect(repo.load(), isNull);
    });

    test('saved tasks load back with the same values', () async {
      final repo = TaskRepository(await SharedPreferences.getInstance());
      final due = DateTime(2026, 11, 5, 9, 30);
      await repo.save([
        Task(
          id: 7,
          title: 'Write report',
          notes: 'Two pages',
          priority: Priority.high,
          list: TaskList.school,
          dueAt: due,
          isDone: true,
          completedAt: due,
        ),
      ]);

      final loaded = repo.load()!;
      expect(loaded.length, 1);
      expect(loaded.first.id, 7);
      expect(loaded.first.title, 'Write report');
      expect(loaded.first.notes, 'Two pages');
      expect(loaded.first.priority, Priority.high);
      expect(loaded.first.list, TaskList.school);
      expect(loaded.first.dueAt, due);
      expect(loaded.first.isDone, isTrue);
      expect(loaded.first.completedAt, due);
    });

    test('an empty saved list is not treated as first launch', () async {
      final repo = TaskRepository(await SharedPreferences.getInstance());
      await repo.save([]);
      expect(repo.load(), isEmpty);
    });

    test('corrupt data returns null instead of crashing', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('tasks_v1', 'not json');
      expect(TaskRepository(prefs).load(), isNull);
    });
  });

  group('TaskNotifier', () {
    Future<ProviderContainer> makeContainer() async {
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('completing a task sets completedAt, undoing clears it', () async {
      final container = await makeContainer();
      final notifier = container.read(tasksProvider.notifier);

      notifier.toggle(1);
      expect(container.read(taskProvider(1))!.isDone, isTrue);
      expect(container.read(taskProvider(1))!.completedAt, isNotNull);

      notifier.toggle(1);
      expect(container.read(taskProvider(1))!.isDone, isFalse);
      expect(container.read(taskProvider(1))!.completedAt, isNull);
    });

    test('add creates a task with a new id', () async {
      final container = await makeContainer();
      final notifier = container.read(tasksProvider.notifier);
      final before = container.read(tasksProvider).length;

      notifier.add('Call the bank', Priority.high, TaskList.personal);

      final tasks = container.read(tasksProvider);
      expect(tasks.length, before + 1);
      expect(tasks.last.title, 'Call the bank');
      expect(tasks.map((t) => t.id).toSet().length, tasks.length);
    });

    test('update changes only the edited task', () async {
      final container = await makeContainer();
      final notifier = container.read(tasksProvider.notifier);
      final original = container.read(taskProvider(2))!;

      notifier.update(original.copyWith(title: 'Reply to all emails'));

      expect(container.read(taskProvider(2))!.title, 'Reply to all emails');
      expect(container.read(taskProvider(1))!.title, 'Review lecture notes');
    });

    test('remove deletes a task and restore brings it back', () async {
      final container = await makeContainer();
      final notifier = container.read(tasksProvider.notifier);
      final task = container.read(taskProvider(3))!;

      notifier.remove(3);
      expect(container.read(taskProvider(3)), isNull);

      notifier.restore(task);
      expect(container.read(taskProvider(3))?.title, task.title);
    });

    test('changes are saved and reloaded by a new container', () async {
      final first = await makeContainer();
      first.read(tasksProvider.notifier).remove(1);

      final second = await makeContainer();
      expect(second.read(taskProvider(1)), isNull);
    });
  });
}