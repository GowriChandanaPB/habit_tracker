import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

// run: dart run build_runner build
part 'habit.g.dart';

@Collection()
class Habit {
  Id id = Isar.autoIncrement; // habit id
  late String name; // habit name
  List<DateTime> completeDays = [
    //date-time(year, month, day)
    //date-time(2024, 1, 1)
    //date-time(2024, 1, 2)
  ];
}
