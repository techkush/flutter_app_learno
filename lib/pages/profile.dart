import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_learno/pages_widgets/find_friends.dart';
import 'package:flutter_app_learno/pages_widgets/post.dart';
import 'package:flutter_app_learno/pages_widgets/upload.dart';
import 'package:flutter_app_learno/screens/home.dart';
import 'package:flutter_app_learno/widgets/post_tile.dart';
import 'package:flutter_app_learno/widgets/progress.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

class Profile extends StatefulWidget {
  final String profileId;

  Profile({this.profileId});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isLoading = false;
  int postCount = 0;
  String postOrientation = "grid";
  List<Post> posts = [];
  String backPostsUpload;

  @override
  void initState() {
    super.initState();
    getProfilePost();
  }

  getProfilePost() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await postsRef
        .document(widget.profileId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();
    setState(() {
      isLoading = false;
      postCount = snapshot.documents.length;
      posts = snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

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
        onPressed: () async {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Upload(
                        currentUser: currentUser,
                      )));
          refresh();
        },
      );
    } else {
      return Container();
    }
  }

  refresh() {
    setState(() {
    });
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
                  onPressed: () {
                    setState(() {
                      backPostsUpload = 'Hello';
                    });
                  },
                ),
              ),
              Container(
                height: 30,
                width: MediaQuery.of(context).size.width / 2 - 40,
                child: RaisedButton(
                  child: Text('Find Friends'),
                  onPressed: () {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (context) => FindFriends()));
                  },
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

  buildProfilePosts() {
    if (isLoading) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 60.0),
              child: Text(
                "No Posts",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 40.0,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (postOrientation == "grid") {
      List<GridTile> gridTiles = [];
      posts.forEach((post) {
        gridTiles.add(GridTile(child: PostTile(post)));
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTiles,
      );
    } else if (postOrientation == "list") {
      return Column(
        children: posts,
      );
    }
  }

  setPostOrientation(String postOrientation) {
    setState(() {
      this.postOrientation = postOrientation;
    });
  }

  buildTogglePostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          onPressed: () => setPostOrientation("grid"),
          icon: Icon(Icons.grid_on),
          color: postOrientation == 'grid'
              ? Color(0xff615DFA)
              : Colors.grey,
        ),
        IconButton(
          onPressed: () => setPostOrientation("list"),
          icon: Icon(Icons.list),
          color: postOrientation == 'list'
              ? Color(0xff615DFA)
              : Colors.grey,
        ),
      ],
    );
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
        ),
        buildTogglePostOrientation(),
        Divider(
          height: 0.0,
        ),
        buildProfilePosts(),
        SizedBox(height: 10,)
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
