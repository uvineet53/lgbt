import 'package:buddiesgram/widgets/HeaderWidget.dart';
import 'package:buddiesgram/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as tAgo;
import 'HomePage.dart';

class CommentsPage extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String url;
  CommentsPage({this.ownerId, this.postId, this.url});
  @override
  CommentsPageState createState() =>
      CommentsPageState(postId: postId, ownerId: ownerId, url: url);
}

class CommentsPageState extends State<CommentsPage> {
  final String postId;
  final String ownerId;
  final String url;
  CommentsPageState({this.ownerId, this.postId, this.url});
  TextEditingController commentController = new TextEditingController();
  displayComments() {
    return StreamBuilder(
      stream: commentsReference
          .document(postId)
          .collection("comments")
          .orderBy("timestamp", descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<Comment> comments = [];
        snapshot.data.documents.forEach((document) {
          comments.add(Comment.fromDocument(document));
        });
        return ListView(
          children: comments,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, strTitle: "Comments"),
      body: Column(
        children: [
          Expanded(
            child: displayComments(),
          ),
          Divider(
            color: Colors.grey[600],
          ),
          ListTile(
            title: Container(
              margin: EdgeInsets.only(
                bottom: 30,
              ),
              child: TextFormField(
                controller: commentController,
                decoration: InputDecoration(
                    labelText: "Write Comment Here",
                    labelStyle: TextStyle(
                      color: Colors.black,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                      ),
                    )),
                style: TextStyle(color: Colors.black),
              ),
            ),
            trailing: OutlineButton(
              onPressed: addComment,
              borderSide: BorderSide.none,
              child: Icon(
                Icons.add_comment,
                color: Colors.redAccent,
              ),
            ),
          )
        ],
      ),
    );
  }

  addComment() {
    commentsReference.document(postId).collection("comments").add({
      "username": currentUser.username,
      "comment": commentController.text,
      "timestamp": DateTime.now(),
      "url": currentUser.url,
      "userId": currentUser.id
    });
    bool isNotOwner = ownerId != currentUser.id;
    if (isNotOwner) {
      activityReference.document(ownerId).collection("feedItems").add({
        "type": "comment",
        "commentData": commentController.text,
        "postId": postId,
        "userId": currentUser.id,
        "username": currentUser.username,
        "userProfileImg": currentUser.url,
        "url": url,
        "timestamp": DateTime.now()
      });
    }
    commentController.clear();
  }
}

class Comment extends StatelessWidget {
  final String username;
  final String userId;
  final String url;
  final String comment;
  final Timestamp timestamp;
  Comment({this.username, this.comment, this.timestamp, this.url, this.userId});
  factory Comment.fromDocument(DocumentSnapshot documentSnapshot) {
    return Comment(
      username: documentSnapshot["username"],
      userId: documentSnapshot["userId"],
      url: documentSnapshot["url"],
      comment: documentSnapshot["comment"],
      timestamp: documentSnapshot["timestamp"],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(6),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[400],
        ),
        child: Column(
          children: [
            ListTile(
              title: Text(
                "$username - $comment",
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(url),
              ),
              subtitle: Text(
                tAgo.format(timestamp.toDate()),
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
