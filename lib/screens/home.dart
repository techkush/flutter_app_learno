import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_learno/errors/login_errors.dart';
import 'package:flutter_app_learno/pages/feed.dart';
import 'package:flutter_app_learno/pages/homepage.dart';
import 'package:flutter_app_learno/pages/notifications.dart';
import 'package:flutter_app_learno/pages/profile.dart';
import 'package:flutter_app_learno/pages/subjects.dart';
import 'package:flutter_app_learno/screens/loading.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  int _pageIndex = 0;

  void signOut(BuildContext context) {
    FirebaseAuth.instance.signOut().then((value) {
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Loading()));
    }).catchError((error) {
      LoginError(
          title: 'Sign out Error!',
          description:
          'Something is wrong. Please check your connection.')
          .alertDialog(context);
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _pageIndex = index;
    });
  }

  Widget screen(context) {
    if (_pageIndex == 0) return HomePage();
    if (_pageIndex == 1) return Subjects();
    if (_pageIndex == 2) return Feed();
    if (_pageIndex == 3) return Notifications();
    if (_pageIndex == 4) return Profile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: screen(context)),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onTabTapped,
        currentIndex: _pageIndex,
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.home, color: Color(0xff615DFA),),
            title: new Text('Home', style: TextStyle(color: Color(0xff615DFA)),),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.book, color: Color(0xff615DFA)),
            title: new Text('Subjects', style: TextStyle(color: Color(0xff615DFA))),
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.burst_mode, color: Color(0xff615DFA)),
              title: Text('Feed', style: TextStyle(color: Color(0xff615DFA)))
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications, color: Color(0xff615DFA)),
              title: Text('Notification', style: TextStyle(color: Color(0xff615DFA)))
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person, color: Color(0xff615DFA)),
              title: Text('Profile', style: TextStyle(color: Color(0xff615DFA)))
          )
        ],
      ),
    );
  }
}
