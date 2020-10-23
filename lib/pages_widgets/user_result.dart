import 'package:flutter/material.dart';
import 'package:flutter_app_learno/models/user.dart';
import 'package:flutter_app_learno/pages/notifications.dart';

class UserResult extends StatelessWidget {
  final User user;
  UserResult(this.user);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.7),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => showProfile(context, profileId: user.id),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey,
                radius: 30,
                backgroundImage: NetworkImage(user.photoUrl),
              ),
              title: Text(user.displayName, style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold
              ), ),
              subtitle: Text(user.school, style: TextStyle(
                  color: Colors.white
              ),),
            ),
          ),
          Divider(
            height: 2.0,
            color: Colors.white54,
          )
        ],
      ),
    );
  }
}