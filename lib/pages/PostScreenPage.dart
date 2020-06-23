import 'package:buddiesgram/pages/HomePage.dart';
import 'package:buddiesgram/widgets/HeaderWidget.dart';
import 'package:buddiesgram/widgets/PostWidget.dart';
import 'package:buddiesgram/widgets/ProgressWidget.dart';
import 'package:flutter/material.dart';

class PostScreenPage extends StatelessWidget {
  final String userId;
  final String postId;
  PostScreenPage({this.postId, this.userId});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: postsReference
            .document(userId)
            .collection("userPosts")
            .document(postId)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          Post post = Post.fromDocument(snapshot.data);
          return Center(
              child: Scaffold(
            appBar: header(
              context,
              disableBackButton: false,
              strTitle: post.description,
            ),
            body: ListView(
              children: [
                Container(
                  child: post,
                )
              ],
            ),
          ));
        });
  }
}
