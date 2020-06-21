import 'package:buddiesgram/models/user.dart';
import 'package:buddiesgram/pages/HomePage.dart';
import 'package:buddiesgram/widgets/CImageWidget.dart';
import 'package:buddiesgram/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  // final String timestamp;
  final dynamic likes;
  final String username;
  final String description;
  final String location;
  final String url;

  Post(
      {this.postId,
      this.ownerId,
      // this.timestamp,
      this.likes,
      this.username,
      this.description,
      this.location,
      this.url});
  factory Post.fromDocument(DocumentSnapshot documentSnapshot) {
    return Post(
      postId: documentSnapshot["postId"],
      ownerId: documentSnapshot["owner Id"],
      likes: documentSnapshot["likes"],
      username: documentSnapshot["username"],
      description: documentSnapshot["description"],
      location: documentSnapshot["location"],
      url: documentSnapshot["url"],
    );
  }
  int getTotalLikes(likes) {
    if (likes == null) {
      return 0;
    }
    int counter = 0;
    likes.values.forEach((value) {
      if (value == true) {
        counter++;
      }
    });
    return counter;
  }

  @override
  _PostState createState() => _PostState(
      postId: this.postId,
      ownerId: this.ownerId,
      //timestamp:this.timestamp,
      likes: this.likes,
      username: this.username,
      description: this.description,
      location: this.location,
      url: this.url,
      likeCount: getTotalLikes(this.likes));
}

class _PostState extends State<Post> {
  final String postId;
  final String ownerId;
  // final String timestamp;
  Map likes;
  final String username;
  final String description;
  final String location;
  final String url;
  int likeCount;
  bool isLiked = false;
  final String currentUserId = currentUser.id;

  _PostState(
      {this.postId,
      this.ownerId,
      // this.timestamp,
      this.likes,
      this.username,
      this.description,
      this.location,
      this.url,
      this.likeCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          postHead(),
          postPicture(),
          postFooter(),
        ],
      ),
    );
  }

  postHead() {
    return FutureBuilder(
      future: userReference.document(ownerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return linearProgress();
        }
        User user = User.fromDocument(snapshot.data);
        bool isPostOwner = currentUserId == ownerId;
        return ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(user.url),
              backgroundColor: Colors.grey,
            ),
            title: GestureDetector(
              onTap: () {
                print("Show Profile");
              },
              child: Text(
                user.username,
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            subtitle: Text(
              location,
              style: TextStyle(color: Colors.black),
            ),
            trailing: isPostOwner
                ? IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      print("Deleted");
                    },
                  )
                : Text(""));
      },
    );
  }

  postPicture() {
    return GestureDetector(
      onDoubleTap: () {
        print("Liked");
      },
      child: Stack(
        alignment: Alignment.center,
        children: [Image.network(url)],
      ),
    );
  }

  postFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(padding: EdgeInsets.only(top: 40, left: 30)),
            GestureDetector(
              onTap: () {
                print("Liked");
              },
              child: Icon(
                Icons.favorite, color: Colors.grey,
                // isLiked ? Icons.favorite : Icons.favorite_border,
                // size: 28,
                // color: Colors.pink,
              ),
            ),
            SizedBox(
              width: 20,
            ),
            GestureDetector(
              onTap: () {
                print("show Comments");
              },
              child: Icon(
                Icons.chat_bubble_outline,
                size: 28,
                color: Colors.black,
              ),
            ),
          ],
        ),
        Row(
          children: [
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(
                "$username ",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Text(
                "$description",
                style: TextStyle(color: Colors.black),
              ),
            )
          ],
        )
      ],
    );
  }
}
