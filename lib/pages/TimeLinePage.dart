
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:realidea/models/user.dart';
import 'package:realidea/pages/HomePage.dart';
import 'package:realidea/widgets/HeaderWidget.dart';
import 'package:realidea/widgets/PostWidget.dart';
import 'package:realidea/widgets/ProgressWidget.dart';

class TimeLinePage extends StatefulWidget {

  final User gCurrentUser;

  TimeLinePage({this.gCurrentUser});

  @override
  _TimeLinePageState createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {

  List<Post> posts;
  List<String> followingsList= [];
  final scaffoldKey = GlobalKey<ScaffoldState>();

  retrieveTimeLine() async {
    QuerySnapshot querySnapshot = await timeLineReference.document(widget.gCurrentUser.id)
        .collection("timelinePosts").orderBy("timestamp", descending: true).getDocuments();

    List<Post> allPosts = querySnapshot.documents.map((document) => Post.fromDocument(document)).toList();

    setState(() {
      this.posts = allPosts;
    });
  }

  retrieveFollowings() async {
    QuerySnapshot querySnapshot = await followingReference.document(widget.gCurrentUser.id)
        .collection("userFollowing").getDocuments();

    setState(() {
      followingsList = querySnapshot.documents.map((document) => document.documentID).toList();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    retrieveTimeLine();
    retrieveFollowings();
  }

  createUserTimeLine(){
    if(posts == null){
      return circularProgress();
    }else{
      return ListView(children: posts,);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: header(context, isAppTitle: true),
      body: RefreshIndicator(child: createUserTimeLine(), onRefresh: () => retrieveTimeLine(),),
    );
  }
}
