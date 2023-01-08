import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo/modules/archived_task/archived_screen.dart';
import 'package:todo/modules/done_task/done_screen.dart';
import 'package:todo/modules/new_task/new_screen.dart';
import 'package:todo/shared/cubit/states.dart';

class TasksCubit extends Cubit<TasksStates> {
  TasksCubit() : super(TasksInitialState());

  int currentIndex = 0;
  List<Widget> screens = const [NewScreen(), DoneScreen(), ArchivedScreen()];
  List<String> titles = const ['Tasks', 'Done', 'Archived'];

  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];

  bool isBottomSheetShown = false;
  IconData fabIcon = Icons.mode_edit_outline_outlined;
  late Database database;

  // to take an object from BlocProvider()
  static TasksCubit getContext(context) => BlocProvider.of(context);

  void changeBottomNavIndex(int index) {
    currentIndex = index;
    emit(TasksBottomNavState());
  } // end changeBottomNavIndex()

  void createDatabase() {
    openDatabase(
      'todo.db',
      version: 1,
      onCreate: (database, version) {
        print('database created');
        database
            .execute(
                'CREATE TABLE tasks (id INTEGER PRIMARY KEY, titles TEXT, date TEXT, time TEXT, description TEXT,status TEXT)')
            .then((value) {
          print('table created');
        });
      },
      onOpen: (database) {
        getAllData(database);
        print('database opened');
      },
    ).then((value) {
      database = value;
    });
  } //end createDatabase()

  insertIntoDatabase({
    required var taskTitle,
    required var taskDate,
    required var taskTime,
    required var taskDesc,
  }) async {
    await database.transaction((transaction) {
      return transaction
          .rawInsert(
              'INSERT INTO tasks(titles, date, time, description, status) VALUES("$taskTitle", "$taskDate", "$taskTime", "$taskDesc", "New")')
          .then((value) {
        print('$value a new record inserted');
        emit(TasksInsertDatabaseState());
        getAllData(database);
      });
    });
  }

  void updateData({required String status, required int id}) async {
    database.rawUpdate('UPDATE tasks SET status = ? WHERE id = ?', [
      status,
      id,
    ]).then((value) {
      getAllData(database);
      emit(TasksUpdateDatabaseState());
    });
  } //end updateData()

  void deleteData({required int id}) async {
    database.rawDelete('DELETE FROM tasks WHERE id = ?', [id]).then((value) {
      getAllData(database);
      emit(TasksDeleteDatabaseState());
    });
  } //end updateData()

  void getAllData(database) {
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];

    emit(TasksGetAllDatabaseLoadingState());
    database.rawQuery('SELECT * FROM tasks').then((value) {
      value.forEach((element) {
        // print(element['status']);
        if (element['status'] == 'New')
          newTasks.add(element);
        else if (element['status'] == 'done')
          doneTasks.add(element);
        else
          archivedTasks.add(element);
      });
      emit(TasksGetAllDatabaseState());
    });
  } //end getAllData()

  void changeBottomSheetState(bool isShown, IconData icon) {
    isBottomSheetShown = isShown;
    fabIcon = icon;
    emit(TasksBottomSheetState());
  } //end changeBottomSheetState()

} //end class
