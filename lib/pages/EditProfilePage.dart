
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:realidea/models/user.dart';
import 'package:realidea/pages/HomePage.dart';
import 'package:realidea/pages/ProfilePage.dart';
import 'package:realidea/widgets/ProgressWidget.dart';

class EditProfilePage extends StatefulWidget {

  final String currentOnlineUserId;
  EditProfilePage({
    this.currentOnlineUserId,
});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {

  TextEditingController profileNameTextEditingController = TextEditingController();
  TextEditingController bioTextEditingController = TextEditingController();
  final _scaffoldGlobalKey = GlobalKey<ScaffoldState>();
  bool loading = false;
  User user;
  bool _bioValid = true;
  bool _profileNameValid = true;


  void initState() {
    super.initState();

    getAndDisplayUserInformation();
  }

  getAndDisplayUserInformation() async{
    setState(() {
      loading = true;
    });

    DocumentSnapshot documentSnapshot = await userReference.document(widget.currentOnlineUserId).get();
    user = User.fromDocument(documentSnapshot);

    profileNameTextEditingController.text = user.profileName;
    bioTextEditingController.text = user.bio;

    setState(() {
      loading = false;
    });
  }

  updateUserData(){
    setState(() {
      profileNameTextEditingController.text.trim().length < 5 || profileNameTextEditingController.text.isEmpty ? _profileNameValid = false : _profileNameValid = true;
      bioTextEditingController.text.trim().length > 280 ? _bioValid = false : _bioValid = true;
    });

    if(_bioValid && _profileNameValid){
      userReference.document(widget.currentOnlineUserId).updateData({
        "profileName": profileNameTextEditingController.text,
        "bio": bioTextEditingController.text,
      });

      SnackBar snackBar = SnackBar(content: Text("Perfil actualizado exitosamente."));
      _scaffoldGlobalKey.currentState.showSnackBar(snackBar);

    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldGlobalKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text("Editar perfil", style: TextStyle(color: Colors.black),),
        actions: [
          IconButton(icon: Icon(Icons.done, color: Colors.black, size: 30.0,), onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> ProfilePage(userProfileId: widget.currentOnlineUserId,))))
        ],
      ),
      body: loading ? circularProgress() : ListView(
        children: <Widget> [
          Container(
            child: Column(
              children: <Widget> [
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 7.0),
                  child: CircleAvatar(
                    radius: 52.0,
                    backgroundImage: CachedNetworkImageProvider(user.url),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(children: <Widget>[createProfileNameTextFormField(), createBioTextFormField()],),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 29.0, left: 50.0, right: 50.0),
                  child: RaisedButton(
                    onPressed: updateUserData,
                  child: Text(
                    "Actualizar",
                    style: TextStyle(color: Colors.black, fontSize: 16.0),
                  ),
                 ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0, left: 50.0, right: 50.0),
                  child: RaisedButton(
                    color: Colors.yellow,
                    onPressed: logoutUser,
                    child: Text(
                      "Cerrar sesión",
                      style: TextStyle(color: Colors.black, fontSize: 16.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  logoutUser() async {
    await gSignIn.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context)=> HomePage()));
  }

  Column createProfileNameTextFormField(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 13.0),
          child: Text(
            "Nombre de Perfil", style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          style: TextStyle(color: Colors.black),
          controller: profileNameTextEditingController,
          decoration: InputDecoration(
            hintText: "Escribe el nombre del perfil aqui...",
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            hintStyle: TextStyle(color: Colors.grey),
            errorText: _profileNameValid ? null: "El nombre de perfil es muy corto",
          ),
        ),
      ],
    );
  }

  Column createBioTextFormField(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 13.0),
          child: Text(
            "Biografía", style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          style: TextStyle(color: Colors.black),
          controller: bioTextEditingController,
          decoration: InputDecoration(
            hintText: "Describe tu biografía aqui...",
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            hintStyle: TextStyle(color: Colors.grey),
            errorText: _bioValid ? null: "La biografía es muy larga",
          ),
        ),
      ],
    );
  }

}
