import 'package:flutter/material.dart';
import 'package:flutter_app_learno/pages_widgets/upload.dart';
import 'package:flutter_app_learno/screens/home.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

class Profile extends StatefulWidget {
  final String profileId;

  Profile({this.profileId});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  buildProfileHeader() {
    return Padding(
      padding: EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 10),
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            CircleAvatar(
              radius: 42.0,
              backgroundColor: Colors.blueGrey,
              child: currentUser.photoUrl == null
                  ? CircleAvatar(
                      radius: 40.0,
                      child: Text(
                        '${currentUser.firstName[0]}',
                        style: TextStyle(fontSize: 40, color: Colors.white),
                      ),
                      backgroundColor: Color(0xff615DFA),
                    )
                  : CircleAvatar(
                      radius: 40.0,
                      backgroundColor: Colors.grey,
                      backgroundImage: NetworkImage(currentUser.photoUrl),
                    ),
            ),
            SizedBox(
              width: 20,
            ),
            buildCountColumn('Posts', 0),
            SizedBox(
              width: 5,
            ),
            buildCountColumn('Followers', 0),
            SizedBox(
              width: 5,
            ),
            buildCountColumn('Following', 0),
            SizedBox(
              width: 5,
            ),
          ],
        ),
      ),
    );
  }

  buildProfileDetails() {
    return Padding(
        padding: EdgeInsets.only(top: 5, left: 30, right: 40, bottom: 10),
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              userDetails(),
              buildLeftIconButton(),
            ],
          ),
        ));
  }

  Widget buildProfileButtons() {
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      return buildCurrentButtons();
    } else {
      return buildVisitButtons();
    }
  }

  Widget buildLeftIconButton() {
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      return IconButton(
        icon: Icon(
          FeatherIcons.camera,
          color: Color(0xff615DFA),
        ),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Upload(
                        currentUser: currentUser,
                      )));
        },
      );
    } else {
      return Container();
    }
  }

  buildCurrentButtons() {
    return Padding(
        padding: EdgeInsets.only(left: 30, right: 30, bottom: 10),
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                height: 30,
                width: MediaQuery.of(context).size.width / 2 - 40,
                child: RaisedButton(
                  child: Text('Edit Profile'),
                  onPressed: () {},
                ),
              ),
              Container(
                height: 30,
                width: MediaQuery.of(context).size.width / 2 - 40,
                child: RaisedButton(
                  child: Text('Find Friends'),
                  onPressed: () {},
                ),
              )
            ],
          ),
        ));
  }

  buildVisitButtons() {
    return Padding(
        padding: EdgeInsets.only(left: 30, right: 30, bottom: 10),
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                height: 30,
                width: MediaQuery.of(context).size.width / 2 - 40,
                child: RaisedButton(
                  child: Text('Follow'),
                  onPressed: () {},
                ),
              ),
              Container(
                height: 30,
                width: MediaQuery.of(context).size.width / 2 - 40,
                child: RaisedButton(
                  child: Text('Contact'),
                  onPressed: () {},
                ),
              )
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        buildProfileHeader(),
        buildProfileDetails(),
        buildProfileButtons(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Divider(
            height: 0,
          ),
        )
      ],
    );
  }

  Column userDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          '${currentUser.firstName} ${currentUser.lastName}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 2,
        ),
        Text('${currentUser.school} | ${currentUser.userRole}')
      ],
    );
  }

  Column buildCountColumn(String label, int count) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 4.0),
          child: Text(
            label,
            style: TextStyle(
                color: Colors.grey,
                fontSize: 15.0,
                fontWeight: FontWeight.w400),
          ),
        )
      ],
    );
  }
}
