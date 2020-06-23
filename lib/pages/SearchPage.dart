import 'package:buddiesgram/models/user.dart';
import 'package:buddiesgram/pages/HomePage.dart';
import 'package:buddiesgram/pages/ProfilePage.dart';
import 'package:buddiesgram/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with AutomaticKeepAliveClientMixin<SearchPage> {
  TextEditingController _searchController = new TextEditingController();
  Future<QuerySnapshot> futureSearchResults;
  emptyTextformField() {
    _searchController.clear();
    setState(() {
      futureSearchResults = null;
    });
  }

  controlSearching(String str) {
    //TODO:Improve Searching method
    Future<QuerySnapshot> allUsers = userReference
        .where("profileName", isGreaterThanOrEqualTo: str)
        .getDocuments();

    setState(() {
      futureSearchResults = allUsers;
    });
  }

  Container displayNoSearchResultScreen() {
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Icon(Icons.group, color: Colors.grey[800], size: 200.0),
            Text(
              "Search Users",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 48.0),
            )
          ],
        ),
      ),
    );
  }

  displayUserFoundScreen() {
    return FutureBuilder(
      future: futureSearchResults,
      builder: (context, dataSnapshot) {
        if (!dataSnapshot.hasData) {
          return circularProgress();
        }
        List<UserResult> searchUserResult = [];
        dataSnapshot.data.documents.forEach((document) {
          User eachUser = User.fromDocument(document);
          UserResult userResult = UserResult(eachUser);
          searchUserResult.add(userResult);
        });
        return ListView(children: searchUserResult);
      },
    );
  }

  AppBar searchPageHeader() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.0,
      title: TextFormField(
        style: TextStyle(fontSize: 18.0, color: Colors.black),
        controller: _searchController,
        decoration: InputDecoration(
            fillColor: Colors.white,
            hintText: "Search Here...",
            hintStyle: TextStyle(color: Colors.grey[800]),
            border: InputBorder.none,
            filled: true,
            prefixIcon: Icon(
              Icons.person_pin,
              color: Colors.black,
              size: 30.0,
            ),
            suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              color: Colors.black,
              onPressed: emptyTextformField,
            )),
        onFieldSubmitted: controlSearching,
      ),
    );
  }

  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: searchPageHeader(),
      body: futureSearchResults == null
          ? displayNoSearchResultScreen()
          : displayUserFoundScreen(),
    );
  }
}

class UserResult extends StatelessWidget {
  final User eachUser;
  UserResult(this.eachUser);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: () =>
                  displayUserProfile(context: context, profileId: eachUser.id),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.black,
                  backgroundImage: CachedNetworkImageProvider(eachUser.url),
                ),
                title: Text(
                  eachUser.profileName,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  eachUser.username,
                  style: TextStyle(color: Colors.black, fontSize: 13.0),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  displayUserProfile({BuildContext context, String profileId}) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ProfilePage(
        userProfileId: profileId,
      ),
    ));
  }
}
