import 'package:buddiesgram/widgets/PostWidget.dart';
import 'package:flutter/material.dart';

class PostTile extends StatelessWidget {
  final Post post;
  PostTile({this.post});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("Show Image");
      },
      child: Image.network(post.url),
    );
  }
}
