import 'package:flutter/material.dart';
import 'package:habit_tracker/models/app_settings.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class HabitDatabase extends ChangeNotifier {
  static late Isar isar;

  // S E T U P
  // Initialize Isar database
  static Future<void> initilize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([
      HabitSchema,
      AppSettingsSchema,
    ], directory: dir.path);
  }

  // save first launch date
  Future<void> saveFirstLaunchDate() async {
    final existingSettings = await isar.appSettings.where().findFirst();
    if (existingSettings == null) {
      final settings = AppSettings()..FirstLaunchDate = DateTime.now();
      await isar.writeTxn(() => isar.appSettings.put(settings));
    }
  }

  // get first launch date
  Future<DateTime?> getFirstLaunchDate() async {
    final settings = await isar.appSettings.where().findFirst();
    return settings?.FirstLaunchDate;
  }

  // C U R D O P E R A T I O N S
  // list of habits
  final List<Habit> currentHabits = [];

  // create habit
  Future<void> addHabit(String habitName) async {
    final newHabit = Habit()..name = habitName; // create new habit
    await isar.writeTxn(() => isar.habits.put(newHabit)); // save to db
    readHabits(); // re-read habits
  }

  // read habits
  Future<void> readHabits() async {
    List<Habit> fetchedHabits = await isar.habits
        .where()
        .findAll(); // fetch all habits from db
    currentHabits.clear(); // clear current list
    currentHabits.addAll(fetchedHabits); // add fetched habits to current list
    notifyListeners(); // notify listeners to update UI
  }

  // update habit(on and off)
  Future<void> updateHabitCompletion(int id, bool isCompleted) async {
    final habit = await isar.habits.get(id);
    // update completion status
    if (habit != null) {
      await isar.writeTxn(() async {
        if (isCompleted && !habit.completeDays.contains(DateTime.now())) {
          final today = DateTime.now(); // today's date
          habit.completeDays.add(DateTime(today.year, today.month, today.day));
        } else {
          habit.completeDays.removeWhere(
            (date) =>
                date.year == DateTime.now().year &&
                date.month == DateTime.now().month &&
                date.day == DateTime.now().day,
          );
        }
        await isar.habits.put(habit);
        readHabits(); // re-read habits
      });
    }
  }

  // update habit name
  Future<void> updateHabitName(int id, String newName) async {
    final habit = await isar.habits.get(id);// get habit by id
    if (habit != null) {
      await isar.writeTxn(() async {
        habit.name = newName; // update name
        await isar.habits.put(habit); // save to db
      });
    }
    readHabits(); // re-read habits
  }

  // delete habit
  Future<void> deleteHabit(int id) async {
    await isar.writeTxn(() async {
      await isar.habits.delete(id); // delete habit by id
    });
    readHabits(); // re-read habits
  }

}
//4:24:46