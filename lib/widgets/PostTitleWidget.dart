import 'package:flutter/material.dart';
import 'package:realidea/pages/PostScreenPage.dart';
import 'package:realidea/widgets/PostWidget.dart';

class PostTitle extends StatelessWidget {

  final Post post;

  PostTitle(this.post);

  displayFullPost(context){
    Navigator.push(context, MaterialPageRoute(builder: (context)=> PostScreenPage(postId: post.postId, userId: post.ownerId)));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=> displayFullPost(context),
      child: Image.network(post.url),
    );
  }
}
