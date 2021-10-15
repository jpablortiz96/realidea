import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:realidea/models/user.dart';
import 'package:realidea/pages/HomePage.dart';
import 'package:realidea/widgets/ProgressWidget.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as ImD;

class UploadPage extends StatefulWidget {

  final User gCurrentUser;

  UploadPage({this.gCurrentUser});

  @override
  _UploadPageState createState() => _UploadPageState();
}


class _UploadPageState extends State<UploadPage> with AutomaticKeepAliveClientMixin<UploadPage>
{

  File file;
  bool uploading = false;
  String postId = Uuid().v4();
  TextEditingController descriptionTextEditingController = TextEditingController();
  TextEditingController locationTextEditingController = TextEditingController();


  captureImageWithCamara() async {
    Navigator.pop(context);
    File imageFile = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 680,
      maxWidth: 970,
    );
    setState(() {
      this.file = imageFile;
    });
  }

  pickImageFromGallery() async {
    Navigator.pop(context);
    File imageFile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );
    setState(() {
      this.file = imageFile;
    });
  }

  takeImage(mContext){
    return showDialog(
      context: mContext,
      builder: (context){
        return SimpleDialog(
          title: Text("Nueva idea", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
          children: <Widget>[
            SimpleDialogOption(
              child: Text("Capturar idea con la cámara", style: TextStyle(color: Hexcolor("#fbcb4c")),),
              onPressed: () {captureImageWithCamara();},
            ),
            SimpleDialogOption(
              child: Text("Selecciona la idea de tu galería", style: TextStyle(color: Hexcolor("#fbcb4c")),),
              onPressed: () {pickImageFromGallery();},
            ),
            SimpleDialogOption(
              child: Text("Cancelar", style: TextStyle(color: Colors.black),),
              onPressed: (){Navigator.pop(context, true);},
            ),
          ],
        );
      }
    );

  }

  displayUploadScreen(){
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.add_photo_alternate, color: Hexcolor("#fbcb4c"),size: 200.0,),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: RaisedButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9.0)),
              child: Text("Cargar imagen de la idea", style: TextStyle(color: Colors.white, fontSize: 20.0),),
              color: Colors.black,
              onPressed: () => takeImage(context)
            ),
          ),
        ],
      ),
    );
  }

  clearPostInfo()
  {
   locationTextEditingController.clear();
   descriptionTextEditingController.clear();
   setState(() {
     file = null;
   });
  }

  getCurrentLocation() async {
    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placeMarks = await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark mPlaceMark = placeMarks[0];
    String completeAddressInfo = '${mPlaceMark.subThoroughfare} ${mPlaceMark.thoroughfare}, ${mPlaceMark.subLocality} ${mPlaceMark.locality}, ${mPlaceMark.subAdministrativeArea} ${mPlaceMark.administrativeArea}, ${mPlaceMark.postalCode} ${mPlaceMark.country}.';
    String specificAddress = '${mPlaceMark.locality}, ${mPlaceMark.country}';
    locationTextEditingController.text = specificAddress;
  }

  compressingPhoto() async {
    final tDirectory = await getTemporaryDirectory();
    final path = tDirectory.path;
    ImD.Image mImageFile = ImD.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')..writeAsBytesSync(ImD.encodeJpg(mImageFile, quality: 60));
    setState(() {
      file = compressedImageFile;
    });
  }


  controlUploadAndSave() async {
    setState(() {
      uploading = true;
    });

    await compressingPhoto();
    String downloadUrl = await uploadPhoto(file);

    savePostInfoToFireStore(url: downloadUrl, location: locationTextEditingController.text, description: descriptionTextEditingController.text);

    locationTextEditingController.clear();
    descriptionTextEditingController.clear();

    setState(() {
      file = null;
      uploading = false;
      postId = Uuid().v4();
    });

  }

  savePostInfoToFireStore({String url, String location, String description})
  {
    postReference.document(widget.gCurrentUser.id).collection("usersPosts").document(postId).setData({
      "postId": postId,
      "ownerId": widget.gCurrentUser.id,
      "timestamp": DateTime.now(),
      "likes": {},
      "username": widget.gCurrentUser.username,
      "description": description,
      "location": location,
      "url": url,
    });
  }

  Future<String> uploadPhoto(mImageFile) async {
    StorageUploadTask mStorageUploadTask = storageReference.child("post_$postId.jpg").putFile(mImageFile);
    StorageTaskSnapshot storageTaskSnapshot = await mStorageUploadTask.onComplete;
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  displayUploadFormScreen(){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.yellowAccent,), onPressed: clearPostInfo),
        title: Text("Nueva idea", style: TextStyle(fontSize: 24.0, color: Hexcolor("#fbcb4c"), fontWeight: FontWeight.bold),),
        actions: <Widget>[
          FlatButton(
              onPressed: uploading ? null: ()=> controlUploadAndSave(),
              child: Text("Compartir",style: TextStyle(color: Colors.yellowAccent, fontWeight: FontWeight.bold, fontSize: 16.0),),
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          uploading ? linearProgress() : Text(""),
          Container(
            height: 300.0,
            width: MediaQuery.of(context).size.width*0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16/19,
                child: Container(
                  decoration: BoxDecoration(image: DecorationImage(image: FileImage(file), fit: BoxFit.cover)),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 12.0),
          ),
          ListTile(
            leading: CircleAvatar(backgroundImage: CachedNetworkImageProvider(widget.gCurrentUser.url),),
            title: Container(
              width: 250.0,
              child: TextField(
                style: TextStyle(color: Colors.black),
                controller: descriptionTextEditingController,
                decoration: InputDecoration(
                  hintText: "Describe brevemente tu idea...",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.location_searching, color: Colors.black, size: 36.0,),
            title: Container(
              width: 250.0,
              child: TextField(
                style: TextStyle(color: Colors.black),
                controller: locationTextEditingController,
                decoration: InputDecoration(
                  hintText: "En que lugar nacio tu idea...",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            width: 220.0,
            height: 110.0,
            alignment: Alignment.center,
            child: RaisedButton.icon(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35.0)),
                color: Hexcolor("#fbcb4c"),
                icon: Icon(Icons.my_location, color: Colors.black,),
                label: Text("Obtener mi ubicación actual", style: TextStyle(color: Colors.black),),
              onPressed: getCurrentLocation,
            ),
          ),
        ],
      ),
    );
  }

  bool get wantKeepAlive => true;


  @override
  Widget build(BuildContext context) {
    return file == null ? displayUploadScreen() : displayUploadFormScreen() ;
  }
}
