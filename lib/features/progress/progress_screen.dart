import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_listapp/features/progress/progress_stats.dart';
import 'package:todo_listapp/features/tasks/domain/task.dart';
import 'package:todo_listapp/features/tasks/presentation/task_providers.dart';
import 'package:todo_listapp/features/tasks/presentation/widgets/task_tile.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider);
    final done = tasks.where((t) => t.isDone).length;
    final remaining = tasks.length - done;
    final percent = tasks.isEmpty ? 0 : (done * 100 / tasks.length).round();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            const Text('Progress', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$percent%', style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w700)),
                  const Text('of your tasks are done', style: TextStyle(color: Colors.white, fontSize: 15)),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: tasks.isEmpty ? 0 : done / tasks.length,
                      minHeight: 8,
                      backgroundColor: Colors.white30,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _Stat(label: 'Done', value: done)),
                const SizedBox(width: 12),
                Expanded(child: _Stat(label: 'Remaining', value: remaining)),
              ],
            ),
            const SizedBox(height: 12),
            _WeekCard(days: lastDays(tasks), streak: currentStreak(tasks)),
            const SizedBox(height: 20),
            const Text(
              'REMAINING BY PRIORITY',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF4B5A54)),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE1E7E2)),
              ),
              child: Column(
                children: [
                  for (final p in Priority.values.reversed)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(color: priorityColor(p), shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(p.label, style: const TextStyle(fontSize: 15))),
                          Text(
                            '${tasks.where((t) => !t.isDone && t.priority == p).length}',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekCard extends StatelessWidget {
  const _WeekCard({required this.days, required this.streak});

  final List<DayCount> days;
  final int streak;

  static const _initials = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final maxCount = days.fold<int>(0, (m, d) => d.count > m ? d.count : m);
    final primary = Theme.of(context).colorScheme.primary;
    final streakText = streak == 0 ? 'No streak yet' : '$streak day streak';

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE1E7E2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Last 7 days', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              Text(streakText, style: const TextStyle(fontSize: 13, color: Color(0xFF4B5A54))),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 130,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < days.length; i++)
                  Expanded(
                    child: Semantics(
                      label: '${days[i].count} tasks completed',
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (days[i].count > 0)
                            Text('${days[i].count}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Container(
                            width: 28,
                            height: maxCount == 0 ? 4 : 4 + 76 * days[i].count / maxCount,
                            decoration: BoxDecoration(
                              color: i == days.length - 1 ? primary : const Color(0xFF9CC9C3),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _initials[days[i].day.weekday - 1],
                            style: const TextStyle(fontSize: 13, color: Color(0xFF4B5A54)),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE1E7E2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$value', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF4B5A54))),
        ],
      ),
    );
  }
}