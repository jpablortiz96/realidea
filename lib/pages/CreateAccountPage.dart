import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:realidea/widgets/HeaderWidget.dart';

class CreateAccountPage extends StatefulWidget {
  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  String username;

  submitUserName(){
    final form = _formKey.currentState;
    if(form.validate()){
      form.save();

      SnackBar snackBar = SnackBar(content: Text(username+", es momento de hacer nuestras ideas realidades"));
      _scaffoldKey.currentState.showSnackBar(snackBar);
      Timer(Duration(seconds: 4), (){
        Navigator.pop(context,username);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(context,strTitle: "Hola, Bienvenido(a)",dissappearedBackButton: true),
      body: ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 26.0),
                  child: Center(
                    child: Text("Crea un nombre de usuario", style: TextStyle(fontSize: 26.0, color: Hexcolor("#fbcb4c")),),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(17.0),
                  child: Container(
                    child: Form(
                      key: _formKey,
                      autovalidate: true,
                      child: TextFormField(
                        style: TextStyle(color:  Colors.black),
                        validator: (val){
                          if(val.trim().length<5 || val.isEmpty){
                            return "El nombre de usuario es muy corto";
                          }
                          else if(val.trim().length>15){
                            return "El nombre de usuario es muy largo";
                          }
                          else{
                            return null;
                          }
                        },
                        onSaved: (val) => username = val,
                        decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          border: OutlineInputBorder(),
                          labelText: "Nombre de usuario",
                          labelStyle: TextStyle(fontSize: 16.0),
                          hintText: "Debe tener por lo menos 5 caracteres",
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: submitUserName,
                  child: Container(
                    height: 55.0,
                    width: 360.0,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Center(
                      child: Text(
                        "Continuar",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
}
