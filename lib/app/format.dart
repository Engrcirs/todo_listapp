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