import 'package:flutter/material.dart';
import 'package:habit_tracker/components/my_drawer.dart';
import 'package:habit_tracker/components/my_habit_tile.dart';
import 'package:habit_tracker/components/my_heat_map.dart';
import 'package:habit_tracker/database/habit_database.dart';
import 'package:provider/provider.dart';

import '../models/habit.dart';
import '../util/habit_util.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void initState() {
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
          decoration: const InputDecoration(hintText: "Create a new habit"),
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              //receive new habit name
              String newHabitName = textController.text;

              //save tp DB
              context.read<HabitDatabase>().addHabit(newHabitName);

              //pop-up box
              Navigator.pop(context);

              //Clear controller
              textController.clear();
            },
            child: const Text('Save'),
          ),

          //cancel button
          MaterialButton(
            onPressed: () {
              //pop box
              Navigator.pop(context);

              textController.clear();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // check habit on & off
  void checkHabitOnOff(bool? value, Habit habit) {
    // update habit complete
    if (value != null) {
      context.read<HabitDatabase>().updateHabitCompletion(habit.id, value);
    }
  }

  //edit habit
  void editHabitBox(Habit habit) {
    textController.text = habit.name;
    
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: TextField(controller: textController,
          ),
          actions: [
            MaterialButton(
              onPressed: () {
                //receive new habit name
                String newHabitName = textController.text;

                //save tp DB
                context.read<HabitDatabase>().updateHabitName(habit.id,newHabitName);

                //pop-up box
                Navigator.pop(context);

                //Clear controller
                textController.clear();
              },
              child: const Text('Save'),
            ),

            //cancel button
            MaterialButton(
              onPressed: () {
                //pop box
                Navigator.pop(context);

                textController.clear();
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
    );
  }

  //delete habit
  void deleteHabitBox(Habit habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Are you sure you want to delete?"),
        actions: [
          // delete button
          MaterialButton(
            onPressed: () {

              //save tp DB
              context.read<HabitDatabase>()
                  .deleteHabit(habit.id);

              //pop-up box
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),

          //cancel button
          MaterialButton(
            onPressed: () {
              //pop box
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
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
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        child: const Icon(Icons.add),
      ),
      body: ListView(
        children: [
          //heatmap
          _buildHeatMap(),

          //habitlist
          _buildHabitList(),
        ],
      ),
    );
  }

  //heat map
  Widget _buildHeatMap() {
    final habitDatabase = context.watch<HabitDatabase>();

    List<Habit> currentHabits = habitDatabase.currentHabits;

    return FutureBuilder<DateTime?>(
        future: habitDatabase.getFirstLaunchDate(),
        builder: (context, snapshot) {
          //if data is avalible build heatmap
          if (snapshot.hasData) {
            return MyHeatMap(
                startDate: snapshot.data!,
                datasets: prepareHeatMap(currentHabits),
            );
          }

          else {
            return Container();
          }


        },
        );
  }


  // habit list
  Widget _buildHabitList() {
    final habitDatabase = context.watch<HabitDatabase>();

    List<Habit> currentHabits = habitDatabase.currentHabits;

    return ListView.builder(
      itemCount: currentHabits.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        //get each habit individually
        final habit = currentHabits[index];

        //check is habit completed today
        bool isCompletedToday = isHabitCompletedToday(habit.completedDays);

        return MyHabitTile(
          text: habit.name,
          isCompleted: isCompletedToday,
          onChanged: (value) => checkHabitOnOff(value, habit),
          editHabit: (context) => editHabitBox(habit),
          deleteHabit: (context) => deleteHabitBox(habit),

        );
      },
    );
  }
}
