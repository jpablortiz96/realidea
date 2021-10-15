
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:realidea/models/user.dart';
import 'package:realidea/pages/CreateAccountPage.dart';
import 'package:realidea/pages/NotificationsPage.dart';
import 'package:realidea/pages/SearchPage.dart';
import 'package:realidea/pages/UploadPage.dart';
import 'package:realidea/pages/ProfilePage.dart';
import 'package:realidea/pages/TimeLinePage.dart';


final GoogleSignIn gSignIn = GoogleSignIn();
final userReference = Firestore.instance.collection("users");
final StorageReference storageReference = FirebaseStorage.instance.ref().child("Post Ideas");
final postReference = Firestore.instance.collection("posts");
final activityFeedReference = Firestore.instance.collection("feed");
final commentsReference = Firestore.instance.collection("comments");
final followersReference = Firestore.instance.collection("followers");
final followingReference = Firestore.instance.collection("following");
final timeLineReference = Firestore.instance.collection("timeline");

final DateTime timestamp = DateTime.now();

User currentUser;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  bool isSignedIn = false;
  PageController pageController;
  int getPageIndex = 0;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void initState(){
    super.initState();

    pageController = PageController();

    gSignIn.onCurrentUserChanged.listen((gSignInAccount) {
      controlSignIn(gSignInAccount);
    }, onError:(gError){
      print("Error Message" + gError);
    });

    gSignIn.signInSilently(suppressErrors: false).then((gSignInAccount){
      controlSignIn(gSignInAccount);
    }).catchError((gError){
      print("Error Message" + gError);
    });
  }

  controlSignIn(GoogleSignInAccount signInAccount) async {
    if(signInAccount!=null){
      await saveUserInfoToFirestore();
      setState(() {
        isSignedIn = true;
      });

      configureRealTimePushNotifications();
    }
    else{
      setState(() {
        isSignedIn=false;
      });
    }
  }

  configureRealTimePushNotifications(){
    final GoogleSignInAccount gUser = gSignIn.currentUser;
    if(Platform.isIOS){
      getIOSPermissions();
    }
    _firebaseMessaging.getToken().then((token) {
      userReference.document(gUser.id).updateData({"androidNotificationToken": token});
    });
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> msg) async {
      final String recipientId = msg["data"]["recipient"];
      final String body = msg["notification"]["body"];

      if(recipientId == gUser.id){
        SnackBar snackBar = SnackBar(
          backgroundColor: Colors.grey,
          content: Text(body, style: TextStyle(color: Colors.white),overflow: TextOverflow.ellipsis,),
        );
        _scaffoldKey.currentState.showSnackBar(snackBar);
      }
      },
    );
  }

  getIOSPermissions(){
    _firebaseMessaging.requestNotificationPermissions(IosNotificationSettings(alert: true, badge: true, sound: true));
    _firebaseMessaging.onIosSettingsRegistered.listen((setting) {
      print("Configuraciones registradas: $setting");
    });
  }

  saveUserInfoToFirestore() async {

    final GoogleSignInAccount gCurrentUser = gSignIn.currentUser;
    DocumentSnapshot documentSnapshot = await userReference.document(gCurrentUser.id).get();
    if(!documentSnapshot.exists){

      final username = await Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAccountPage()));

      userReference.document(gCurrentUser.id).setData({
        "id":gCurrentUser.id,
        "profileName": gCurrentUser.displayName,
        "username": username,
        "url": gCurrentUser.photoUrl,
        "email": gCurrentUser.email,
        "bio":"",
        "timestamp": timestamp,
      });

      await followersReference.document(gCurrentUser.id).collection("userFollowers").document(gCurrentUser.id).setData({});

      documentSnapshot = await userReference.document(gCurrentUser.id).get();
    }
    currentUser = User.fromDocument(documentSnapshot);
  }

  void dispose(){
    pageController.dispose();
    super.dispose();
  }

  loginUser(){
    gSignIn.signIn();
  }

  logoutUser(){
    gSignIn.signOut();
  }

  whenPagesChanges(int pageIndex){
    setState(() {
      this.getPageIndex = pageIndex;
    });
  }

  onTapChangePage(int pageIndex){
    pageController.animateToPage(pageIndex, duration: Duration(milliseconds: 400), curve: Curves.bounceInOut);
  }

  Scaffold buildHomeScreen() {
    return Scaffold(
      key: _scaffoldKey,
      body: PageView(
        children: <Widget>[
          TimeLinePage(gCurrentUser: currentUser,),
          SearchPage(),
          UploadPage(gCurrentUser: currentUser,),
          NotificationsPage(),
          ProfilePage(userProfileId: currentUser.id),
        ],
        controller: pageController,
        onPageChanged: whenPagesChanges,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: getPageIndex,
        onTap: onTapChangePage,
        backgroundColor: Hexcolor("#fbcb4c"),
        activeColor: Colors.white,
        inactiveColor: Colors.black,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home)),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(icon: Icon(Icons.lightbulb_outline, size: 37.0)),
          BottomNavigationBarItem(icon: Icon(Icons.favorite)),
          BottomNavigationBarItem(icon: Icon(Icons.person)),

        ],
      ),
    );
    //return RaisedButton.icon(onPressed: logoutUser, icon: Icon(Icons.close), label: Text("Cerrar sesión"));
  }

  Scaffold buildSignInScreen() {
    return Scaffold(
      body: Container(
        decoration:  BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Hexcolor("#fbcb4c"),Hexcolor("#ffffff")]
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "Realidea",
              style: TextStyle(fontSize: 92.0, color: Hexcolor("#a16c40"), fontFamily: "Raleway"),
            ),
            GestureDetector(
              onTap: loginUser,
              child: Container(
                width: 270,
                height: 60,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/google_sign_in.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if(isSignedIn)
      {
        return buildHomeScreen();
      }
    else
      {
        return buildSignInScreen();
      }
  }


}


