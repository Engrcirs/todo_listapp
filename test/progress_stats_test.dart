import 'package:flutter_test/flutter_test.dart';
import 'package:todo_listapp/features/progress/progress_stats.dart';
import 'package:todo_listapp/features/tasks/domain/task.dart';

Task _done(int id, DateTime at) => Task(
      id: id,
      title: 'Task $id',
      priority: Priority.low,
      list: TaskList.work,
      isDone: true,
      completedAt: at,
    );

void main() {
  final now = DateTime.now();
  DateTime daysAgo(int n) => DateTime(now.year, now.month, now.day - n, 12);

  group('currentStreak', () {
    test('is 0 with no completed tasks', () {
      expect(currentStreak([]), 0);
    });

    test('counts consecutive days ending today', () {
      final tasks = [_done(1, daysAgo(0)), _done(2, daysAgo(1)), _done(3, daysAgo(2))];
      expect(currentStreak(tasks), 3);
    });

    test('still counts up to yesterday when nothing is done today', () {
      final tasks = [_done(1, daysAgo(1)), _done(2, daysAgo(2))];
      expect(currentStreak(tasks), 2);
    });

    test('stops at a gap', () {
      final tasks = [_done(1, daysAgo(0)), _done(2, daysAgo(2))];
      expect(currentStreak(tasks), 1);
    });

    test('several tasks on the same day count as one day', () {
      final tasks = [_done(1, daysAgo(0)), _done(2, daysAgo(0)), _done(3, daysAgo(0))];
      expect(currentStreak(tasks), 1);
    });
  });

  group('lastDays', () {
    test('returns 7 days, oldest first, with today last', () {
      final days = lastDays([]);
      expect(days.length, 7);
      expect(days.last.day, DateTime(now.year, now.month, now.day));
      expect(days.first.day, DateTime(now.year, now.month, now.day - 6));
    });

    test('counts completions per day', () {
      final tasks = [_done(1, daysAgo(0)), _done(2, daysAgo(0)), _done(3, daysAgo(2))];
      final days = lastDays(tasks);
      expect(days.last.count, 2);
      expect(days[4].count, 1);
      expect(days[5].count, 0);
    });

    test('ignores tasks completed more than 7 days ago', () {
      final days = lastDays([_done(1, daysAgo(10))]);
      expect(days.every((d) => d.count == 0), isTrue);
    });
  });
}