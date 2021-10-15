import 'package:flutter/material.dart';
import 'package:realidea/pages/HomePage.dart';
import 'package:realidea/widgets/HeaderWidget.dart';
import 'package:realidea/widgets/PostWidget.dart';
import 'package:realidea/widgets/ProgressWidget.dart';

class PostScreenPage extends StatelessWidget {

  final String postId;
  final String userId;


  PostScreenPage({
    this.userId, this.postId
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: postReference.document(userId).collection("usersPosts").document(postId).get(),
      builder: (context, dataSnapshot){
        if(!dataSnapshot.hasData){
          return circularProgress();
        }

        Post post = Post.fromDocument(dataSnapshot.data);
        return Center(
          child: Scaffold(
            appBar: header(context, strTitle: post.description),
            body: ListView(
              children: <Widget>[
                Container(
                  child: post,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
