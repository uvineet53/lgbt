import 'package:flutter/material.dart';

AppBar header(context,
    {bool isAppTitle = false, String strTitle, disableBackButton = false}) {
  return AppBar(
    elevation: 0.0,
    iconTheme: IconThemeData(color: Colors.white),
    automaticallyImplyLeading: disableBackButton ? false : true,
    title: Text(
      isAppTitle ? "Selene" : strTitle,
      style: TextStyle(
          color: Colors.black,
          fontFamily: isAppTitle ? "Signatra" : "",
          fontSize: isAppTitle ? 45.0 : 22.0),
      overflow: TextOverflow.ellipsis,
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).accentColor,
  );
}
