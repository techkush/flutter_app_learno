import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_learno/errors/login_errors.dart';
import 'package:flutter_app_learno/models/user.dart';
import 'package:flutter_app_learno/pages/feed.dart';
import 'package:flutter_app_learno/pages/homepage.dart';
import 'package:flutter_app_learno/pages/notifications.dart';
import 'package:flutter_app_learno/pages/profile.dart';
import 'package:flutter_app_learno/pages/subjects.dart';
import 'package:flutter_app_learno/screens/loading.dart';
import 'package:flutter_app_learno/widgets/progress.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

String currentUserId;
User currentUser;
final DateTime timestamp = DateTime.now();
final usersRef = Firestore.instance.collection('users');
final postsRef = Firestore.instance.collection('posts');
final StorageReference storageRef = FirebaseStorage.instance.ref();

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  int _pageIndex = 0;
  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProfileData();
  }

  Future<void> getProfileData() async {
    setState(() {
      _isLoading = true;
    });
    var user = await FirebaseAuth.instance.currentUser();
    currentUserId = user.uid;

    DocumentSnapshot doc = await usersRef.document(user.uid).get();
    currentUser = User.fromDocument(doc);
    setState(() {
      _isLoading = false;
    });
  }

  void signOut(BuildContext context) {
    FirebaseAuth.instance.signOut().then((value) {
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Loading()));
    }).catchError((error) {
      CommonError(
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
    if (_pageIndex == 4) return Profile(profileId: currentUser?.id,);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _isLoading ? linearProgress() : screen(context)),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onTabTapped,
        currentIndex: _pageIndex,
        items: [
          BottomNavigationBarItem(
            icon: new Icon(FeatherIcons.home, color: Color(0xff615DFA),),
            title: new Text('Home', style: TextStyle(color: Color(0xff615DFA)),),
          ),
          BottomNavigationBarItem(
            icon: new Icon(FeatherIcons.bookOpen, color: Color(0xff615DFA)),
            title: new Text('Subjects', style: TextStyle(color: Color(0xff615DFA))),
          ),
          BottomNavigationBarItem(
              icon: Icon(FeatherIcons.layers, color: Color(0xff615DFA)),
              title: Text('Feed', style: TextStyle(color: Color(0xff615DFA)))
          ),
          BottomNavigationBarItem(
              icon: Icon(FeatherIcons.bell, color: Color(0xff615DFA)),
              title: Text('Notification', style: TextStyle(color: Color(0xff615DFA)))
          ),
          BottomNavigationBarItem(
              icon: Icon(FeatherIcons.user, color: Color(0xff615DFA)),
              title: Text('Profile', style: TextStyle(color: Color(0xff615DFA)))
          )
        ],
      ),
    );
  }
}
