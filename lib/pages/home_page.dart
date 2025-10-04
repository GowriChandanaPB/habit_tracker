import 'package:flutter/material.dart';
import 'package:habit_tracker/components/my_drawer.dart';
import 'package:habit_tracker/components/my_habit_tile.dart';
import 'package:habit_tracker/components/my_heat_map.dart';
import 'package:habit_tracker/database/habit_database.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/util/habit_util.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initstate() {
    //read existing habit from db
    Provider.of<HabitDatabase>(context, listen: false).readHabits();

    super.initState();
  }

  // text controller
  final TextEditingController textController = TextEditingController();

  // create new habit
  void createNewHabit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(hintText: "create a new habit"),
        ),
        actions: [
          // save button
          MaterialButton(
            onPressed: () {
              String newHabitName = textController.text; // get the habit name
              context.read<HabitDatabase>().addHabit(
                newHabitName,
              ); // save to database
              Navigator.pop(context); // close the dialog
              textController.clear(); // clear the text field
            },
            child: const Text("Save"),
          ),
          MaterialButton(
            onPressed: () {
              Navigator.pop(context); // close the dialog
              textController.clear(); // clear the text field
            },
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  // check habit on and off
  void checkHabitOnOff(bool? value, Habit habit) {
    //update habit completion status
    if (value != null) {
      context.read<HabitDatabase>().updateHabitCompletion(habit.id, value);
    }
  }

  // edit habit
  void editHabitBox(Habit habit) {
    textController.text = habit.name; // prefill the text field with the name
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(controller: textController),
        actions: [
          // save button
          MaterialButton(
            onPressed: () {
              String newHabitName = textController.text; // get the habit name
              context.read<HabitDatabase>().updateHabitName(
                habit.id,
                newHabitName,
              ); // save to database
              Navigator.pop(context); // close the dialog
              textController.clear(); // clear the text field
            },
            child: const Text("Save"),
          ),

          // cancel button
          MaterialButton(
            onPressed: () {
              Navigator.pop(context); // close the dialog
              textController.clear(); // clear the text field
            },
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  // delete habit
  void deleteHabitBox(Habit habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Are you sure you want to delete?"),
        actions: [
          // delete button
          MaterialButton(
            onPressed: () {
              context.read<HabitDatabase>().deleteHabit(
                habit.id,
              ); // save to database
              Navigator.pop(context); // close the dialog
            },
            child: const Text("Delete"),
          ),

          // cancel button
          MaterialButton(
            onPressed: () {
              Navigator.pop(context); // close the dialog
            },
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: const MyDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewHabit,
        //elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: ListView(
        children: [
          // heat map on top
          _buildHeatMap(),

          // habit list below
          _buildHabitList(),
        ],
      ),
    );
  }

  Widget _buildHeatMap() {
    final habitDatabase = context.watch<HabitDatabase>(); // habit database
    List<Habit> currentHabits = habitDatabase.currentHabits; // current habits

    // return head map ui

    return FutureBuilder<DateTime?>(
      future: habitDatabase.getFirstLaunchDate(),
      builder: (context, snapshot) {
        // once the data is available -> build heat map
        if (snapshot.hasData) {
          return MyHeatMap(
            startDate: snapshot.data!, 
            dataSets: prepHeatMapDataSet(currentHabits),
          );
        } else {
          return Container();
        }
      },
    );
  }

  Widget _buildHabitList() {
    final habitDatabase = context.watch<HabitDatabase>(); // habit db
    List<Habit> currentHabits = habitDatabase.currentHabits; // current habits
    // return habli list
    return ListView.builder(
      itemCount: currentHabits.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final habit = currentHabits[index]; // get individual habit
        final isCompletedToday = isHabitCompletedToday(
          habit.completeDays,
        ); // check if the habit is completed today
        return MyHabitTile(
          text: habit.name,
          isCompleted: isCompletedToday,
          onChanged: (value) => checkHabitOnOff(value, habit),
          editHabit: (context) => editHabitBox(habit),
          deleteHabit: (context) => deleteHabitBox(habit),
        ); // return habilt tile UI
      },
    );
  }
}
