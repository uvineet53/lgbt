import 'package:buddiesgram/pages/PostScreenPage.dart';
import 'package:buddiesgram/widgets/ProgressWidget.dart';
import 'package:timeago/timeago.dart' as tAgo;
import 'package:buddiesgram/pages/HomePage.dart';
import 'package:buddiesgram/widgets/HeaderWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'ProfilePage.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, strTitle: "Notifications", isAppTitle: false),
      body: Container(
        child: FutureBuilder(
          future: getNotifications(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return circularProgress();
            }
            return ListView(
              children: snapshot.data,
            );
          },
        ),
      ),
    );
  }

  getNotifications() async {
    QuerySnapshot querySnapshot = await activityReference
        .document(currentUser.id)
        .collection("feedItems")
        .orderBy("timestamp", descending: true)
        .limit(60)
        .getDocuments();

    List<NotificationsItem> notificationItem = [];
    querySnapshot.documents.forEach((element) {
      if (element.data.containsValue(currentUser.id) == false) {
        notificationItem.add(NotificationsItem.fromDocument(element));
      }
    });
    return notificationItem;
  }
}

Widget mediaPreview;
String notificationText;

class NotificationsItem extends StatelessWidget {
  final String username;
  final String type;
  final String commentData;
  final String postId;
  final String userId;
  final String userProfileImg;
  final String url;
  final Timestamp timestamp;
  NotificationsItem(
      {this.commentData,
      this.postId,
      this.timestamp,
      this.type,
      this.url,
      this.userId,
      this.userProfileImg,
      this.username});

  factory NotificationsItem.fromDocument(DocumentSnapshot snapshot) {
    return NotificationsItem(
      username: snapshot["username"],
      type: snapshot["type"],
      commentData: snapshot["commentData"],
      postId: snapshot["postId"],
      userId: snapshot["userId"],
      userProfileImg: snapshot["userProfileImage"],
      url: snapshot["url"],
      timestamp: snapshot["timestamp"],
    );
  }
  @override
  Widget build(BuildContext context) {
    configureMediaPreview(context);
    return Padding(
      padding: EdgeInsets.all(6),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[400],
        ),
        child: ListTile(
          title: GestureDetector(
            onTap: () =>
                displayUserProfile(context: context, profileId: userId),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                  style: TextStyle(fontSize: 14, color: Colors.black),
                  children: [
                    TextSpan(
                        text: username,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: " $notificationText")
                  ]),
            ),
          ),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(userProfileImg),
          ),
          subtitle: Text(
            tAgo.format(timestamp.toDate()),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: mediaPreview,
        ),
      ),
    );
  }

  configureMediaPreview(context) {
    if (type == "comment" || type == "like") {
      mediaPreview = GestureDetector(
        onTap: () =>
            displayOwnPost(context: context, profileId: currentUser.id),
        child: Container(
          height: 50,
          width: 50,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: CachedNetworkImageProvider(url))),
            ),
          ),
        ),
      );
    } else {
      mediaPreview = Text("");
    }
    if (type == "like") {
      notificationText = "liked your post.";
    } else if (type == "comment") {
      notificationText = "commented on your post: $commentData.";
    } else if (type == "follow") {
      notificationText = "started following you.";
    } else {
      notificationText = "Error, Unkown type : $type ";
    }
  }

  displayOwnPost({BuildContext context, String profileId}) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(
            userProfileId: currentUser.id,
          ),
        ));
  }

  displayUserProfile({BuildContext context, String profileId}) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ProfilePage(
        userProfileId: profileId,
      ),
    ));
  }
}
