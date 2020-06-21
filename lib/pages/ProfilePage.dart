import 'package:buddiesgram/models/user.dart';
import 'package:buddiesgram/pages/EditProfilePage.dart';
import 'package:buddiesgram/widgets/HeaderWidget.dart';
import 'package:buddiesgram/widgets/PostTileWidget.dart';
import 'package:buddiesgram/widgets/PostWidget.dart';
import 'package:buddiesgram/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'HomePage.dart';

class ProfilePage extends StatefulWidget {
  final String userProfileId;
  ProfilePage({this.userProfileId});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String currentOnlineUserId = currentUser.id;
  List<Post> postsList;
  String postOrientation = "grid";

  createProfileTopView() {
    return FutureBuilder(
      future: userReference.document(widget.userProfileId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data);
        return Padding(
          padding: EdgeInsets.all(17),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 45.0,
                    backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(user.url),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            createColumns("Posts", 0),
                            createColumns("Followers", 0),
                            createColumns("Following", 0),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[createButton()],
                        ),
                      ],
                    ),
                  )
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 13),
                child: Text(
                  "${user.username}",
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 5),
                child: Text(
                  "${user.profileName}",
                  style: TextStyle(fontSize: 19, color: Colors.black),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 5),
                child: Text(
                  "${user.bio}",
                  style: TextStyle(fontSize: 19, color: Colors.grey[700]),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    getAllProfilePosts();
  }

  int countPost = 0;
  getAllProfilePosts() async {
    setState(() {
      loading = true;
    });
    QuerySnapshot querySnapshot = await postsReference
        .document(widget.userProfileId)
        .collection("userPosts")
        .orderBy("timestamp", descending: true)
        .getDocuments();
    setState(() {
      loading = false;
      countPost = querySnapshot.documents.length;
      postsList = querySnapshot.documents
          .map((snapshot) => Post.fromDocument(snapshot))
          .toList();
    });
  }

  createButton() {
    bool ownProfile = currentOnlineUserId == widget.userProfileId;
    if (ownProfile) {
      return createButtonTitleAndFunction(
          title: "Edit Profile", performFunction: editUserProfile);
    }
  }

  editUserProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              EditProfilePage(currentOnlineUserId: currentOnlineUserId),
        ));
  }

  createButtonTitleAndFunction({String title, Function performFunction}) {
    return Container(
      padding: EdgeInsets.only(top: 3.0),
      child: FlatButton(
        onPressed: performFunction,
        child: Container(
          width: 245.0,
          height: 30,
          child: Text(
            "$title",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }

  Column createColumns(String title, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(
              fontSize: 20.0, color: Colors.black, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 5),
          child: Text(
            title,
            style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey,
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, strTitle: "Profile", isAppTitle: false),
      body: ListView(
        children: <Widget>[
          createProfileTopView(),
          Divider(),
          gridpost(),
          Divider(
            height: 0.0,
          ),
          createProfilePost()
        ],
      ),
    );
  }

  setOrientation(String o) {
    setState(() {
      postOrientation = o;
    });
  }

  gridpost() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () {
            setOrientation("grid");
          },
          icon: Icon(Icons.grid_on),
          color: postOrientation == "grid" ? Colors.red : Colors.grey,
        ),
        IconButton(
          onPressed: () {
            setOrientation("list");
          },
          icon: Icon(Icons.grid_off),
          color: postOrientation == "list" ? Colors.red : Colors.grey,
        )
      ],
    );
  }

  bool loading = false;
  createProfilePost() {
    if (loading) {
      return circularProgress();
    } else if (postsList.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: Icon(
                Icons.photo_library,
                color: Colors.grey,
                size: 200,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "No Posts to Show",
              style: TextStyle(color: Colors.grey, fontSize: 40),
            )
          ],
        ),
      );
    } else if (postOrientation == "grid") {
      List<GridTile> gridTile = [];
      postsList.forEach((eachPost) {
        gridTile.add(GridTile(
          child: PostTile(
            post: eachPost,
          ),
        ));
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTile,
      );
    } else if (postOrientation == "list") {
      return Column(
        children: postsList,
      );
    }
  }
}
