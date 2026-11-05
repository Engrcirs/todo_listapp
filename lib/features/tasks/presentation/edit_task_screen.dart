import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_listapp/app/format.dart';
import 'package:todo_listapp/features/tasks/domain/task.dart';
import 'package:todo_listapp/features/tasks/presentation/task_providers.dart';

class EditTaskScreen extends ConsumerStatefulWidget {
  const EditTaskScreen({super.key, required this.taskId});

  final int taskId;

  @override
  ConsumerState<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends ConsumerState<EditTaskScreen> {
  late final TextEditingController _title;
  late final TextEditingController _notes;
  late Priority _priority;
  late TaskList _list;
  DateTime? _due;

  @override
  void initState() {
    super.initState();
    final t = ref.read(taskProvider(widget.taskId));
    _title = TextEditingController(text: t?.title ?? '');
    _notes = TextEditingController(text: t?.notes ?? '');
    _priority = t?.priority ?? Priority.medium;
    _list = t?.list ?? TaskList.work;
    _due = t?.dueAt;
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDue() async {
    final base = _due ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
    );
    if (time == null || !mounted) return;
    setState(() => _due = DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  void _save() {
    final current = ref.read(taskProvider(widget.taskId));
    final title = _title.text.trim();
    if (current == null || title.isEmpty) return;
    ref.read(tasksProvider.notifier).update(
          current.copyWith(
            title: title,
            notes: _notes.text.trim(),
            priority: _priority,
            list: _list,
            dueAt: _due,
          ),
        );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit task'), backgroundColor: Colors.transparent),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Task', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notes,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            const Text('Due', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            OutlinedButton.icon(
              onPressed: _pickDue,
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text(formatDue(context, _due)),
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            ),
            const SizedBox(height: 16),
            const Text('Priority', style: TextStyle(fontWeight: FontWeight.w700)),
            Wrap(
              spacing: 8,
              children: [
                for (final p in Priority.values)
                  ChoiceChip(
                    label: Text(p.label),
                    selected: _priority == p,
                    onSelected: (_) => setState(() => _priority = p),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('List', style: TextStyle(fontWeight: FontWeight.w700)),
            Wrap(
              spacing: 8,
              children: [
                for (final l in TaskList.values)
                  ChoiceChip(
                    label: Text(l.label),
                    selected: _list == l,
                    onSelected: (_) => setState(() => _list = l),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: const Text('Save changes')),
          ],
        ),
      ),
    );
  }
}