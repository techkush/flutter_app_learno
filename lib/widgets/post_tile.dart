import 'package:flutter/material.dart';
import 'package:flutter_app_learno/pages_widgets/post.dart';
import 'package:flutter_app_learno/widgets/custom_image.dart';

class PostTile extends StatelessWidget {
  final Post post;

  PostTile(this.post);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => print('showing post'),
      child: cachedNetworkImage(post.mediaUrl),
    );
  }
}