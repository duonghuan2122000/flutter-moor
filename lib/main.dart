import 'package:flutter/material.dart';
import 'package:flutter_app_task/data/Tasks.dart';
import 'package:flutter_app_task/ui/home_page.dart';
import 'package:moor/moor.dart';
import 'package:provider/provider.dart';

void main(){
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Provider(
      create: (_) => AppDatabase(),
      child: MaterialApp(
        title: "Task",
        home: HomePage(),
      ),
    );
  }
}