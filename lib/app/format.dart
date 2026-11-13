import 'package:flutter/material.dart';

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String formatDue(BuildContext context, DateTime? d) {
  if (d == null) return 'No due date';
  final now = DateTime.now();
  final isToday = d.year == now.year && d.month == now.month && d.day == now.day;
  final time = TimeOfDay.fromDateTime(d).format(context);
  if (isToday) return 'Today, $time';
  return '${_months[d.month - 1]} ${d.day}, $time';
}
String formatDate(DateTime d) => '${_months[d.month - 1]} ${d.day}';
const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

String formatDay(DateTime d) {
  final now = DateTime.now();
  final tomorrow = DateTime(now.year, now.month, now.day + 1);
  final day = DateTime(d.year, d.month, d.day);
  if (day == tomorrow) return 'Tomorrow';
  return '${_weekdays[day.weekday - 1]}, ${_months[day.month - 1]} ${day.day}';
}