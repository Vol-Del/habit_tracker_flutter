import 'package:flutter/cupertino.dart';
import 'package:habit_tracker/models/app_settings.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class HabitDatabase extends ChangeNotifier {
  static late Isar isar;

  /*

  S E T U P

   */


  //Initialize database
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [HabitSchema, AppSettingsSchema],
      directory: dir.path,
    );
  }

  Future<void> saveFirstLaunchDate() async {
    final existingSettings = await isar.appSettings.where().findFirst();
    if (existingSettings == null) {
      final settings = AppSettings()..firstLaunchDate = DateTime.now();
      await isar.writeTxn(() => isar.appSettings.put(settings));
    }
  }

  Future<DateTime?> getFirstLaunchDate() async {
    final settings = await isar.appSettings.where().findFirst();
    return settings?.firstLaunchDate;
  }

  /*

  C R U D X O P E R A T I O N S

   */

  //list of habits
  final List<Habit> currentHabits = [];

  //Create - add a new habit
  Future<void> addHabit(String habitName) async {
    final newHabit = Habit()..name = habitName;

    //save to db
    await isar.writeTxn(() => isar.habits.put(newHabit));

    //re-read from DB
    readHabits();
    
  }

  Future<void> readHabits() async {
    //fetch habits from db
    List<Habit> fetchedHabits = await isar.habits.where().findAll();

    //give to current habits list
    currentHabits.clear();
    currentHabits.addAll(fetchedHabits);

    //update ui
    notifyListeners();
  }

  // U P D A T E - check habit on and off
  Future<void> updateHabitCompletion(int id, bool isCompleted) async {
    //find specific habit
    final habit = await isar.habits.get(id);

    //update completion status
    if (habit != null) {
      await isar.writeTxn(() async {
        if(isCompleted) {

        }

        else {

        }
      });
  }

  }


}