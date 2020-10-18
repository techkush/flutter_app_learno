import 'package:flutter/material.dart';
import 'package:flutter_app_learno/screens/loading.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learno',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          //primarySwatch: Colors.blue,
          primaryColorDark: Color(0xff615DFA),
          primaryColorLight: Color(0xff23D2E2),
          fontFamily: 'Montserrat'
          //accentColor: Color(0xff05D2DD),
          ),
      home: Loading(),
    );
  }
}
