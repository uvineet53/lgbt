import 'dart:async';

import 'package:buddiesgram/models/user.dart';
import 'package:buddiesgram/pages/CommentsPage.dart';
import 'package:buddiesgram/pages/HomePage.dart';
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
  bool isLiked;
  bool showHeart = false;
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
    isLiked = (likes[currentUserId] == true);
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

  userLike() {
    bool liked = likes[currentUserId] == true;
    if (liked) {
      postsReference
          .document(ownerId)
          .collection("userPosts")
          .document(postId)
          .updateData({"likes.$currentUserId": false});
      removelike();
      setState(() {
        likeCount--;
        isLiked = false;
        likes[currentUserId] = false;
      });
    } else if (!liked) {
      postsReference
          .document(ownerId)
          .collection("userPosts")
          .document(postId)
          .updateData({"likes.$currentUserId": true});
      addlike();
      setState(() {
        likeCount++;
        isLiked = true;
        likes[currentUserId] = true;
        showHeart = true;
      });
      Timer(Duration(milliseconds: 600), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  addlike() {
    bool noPostOwner = currentUserId != ownerId;
    if (!noPostOwner) {
      activityReference
          .document(ownerId)
          .collection("feedItems")
          .document(postId)
          .setData({
        "type": "like",
        "username": currentUser.username,
        "userId": currentUser.id,
        "timestamp": timestamp,
        "url": url,
        "postId": postId,
        "userProfileImage": currentUser.url
      });
    }
  }

  removelike() {
    bool noPostOwner = currentUserId != ownerId;
    if (!noPostOwner) {
      activityReference
          .document(ownerId)
          .collection("feedItems")
          .document(postId)
          .get()
          .then((value) {
        if (value.exists) {
          value.reference.delete();
        }
      });
    }
  }

  postPicture() {
    return GestureDetector(
      onDoubleTap: () {
        userLike();
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.network(url),
          showHeart
              ? Icon(
                  Icons.favorite,
                  size: 120,
                  color: Colors.pink,
                )
              : Text("")
        ],
      ),
    );
  }

  comments({BuildContext context, String postId, String ownerId, String url}) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CommentsPage(postId: postId, ownerId: ownerId, url: url),
        ));
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
                userLike();
              },
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                size: 28,
                color: Colors.pink,
              ),
            ),
            SizedBox(
              width: 20,
            ),
            GestureDetector(
              onTap: () {
                comments(
                    context: context,
                    postId: postId,
                    ownerId: ownerId,
                    url: url);
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
