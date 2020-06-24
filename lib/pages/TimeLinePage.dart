import 'package:buddiesgram/models/user.dart';
import 'package:buddiesgram/widgets/HeaderWidget.dart';
import 'package:buddiesgram/widgets/PostWidget.dart';
import 'package:buddiesgram/widgets/ProgressWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'HomePage.dart';

class TimeLinePage extends StatefulWidget {
  final User gCurrentUser;
  TimeLinePage({this.gCurrentUser});
  @override
  _TimeLinePageState createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Post> posts;
  List<String> followingList = [];

  retrieveTimeline() async {
    QuerySnapshot querySnapshot = await timelineReference
        .document(widget.gCurrentUser.id)
        .collection("timelinePosts")
        .orderBy("timestamp", descending: true)
        .getDocuments();

    List<Post> allposts = querySnapshot.documents
        .map((document) => Post.fromDocument(document))
        .toList();
    setState(() {
      this.posts = allposts;
    });
  }

  retrieveFollowing() async {
    QuerySnapshot querySnapshot = await followingReference
        .document(currentUser.id)
        .collection("userFollowing")
        .getDocuments();
    setState(() {
      followingList = querySnapshot.documents
          .map((document) => document.documentID)
          .toList();
    });
  }

  createUserTimeline() {
    if (posts == null) {
      return circularProgress();
    } else {
      return ListView(
        children: posts,
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    retrieveTimeline();
    retrieveFollowing();
  }

  @override
  Widget build(context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(context, isAppTitle: true),
      body: RefreshIndicator(
        color: Colors.purple[800],
        backgroundColor: Colors.purple[100],
        child: createUserTimeline(),
        onRefresh: () => retrieveTimeline(),
      ),
    );
  }
}
