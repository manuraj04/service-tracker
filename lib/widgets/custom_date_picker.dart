import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomDatePicker {
  static Future<DateTime?> pickDate(BuildContext context, DateTime initialDate) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 10),
    );
    return picked;
  }

  static String format(DateTime date) => DateFormat.yMMMd().format(date);
}
