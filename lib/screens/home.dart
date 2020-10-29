import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
import 'package:google_sign_in/google_sign_in.dart';

String currentUserId;
User currentUser;
final usersRef = Firestore.instance.collection('users');
final postsRef = Firestore.instance.collection('posts');
final commentsRef = Firestore.instance.collection('comments');
final notificationRef = Firestore.instance.collection('notification');
final followersRef = Firestore.instance.collection('followers');
final followingRef = Firestore.instance.collection('following');
final timelineRef = Firestore.instance.collection('timeline');
final StorageReference storageRef = FirebaseStorage.instance.ref();

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
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
    await configurePushNotifications();
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

  Future<void> configurePushNotifications() async {
    if (Platform.isIOS) await getiOSPermission();

    _firebaseMessaging.getToken().then((token) {
      print("Firebase Messaging Token: $token\n");
      usersRef
          .document(currentUser.id)
          .updateData({"androidNotificationToken": token});
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("on message: $message\n");
        final String recipientId = message['data']['recipient'];
        final String body = message['notification']['body'];
        if (recipientId == currentUser.id) {
          print("Notification shown!");
          SnackBar snackbar = SnackBar(
              content: InkWell(
                onTap: () {
                  setState(() {
                    _pageIndex = 3;
                  });
                },
                child: Text(
                  body,
                  overflow: TextOverflow.ellipsis,
                ),
              ));
          _scaffoldKey.currentState.showSnackBar(snackbar);
        }
        print("Notification NOT shown");
      },
    );
  }

  Future<void> getiOSPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(alert: true, badge: true, sound: true));
    _firebaseMessaging.onIosSettingsRegistered.listen((settings) {
      print("Settings registered: $settings");
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
    if (_pageIndex == 2) return Feed(currentUser: currentUser);
    if (_pageIndex == 3) return Notifications();
    if (_pageIndex == 4) return Profile(profileId: currentUser?.id, backButton: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
              title: Text('Notifications', style: TextStyle(color: Color(0xff615DFA)))
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
