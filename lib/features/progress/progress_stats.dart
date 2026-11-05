import 'package:todo_listapp/features/tasks/domain/task.dart';

DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

class DayCount {
  const DayCount(this.day, this.count);

  final DateTime day;
  final int count;
}

/// Tasks completed on each of the last [days] days, oldest first.
List<DayCount> lastDays(List<Task> tasks, {int days = 7}) {
  final today = _dayOnly(DateTime.now());
  return [
    for (var i = days - 1; i >= 0; i--)
      () {
        final day = DateTime(today.year, today.month, today.day - i);
        final count = tasks
            .where((t) => t.completedAt != null && _dayOnly(t.completedAt!) == day)
            .length;
        return DayCount(day, count);
      }(),
  ];
}

/// Consecutive days with at least one completed task. If nothing is done
/// yet today, the streak still counts up to yesterday.
int currentStreak(List<Task> tasks) {
  final days = {
    for (final t in tasks)
      if (t.completedAt != null) _dayOnly(t.completedAt!),
  };
  final today = _dayOnly(DateTime.now());
  var day = days.contains(today)
      ? today
      : DateTime(today.year, today.month, today.day - 1);
  var streak = 0;
  while (days.contains(day)) {
    streak++;
    day = DateTime(day.year, day.month, day.day - 1);
  }
  return streak;
}