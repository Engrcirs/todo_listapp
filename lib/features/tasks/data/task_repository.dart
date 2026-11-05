import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_listapp/features/tasks/domain/task.dart';

class TaskRepository {
  TaskRepository(this._prefs);

  final SharedPreferences _prefs;
  static const _key = 'tasks_v1';

  /// Returns null when nothing has been saved yet (first launch).
  List<Task>? load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return [for (final e in list) Task.fromJson(e as Map<String, dynamic>)];
    } catch (_) {
      return null;
    }
  }

  Future<void> save(List<Task> tasks) =>
      _prefs.setString(_key, jsonEncode([for (final t in tasks) t.toJson()]));
}