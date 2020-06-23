import 'package:buddiesgram/models/user.dart';
import 'package:buddiesgram/pages/HomePage.dart';
import 'package:buddiesgram/pages/ProfilePage.dart';
import 'package:buddiesgram/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";

class EditProfilePage extends StatefulWidget {
  final String currentOnlineUserId;
  EditProfilePage({this.currentOnlineUserId});
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _bioController = new TextEditingController();
  final _scaffoldkey = GlobalKey<ScaffoldState>();
  bool loading = false;
  User user;
  bool _profileNameValid = true;
  bool _bioValid = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserInfo();
  }

  getUserInfo() async {
    setState(() {
      loading = true;
    });
    DocumentSnapshot documentSnapshot =
        await userReference.document(widget.currentOnlineUserId).get();
    user = User.fromDocument(documentSnapshot);
    _nameController.text = user.profileName;
    _bioController.text = user.bio;
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          "Edit Profile",
          style: TextStyle(color: Colors.black),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      userProfileId: widget.currentOnlineUserId,
                    ),
                  ));
            },
            icon: Icon(
              Icons.done,
              color: Colors.black,
              size: 30,
            ),
          )
        ],
        elevation: 0.0,
      ),
      body: loading
          ? circularProgress()
          : ListView(
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 16, bottom: 16),
                        child: CircleAvatar(
                          radius: 52.0,
                          backgroundImage: CachedNetworkImageProvider(user.url),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: <Widget>[nametext(), biotext()],
                        ),
                      ),
                      SizedBox(
                        height: 29,
                      ),
                      FlatButton(
                        onPressed: updateData,
                        color: Colors.grey,
                        child: Text(
                          "Update",
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ),
                      SizedBox(
                        height: 29,
                      ),
                      FlatButton(
                        onPressed: logout,
                        color: Colors.red,
                        child: Text(
                          "Logout",
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }

  logout() async {
    await gSignIn.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(),
      ),
    );
  }

  updateData() {
    setState(() {
      _nameController.text.trim().length < 3 || _nameController.text.isEmpty
          ? _profileNameValid = false
          : _profileNameValid = true;

      _bioController.text.trim().length > 110
          ? _bioValid = false
          : _bioValid = true;
    });

    if (_bioValid && _profileNameValid) {
      userReference.document(widget.currentOnlineUserId).updateData(
          {"profileName": _nameController.text, "bio": _bioController.text});
      SnackBar snackBar = SnackBar(
        content: Text("Profile updated successfully"),
      );
      _scaffoldkey.currentState.showSnackBar(snackBar);
    }
  }

  Column nametext() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text(
            "Profile Name",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
              hintText: "Edit Profile Name",
              enabledBorder: InputBorder.none,
              hintStyle: TextStyle(color: Colors.grey),
              errorText:
                  _profileNameValid ? null : "Profile Name is not Valid"),
          style: TextStyle(color: Colors.black),
        ),
      ],
    );
  }

  Column biotext() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text(
            "Profile Name",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: _bioController,
          decoration: InputDecoration(
              hintText: "Edit Bio",
              enabledBorder: InputBorder.none,
              hintStyle: TextStyle(color: Colors.grey),
              errorText: _bioValid ? null : "Bio is not Valid"),
          style: TextStyle(color: Colors.black),
        ),
      ],
    );
  }
}
