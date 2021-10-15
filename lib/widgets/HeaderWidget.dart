import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

AppBar header(context, {bool isAppTitle=false, String strTitle, dissappearedBackButton=false}){
  return AppBar(
    iconTheme: IconThemeData(
      color: Hexcolor("#ffffff"),
    ),
    automaticallyImplyLeading: dissappearedBackButton ? false: true,
    title: Text(
      isAppTitle ? "Realidea" : strTitle,
      style: TextStyle(
        color: Colors.white,
        fontFamily: isAppTitle ? "Raleway" : "",
        fontSize: isAppTitle ? 45.0 : 22.0,
      ),
      overflow: TextOverflow.ellipsis,
    ),
    centerTitle: true,
    backgroundColor: Hexcolor("#fbcb4c"),
  );
}