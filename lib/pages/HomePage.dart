import 'package:buddiesgram/models/user.dart';
import 'package:buddiesgram/pages/CreateAccountPage.dart';
import 'package:buddiesgram/pages/NotificationsPage.dart';
import 'package:buddiesgram/pages/ProfilePage.dart';
import 'package:buddiesgram/pages/SearchPage.dart';
import 'package:buddiesgram/pages/TimeLinePage.dart';
import 'package:buddiesgram/pages/UploadPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn gSignIn = GoogleSignIn();
final userReference = Firestore.instance.collection("users");
final DateTime timestamp = DateTime.now();
User currentUser;
final StorageReference storageReference =
    FirebaseStorage.instance.ref().child("Posts Pictures");
final postsReference = Firestore.instance.collection("posts");

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isSignedIn = false;
  PageController pageController;
  int getPageIndex = 0;
  controlSignIn(GoogleSignInAccount signInAccount) async {
    if (signInAccount != null) {
      await saveUserInfoToFirestore();
      setState(() {
        isSignedIn = true;
      });
    } else {
      setState(() {
        isSignedIn = false;
      });
    }
  }

  saveUserInfoToFirestore() async {
    final GoogleSignInAccount gcurrentUser = gSignIn.currentUser;
    DocumentSnapshot documentSnapshot =
        await userReference.document(gcurrentUser.id).get();
    if (!documentSnapshot.exists) {
      final username = await Navigator.push(context,
          MaterialPageRoute(builder: (context) => CreateAccountPage()));
      userReference.document(gcurrentUser.id).setData({
        "id": gcurrentUser.id,
        "profileName": gcurrentUser.displayName,
        "username": username,
        "url": gcurrentUser.photoUrl,
        "email": gcurrentUser.email,
        "bio": "",
        "timestamp": timestamp
      });
      documentSnapshot = await userReference.document(gcurrentUser.id).get();
    }
    currentUser = User.fromDocument(documentSnapshot);
  }

  loginUser() {
    gSignIn.signIn();
  }

  logoutUser() {
    gSignIn.signOut();
  }

  whenPageChanges(int pageIndex) {
    setState(() {
      this.getPageIndex = pageIndex;
    });
  }

  onTabChangePage(int pageIndex) {
    pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 400),
      curve: Curves.bounceInOut,
    );
  }

  Widget buildHomeScreen() {
    return Scaffold(
      body: PageView(
        children: <Widget>[
          // TimeLinePage(),
          RaisedButton.icon(
            icon: Icon(Icons.close),
            label: Text("Sign Out"),
            onPressed: logoutUser,
          ),
          SearchPage(),
          UploadPage(
            gcurrentUser: currentUser,
          ),
          NotificationsPage(),
          ProfilePage()
        ],
        controller: pageController,
        onPageChanged: whenPageChanges,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: getPageIndex,
        onTap: onTabChangePage,
        activeColor: Colors.white,
        backgroundColor: Theme.of(context).accentColor,
        inactiveColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home)),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(
              icon: Icon(
            Icons.photo_camera,
            size: 37.0,
          )),
          BottomNavigationBarItem(icon: Icon(Icons.favorite)),
          BottomNavigationBarItem(icon: Icon(Icons.person)),
        ],
      ),
    );
  }

  Scaffold buildSignInScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
              Theme.of(context).accentColor,
              Theme.of(context).primaryColor
            ])),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "Selene",
              style: TextStyle(
                  color: Colors.white, fontFamily: "Signatra", fontSize: 92.0),
            ),
            InkWell(
              onTap: loginUser,
              child: Container(
                width: 270.0,
                height: 65.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image:
                          AssetImage("assets/images/google_signin_button.png"),
                      fit: BoxFit.cover),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pageController = PageController();
    gSignIn.onCurrentUserChanged.listen((gSignInAccount) {
      controlSignIn(gSignInAccount);
    }, onError: (gError) {
      print("Error message: $gError");
    });
    gSignIn.signInSilently(suppressErrors: false).then((gSignInAccount) {
      controlSignIn(gSignInAccount);
    }).catchError((gError) {
      print("Error message: $gError");
    });
  }

  void dispose() {
    pageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isSignedIn) {
      return buildHomeScreen();
    } else {
      return buildSignInScreen();
    }
  }
}
