
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:realidea/models/user.dart';
import 'package:realidea/pages/EditProfilePage.dart';
import 'package:realidea/pages/HomePage.dart';
import 'package:realidea/widgets/HeaderWidget.dart';
import 'package:realidea/widgets/PostTitleWidget.dart';
import 'package:realidea/widgets/PostWidget.dart';
import 'package:realidea/widgets/ProgressWidget.dart';


class ProfilePage extends StatefulWidget {

  final String userProfileId;

  ProfilePage({this.userProfileId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String currentOnlineUserId = currentUser?.id;
  bool loading = false;
  int countPost = 0;
  List<Post> postList = [];
  String postOrientation = "grid";
  int countTotalFollowers = 0;
  int countTotalFollowings = 0;
  bool following = false;

  void initState() {
    getAllProfilePost();
    getAllFollowers();
    getAllFollowings();
    checkIfAlreadyFollowing();
  }

  getAllFollowings() async {
    QuerySnapshot querySnapshot = await followingReference
        .document(widget.userProfileId).collection("userFollowing").getDocuments();

    setState(() {
      countTotalFollowings = querySnapshot.documents.length;
    });
  }

  checkIfAlreadyFollowing() async {
    DocumentSnapshot documentSnapshot = await followersReference
        .document(widget.userProfileId).collection("userFollowers")
        .document(currentOnlineUserId).get();

    setState(() {
      following = documentSnapshot.exists;
    });
  }

  getAllFollowers() async {
    QuerySnapshot querySnapshot = await followersReference
        .document(widget.userProfileId).collection("userFollowers").getDocuments();

    setState(() {
      countTotalFollowers = querySnapshot.documents.length;
    });
  }

  createProfileView(){
    return FutureBuilder(
      future: userReference.document(widget.userProfileId).get(),
      builder: (context, dataSnapshot){
        if(!dataSnapshot.hasData){
          return circularProgress();
        }
        User user = User.fromDocument(dataSnapshot.data);
        return Padding(
          padding: EdgeInsets.all(17.0),
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
                            createColumns("Ideas", countPost),
                            createColumns("Seguidores", countTotalFollowers),
                            createColumns("Seguidos", countTotalFollowings),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            createButton(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 13.0),
                child: Text(
                  user.username, style: TextStyle(fontSize: 14.0, color: Colors.black),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 5.0),
                child: Text(
                  user.profileName, style: TextStyle(fontSize: 18.0, color: Colors.black),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 3.0),
                child: Text(
                  user.bio, style: TextStyle(fontSize: 18.0, color: Colors.black54),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  Column createColumns(String title, int count){
   return Column(
     mainAxisAlignment: MainAxisAlignment.center,
     mainAxisSize: MainAxisSize.min,
     children: <Widget>[
       Text(
         count.toString(),
         style: TextStyle(fontSize: 20.0, color: Colors.black, fontWeight: FontWeight.bold),
       ),
       Container(
         margin: EdgeInsets.only(top: 5.0),
         child: Text(
           title,
           style:TextStyle(fontSize: 16.0, color: Colors.grey, fontWeight: FontWeight.w400),
         ),
       ),
     ],
   );
  }

  createButton(){
    bool ownProfile = currentOnlineUserId == widget.userProfileId;
    if(ownProfile){
      return createButtonTitleAndFunction(title: "Editar perfil", performFunction: editUserProfile);
    }
    else if(following){
      return createButtonTitleAndFunction(title: "Dejar de seguir", performFunction: controlUnfollowUser);
    }
    else if(!following){
      return createButtonTitleAndFunction(title: "Seguir", performFunction: controlfollowUser);
    }
  }

  controlUnfollowUser(){
    setState(() {
      following = false;
    });

    followersReference.document(widget.userProfileId)
        .collection("userFollowers")
        .document(currentOnlineUserId)
        .get()
        .then((document) {
          if(document.exists){
            document.reference.delete();
          }
    });

    followingReference.document(currentOnlineUserId)
        .collection("userFollowing")
        .document(widget.userProfileId)
        .get()
        .then((document) {
      if(document.exists){
        document.reference.delete();
      }
    });

    activityFeedReference.document(widget.userProfileId).collection("feedItems")
      .document(currentOnlineUserId).get().then((document) {
        if(document.exists){
          document.reference.delete();
        }
    });
  }

  controlfollowUser(){
    setState(() {
      following = true;
    });

    followersReference.document(widget.userProfileId).collection("userFollowers")
        .document(currentOnlineUserId)
        .setData({});

    followingReference.document(currentOnlineUserId).collection("userFollowing")
        .document(widget.userProfileId)
        .setData({});

    activityFeedReference.document(widget.userProfileId)
        .collection("feedItems")
        .document(currentOnlineUserId)
        .setData({
      "type": "follow",
      "ownerId":widget.userProfileId,
      "username": currentUser.username,
      "timestamp": DateTime.now(),
      "userProfileImg": currentUser.url,
      "userId": currentOnlineUserId,
    });

  }

  Container createButtonTitleAndFunction({String title, Function performFunction}){
    return Container(
      padding: EdgeInsets.only(top: 10.0),
      child: FlatButton(
        onPressed: performFunction,
          child: Container(
            width: 225.0,
            height: 26.0,
            child: Text(title, style: TextStyle(color: following ? Colors.grey : Colors.black, fontWeight: FontWeight.bold),),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: following ? Colors.white : Hexcolor("#fbcb4c"),
              border: Border.all(color: following ? Colors.grey : Colors.black54),
              borderRadius: BorderRadius.circular(6.0),
            ),
          ),
      ),
    );
  }

  editUserProfile(){
    Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfilePage(currentOnlineUserId: currentOnlineUserId)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, strTitle:"Perfil"),
      body: ListView(
        children: <Widget>[
          createProfileView(),
          Divider(),
          createListAndGridPostOrientation(),
          Divider(height: 0.0,),
          displayProfilePost(),
        ],
      ),
    );
  }

  displayProfilePost(){
    if(loading){
      return circularProgress();
    }
    else if(postList.isEmpty){
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
             padding: EdgeInsets.all(30.0),
             child: Icon(Icons.local_library, color: Colors.grey, size: 200.0,),
            ),
            Padding(padding: EdgeInsets.only(top: 20.0),
              child: Text("No se han publicado ideas todavia", style: TextStyle(color: Colors.black, fontSize: 20.0, fontWeight: FontWeight.bold),),
            ),
          ],
        ),
      );
    }
    else if(postOrientation == "grid"){
      List<GridTile> gridTitleList = [];
      postList.forEach((eachPost) {
        gridTitleList.add(GridTile(child: PostTitle(eachPost),));
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTitleList,
      );
    }
    else if(postOrientation == "list"){
      return Column(
        children: postList,
      );
    }
  }

  getAllProfilePost () async {
    setState(() {
      loading = true;
    });

    QuerySnapshot querySnapshot = await postReference.document(widget.userProfileId).collection("usersPosts").orderBy("timestamp", descending: true).getDocuments();

    setState(() {
      loading = false;
      countPost = querySnapshot.documents.length;
      postList = querySnapshot.documents.map((documentSnapshot) => Post.fromDocument(documentSnapshot)).toList();
    });

  }

  createListAndGridPostOrientation(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          onPressed: ()=> setOrientation("grid"),
          icon: Icon(Icons.grid_on),
          color: postOrientation == "grid" ? Hexcolor("#fbcb4c") : Colors.grey,
        ),
        IconButton(
          onPressed: ()=> setOrientation("list"),
          icon: Icon(Icons.list),
          color: postOrientation == "list" ? Hexcolor("#fbcb4c") : Colors.grey,
        ),
      ],
    );
  }

  setOrientation(String orientation){
    setState(() {
      this.postOrientation = orientation;
    });
  }

}

