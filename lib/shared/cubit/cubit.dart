import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:whats_now/shared/cubit/states.dart';

import '../../modules/archived_tasks/archived_tasks_screen.dart';
import '../../modules/done_tasks/done_tasks_screen.dart';
import '../../modules/new_tasks/new_tasks_screen.dart';

class AppCubit extends Cubit<AppState>{

  AppCubit() : super(AppInitialState());
  static AppCubit get(context) => BlocProvider.of(context);

  int currentIndex=0;
  late Database database;
  List<Map> newTasks=[];
  List<Map> doneTasks=[];
  List<Map> archivedTasks=[];
  bool isBottomSheetShown= false;



  List<Widget> screens =
  [
    const NewTasksScreen(),
    const DoneTasksScreen(),
    const ArchivedTasksScreen(),
  ];
  List<String> titles=
  [
    'New Tasks',
    'Done Tasks',
    'Archived Tasks',
  ];

  void changeIndex(int index){
    currentIndex=index;
    emit(AppChangeBottomNavBarState());
  }
  void changeIconBottomSheet({required bool isShow}){
    isBottomSheetShown=isShow;
    emit(AppChangeIconBottomState());
  }

  void createDatabase() {
    openDatabase(
      'todo.db',
      version: 1,
      onCreate: (database, version) {
        print('Database Created');
        database.execute('CREATE TABLE Tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)').then(
                (value) {
              print('table Created');
            }
        ).catchError(
                (error){
              print('Error when creating Table${error.toString()}');
            }
        );
      },
      onOpen: (db) {
        print('Open Database');
        getDataFromDatabase(db);
      },
    ).then((value) {
      database = value;
      emit(AppCreateDatabaseState());
    });
  }

  Future insertToDatabase({required String taskTitle,required String taskTime, required String taskDate}) async {
    return await database.transaction( (txn) async {
      txn.rawInsert('INSERT INTO Tasks (title, date, time, status) VALUES("$taskTitle","$taskDate","$taskTime","Status" )').then((value) {

        emit(AppInsertDatabaseState());
        print('$value inserted Successfuly');
        getDataFromDatabase(database);

      }).catchError((error){
        print('Error When Inserting New Record${error.toString()}');
      });
      return null;
    });

  }

  void getDataFromDatabase(database) {

    newTasks = [];
    doneTasks = [];
    archivedTasks = [];

    emit(AppLoadingGetDatabaseState());
    database.rawQuery('SELECT * FROM tasks').then((value) {

      value.forEach((element) {
        if(element['status'] == 'Status'){
          newTasks.add(element);
        }else if(element['status'] == 'done'){
          doneTasks.add(element);
        }else{
          archivedTasks.add(element);
        }
        print(element['status']);
      });
      emit(AppGetDatabaseState());
    });
  }

  void updateData({required String status,required int id}) async {
    database.rawUpdate(
        'UPDATE tasks SET status = ? WHERE id = ?',
        ['$status', id]).then((value) {

          getDataFromDatabase(database);
          emit(AppUpdateDatabaseState());
    });
  }

  void deleteData({required int id}) async {
    database.rawDelete(
        'DELETE FROM tasks WHERE id = ?',
        [id]).then((value) {

          getDataFromDatabase(database);
          emit(AppDeleteDatabaseState());
    });
  }


}