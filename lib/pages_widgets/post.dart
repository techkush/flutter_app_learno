import 'dart:async';
import 'package:animator/animator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_learno/models/user.dart';
import 'package:flutter_app_learno/pages_widgets/comments.dart';
import 'package:flutter_app_learno/screens/home.dart';
import 'package:flutter_app_learno/widgets/custom_image.dart';
import 'package:flutter_app_learno/widgets/profile_image.dart';
import 'package:flutter_app_learno/widgets/progress.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:timeago/timeago.dart' as timeago;

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  final Timestamp timestamp;
  final dynamic likes;

  Post(
      {this.postId,
      this.ownerId,
      this.username,
      this.location,
      this.timestamp,
      this.description,
      this.mediaUrl,
      this.likes});

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc['postId'],
      ownerId: doc['ownerId'],
      username: doc['username'],
      location: doc['location'],
      description: doc['description'],
      timestamp: doc['timestamp'],
      mediaUrl: doc['mediaUrl'],
      likes: doc['likes'],
    );
  }

  int getLikes(likes) {
    if (likes == null) {
      return 0;
    }
    int count = 0;
    likes.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }

  @override
  _PostState createState() => _PostState(
      postId: this.postId,
      ownerId: this.ownerId,
      username: this.username,
      location: this.location,
      timestamp: this.timestamp,
      description: this.description,
      mediaUrl: this.mediaUrl,
      likeCount: this.getLikes(this.likes),
      likes: this.likes);
}

class _PostState extends State<Post> {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final Timestamp timestamp;
  final String description;
  final String mediaUrl;
  int likeCount;
  Map likes;
  bool showHeart = false;
  bool isLiked;

  _PostState(
      {this.postId,
      this.ownerId,
      this.username,
      this.location,
      this.timestamp,
      this.description,
      this.mediaUrl,
      this.likeCount,
      this.likes});

  buildPostHeader() {
    return FutureBuilder(
      future: usersRef.document(ownerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data);
        return ListTile(
          leading: profileImage(user.photoUrl, user.displayName),
          title: GestureDetector(
            onTap: () => print('showing profile'),
            child: Text(
              "${user.firstName} ${user.lastName}",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
          subtitle: Text(timeago.format(timestamp.toDate())),
          trailing: IconButton(
            onPressed: () => print('Deleting post'),
            icon: Icon(Icons.more_vert),
          ),
        );
      },
    );
  }

  handleLikePost() {
    bool _isLiked = likes[currentUserId] == true;
    if (_isLiked) {
      postsRef
          .document(ownerId)
          .collection('userPosts')
          .document(postId)
          .updateData({'likes.$currentUserId': false});
      removeLikeFromActivityFeed();
      setState(() {
        likeCount -= 1;
        isLiked = false;
        likes[currentUserId] = false;
      });
    } else if (!_isLiked) {
      postsRef
          .document(ownerId)
          .collection('userPosts')
          .document(postId)
          .updateData({'likes.$currentUserId': true});
      addLikeToActivityFeed();
      setState(() {
        likeCount += 1;
        isLiked = true;
        likes[currentUserId] = true;
        showHeart = true;
      });
      Timer(Duration(milliseconds: 500), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  addLikeToActivityFeed() {
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      notificationRef
          .document(ownerId)
          .collection("notificationItems")
          .document(postId)
          .setData({
        "type": "like",
        "username": currentUser.displayName,
        "userId": currentUser.id,
        "userProfileImg": currentUser.photoUrl,
        "postId": postId,
        "mediaUrl": mediaUrl,
        "timestamp": timestamp,
      });
    }
  }

  removeLikeFromActivityFeed() {
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      notificationRef
          .document(ownerId)
          .collection("notificationItems")
          .document(postId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    }
  }

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: () => handleLikePost(),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          cachedNetworkImage(mediaUrl),
          showHeart
              ? Animator(
                  duration: Duration(milliseconds: 300),
                  tween: Tween(begin: 0.8, end: 1.5),
                  curve: Curves.elasticOut,
                  cycles: 0,
                  builder: (context, anim, child) => Transform.scale(
                    scale: anim.value,
                    child: Icon(
                      Icons.favorite,
                      color: Colors.pink,
                      size: 100.0,
                    ),
                  ),
                )
              : Text(""),
        ],
      ),
    );
  }

  buildPostFooter() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 40, left: 20),
            ),
            GestureDetector(
              onTap: () => handleLikePost(),
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                size: 28.0,
                color: Colors.pink,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 20),
            ),
            GestureDetector(
              onTap: () => showComments(context,
                  postId: postId, ownerId: ownerId, mediaUrl: mediaUrl),
              child: Icon(
                FeatherIcons.messageSquare,
                size: 28.0,
                color: Colors.blue[900],
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(
                "$likeCount likes",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentUserId] == true);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "$username  ",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            description,
            textAlign: TextAlign.start,
            style: TextStyle(),
          ),
        ),
      ],
    );
  }
}

showComments(BuildContext context,
    {String postId, String ownerId, String mediaUrl}) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return Comments(
        postId: postId, postOwnerId: ownerId, postMediaUrl: mediaUrl);
  }));
}
