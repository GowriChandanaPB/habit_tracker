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
  // create habit
  // update habit(on and off)
  // update habit name
  // delete habit
}
//4:19:50