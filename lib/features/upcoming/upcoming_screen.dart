import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_listapp/app/format.dart';
import 'package:todo_listapp/features/tasks/domain/task.dart';
import 'package:todo_listapp/features/tasks/presentation/task_providers.dart';
import 'package:todo_listapp/features/tasks/presentation/widgets/task_tile.dart';

class UpcomingScreen extends ConsumerWidget {
  const UpcomingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(upcomingTasksProvider);

    final groups = <DateTime, List<Task>>{};
    for (final t in tasks) {
      groups.putIfAbsent(dayOnly(t.dueAt!), () => []).add(t);
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            const Text('Upcoming', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            if (tasks.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Column(
                  children: [
                    Icon(Icons.event_available_outlined, size: 56, color: Color(0xFF0F766E)),
                    SizedBox(height: 16),
                    Text('Nothing coming up', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                    SizedBox(height: 6),
                    Text(
                      'Tasks due after today will appear here.',
                      style: TextStyle(color: Color(0xFF4B5A54)),
                    ),
                  ],
                ),
              )
            else
              for (final entry in groups.entries) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 14, bottom: 8),
                  child: Text(
                    formatDay(entry.key).toUpperCase(),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF4B5A54)),
                  ),
                ),
                for (final t in entry.value)
                  GestureDetector(
                    onTap: () => context.push('/task/${t.id}'),
                    child: TaskTile(task: t),
                  ),
              ],
          ],
        ),
      ),
    );
  }
}