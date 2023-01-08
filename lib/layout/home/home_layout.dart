import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo/shared/components/components.dart';
import 'package:todo/shared/cubit/cubit.dart';
import 'package:todo/shared/cubit/states.dart';

class HomeLayout extends StatelessWidget {
  HomeLayout({Key? key}) : super(key: key);

  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();

  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();
  var descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TasksCubit()..createDatabase(),
      child: BlocConsumer<TasksCubit, TasksStates>(
        builder: (context, state) {
          TasksCubit tasksCubit = TasksCubit.getContext(context);
          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              title: Text(
                tasksCubit.titles[tasksCubit.currentIndex],
              ),
            ),
            body: ConditionalBuilder(
              condition: state is! TasksGetAllDatabaseLoadingState,
              builder: (context) => tasksCubit.screens[tasksCubit.currentIndex],
              fallback: (context) =>
                  const Center(child: CircularProgressIndicator()),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                try {
                  if (tasksCubit.isBottomSheetShown) {
                    if (formKey.currentState!.validate()) {
                      tasksCubit.insertIntoDatabase(
                        taskTitle: titleController.text,
                        taskDate: dateController.text,
                        taskTime: timeController.text,
                        taskDesc: descController.text,
                      );
                    } //end if()

                    /// Remember that the default value is to be unshown that basically mean that it's value is false
                  } else {
                    scaffoldKey.currentState
                        ?.showBottomSheet(
                          (context) => Form(
                            key: formKey,
                            child: Container(
                              padding: const EdgeInsets.all(20.0),
                              width: double.infinity,
                              height: 410.0,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadiusDirectional.only(
                                  topStart: Radius.circular(25.0),
                                  topEnd: Radius.circular(25.0),
                                ),
                                color: Colors.white70,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  textForm(
                                    inputType: TextInputType.text,
                                    controller: titleController,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'task title must not be empty';
                                      } //end if()
                                      return null;
                                    },
                                    label: 'task title',
                                    icon: Icons.touch_app_outlined,
                                  ),
                                  const SizedBox(
                                    height: 15.0,
                                  ),
                                  textForm(
                                    inputType: TextInputType.datetime,
                                    controller: timeController,
                                    onTap: () {
                                      showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                      ).then((value) {
                                        timeController.text =
                                            value!.format(context);
                                      });
                                    },
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'task time must not be empty';
                                      } //end if()
                                      return null;
                                    },
                                    label: 'task time',
                                    icon: Icons.av_timer_outlined,
                                  ),
                                  const SizedBox(
                                    height: 15.0,
                                  ),
                                  textForm(
                                      inputType: TextInputType.datetime,
                                      controller: dateController,
                                      label: 'task date',
                                      icon: Icons.date_range_outlined,
                                      onTap: () {
                                        showDatePicker(
                                                context: context,
                                                initialDate: DateTime.now(),
                                                firstDate: DateTime.now(),
                                                lastDate: DateTime.parse(
                                                    '2023-03-01'))
                                            .then((value) {
                                          dateController.text =
                                              DateFormat.yMMMd().format(value!);
                                        });
                                      },
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'task date must not be empty';
                                        }
                                        return null;
                                      }),
                                  const SizedBox(
                                    height: 15.0,
                                  ),
                                  textForm(
                                    inputType: TextInputType.text,
                                    controller: descController,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'task description must not be empty';
                                      } //end if()
                                      return null;
                                    },
                                    label: 'task description',
                                    icon: Icons.description_outlined,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .closed
                        .then((value) {
                      tasksCubit.changeBottomSheetState(
                          false, Icons.mode_edit_outlined);
                    });
                    tasksCubit.changeBottomSheetState(true, Icons.add);
                  } //end else
                } catch (error) {
                  print('the error is $error');
                }
              },
              child: Icon(
                tasksCubit.fabIcon,
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: TasksCubit.getContext(context).currentIndex,
              onTap: (index) {
                tasksCubit.changeBottomNavIndex(index);
              },
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.format_list_bulleted_sharp),
                    label: 'Tasks'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.done_all), label: 'Done'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.archive_outlined), label: 'Archived'),
              ],
            ),
          );
        },
        listener: (context, state) {
          if (state is TasksInsertDatabaseState) {
            Navigator.pop(context);
            titleController.clear();
            timeController.clear();
            dateController.clear();
            descController.clear();
          } // end if()
        },
      ),
    );
  } //end build()

} //end class
