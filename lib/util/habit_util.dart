// is habit completed today in the list
import 'package:habit_tracker/models/habit.dart';

bool isHabitCompletedToday(List<DateTime> completedDays) {
  final today = DateTime.now();
  return completedDays.any(
    (date) =>
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day,
  );
}

// prepare heat map dataset

Map<DateTime, int> prepHeatMapDataSet(List<Habit> habits) {
  Map<DateTime, int> dataset = {};

  for (var habit in habits) {
    for (var date in habit.completeDays) {
      final normalizedDate = DateTime(
        date.year,
        date.month,
        date.day,
      ); // normalize date and time to avoid miss match
      if (dataset.containsKey(normalizedDate)) {
        dataset[normalizedDate] =
            dataset[normalizedDate]! + 1; // increment count
      } else {
        dataset[normalizedDate] = 1; // first entry
      }
    }
  }
  return dataset;
}
