import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_listapp/app/format.dart';
import 'package:todo_listapp/features/tasks/domain/task.dart';
import 'package:todo_listapp/features/tasks/presentation/task_providers.dart';

void showAddTaskSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const AddTaskSheet(),
  );
}

DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

class AddTaskSheet extends ConsumerStatefulWidget {
  const AddTaskSheet({super.key});

  @override
  ConsumerState<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends ConsumerState<AddTaskSheet> {
  final _controller = TextEditingController();
  Priority _priority = Priority.medium;
  TaskList _list = TaskList.work;
  DateTime _date = _dayOnly(DateTime.now());
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = _dayOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isBefore(today) ? today : _date,
      firstDate: today,
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = _dayOnly(picked));
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  void _submit() {
    final title = _controller.text.trim();
    if (title.isEmpty) return;
    final due = DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);
    ref.read(tasksProvider.notifier).add(title, _priority, _list, dueAt: due);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final today = _dayOnly(DateTime.now());
    final tomorrow = DateTime(today.year, today.month, today.day + 1);
    final isToday = _date == today;
    final isTomorrow = _date == tomorrow;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('New task', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            decoration: const InputDecoration(
              labelText: 'Task',
              hintText: 'What needs doing?',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Due', style: TextStyle(fontWeight: FontWeight.w700)),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Today'),
                selected: isToday,
                onSelected: (_) => setState(() => _date = today),
              ),
              ChoiceChip(
                label: const Text('Tomorrow'),
                selected: isTomorrow,
                onSelected: (_) => setState(() => _date = tomorrow),
              ),
              ChoiceChip(
                avatar: const Icon(Icons.calendar_today_outlined, size: 18),
                label: Text(isToday || isTomorrow ? 'Pick date' : formatDate(_date)),
                selected: !isToday && !isTomorrow,
                onSelected: (_) => _pickDate(),
              ),
              ActionChip(
                avatar: const Icon(Icons.access_time, size: 18),
                label: Text(_time.format(context)),
                onPressed: _pickTime,
              ),
            ],
          ),
          const SizedBox(height: 12),
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
          const SizedBox(height: 20),
          FilledButton(onPressed: _submit, child: const Text('Add task')),
        ],
      ),
    );
  }
}