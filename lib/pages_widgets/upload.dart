import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_learno/errors/login_errors.dart';
import 'package:flutter_app_learno/models/user.dart';
import 'package:flutter_app_learno/screens/home.dart';
import 'package:flutter_app_learno/widgets/progress.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as Im;

class Upload extends StatefulWidget {
  final User currentUser;

  Upload({this.currentUser});

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  File file;
  bool isUploading = false;
  String postId = Uuid().v4();
  TextEditingController captionController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isUploading ? "Waiting" : "Upload",
          style: TextStyle(color: Color(0xff615DFA)),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Color(0xff615DFA), //change your color here
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              FeatherIcons.upload,
              color: Colors.black,
            ),
            onPressed: () {
              selectImage(context);
            },
          ),
          SizedBox(
            width: 10,
          ),
          IconButton(
            icon: Icon(
              FeatherIcons.check,
              color: Colors.green,
            ),
            onPressed: isUploading ? null : () => file == null ? null : handleSubmit(),
          )
        ],
      ),
      body: file == null
          ? Center(
              child: Text('Upload Image!'),
            )
          : buildUploadForm(),
    );
  }

  clearImage() {
    setState(() {
      file = null;
    });
  }

  buildUploadForm() {
    return ListView(
      children: <Widget>[
        isUploading ? linearProgress() : Container(),
        Padding(
          padding: EdgeInsets.only(top: 20.0),
        ),
        Container(
          height: 220.0,
          width: MediaQuery.of(context).size.width * 0.8,
          child: Center(
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: FileImage(file),
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 20.0),
        ),
        ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(currentUser.photoUrl),
          ),
          title: Container(
            width: 250.0,
            child: TextField(
              controller: captionController,
              decoration: InputDecoration(
                hintText: "Write a caption...",
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        Divider(),
        ListTile(
          leading: Icon(
            Icons.pin_drop,
            color: Colors.orange,
            size: 35.0,
          ),
          title: Container(
            width: 250.0,
            child: TextField(
              controller: locationController,
              decoration: InputDecoration(
                hintText: "Where was this photo taken?",
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        Container(
          width: 200.0,
          height: 100.0,
          alignment: Alignment.center,
          child: RaisedButton.icon(
            label: Text(
              "Use Current Location",
              style: TextStyle(color: Colors.white),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            color: Colors.blue,
            onPressed: getUserLocation,
            icon: Icon(
              Icons.my_location,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Future<String> uploadImage(imageFile) async {
    StorageUploadTask uploadTask =
    storageRef.child('post_$postId.jpg').putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  checkFilesOk(){
    if(file == null || captionController.text == null || locationController.text == null){
      CommonError(
        title: "Upload Error",
        description: "Some fields are empty!",
      );
    }else{
      handleSubmit();
    }
  }

  handleSubmit() async {
    setState(() {
      isUploading = true;
    });
    await compressImage();
    String mediaUrl = await uploadImage(file);
    createPostInFirestore(
        mediaUrl: mediaUrl,
        location: locationController.text,
        description: captionController.text);
    captionController.clear();
    locationController.clear();
    setState(() {
      file = null;
      isUploading = false;
    });
    Navigator.of(context).pop();
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    setState(() {
      file = compressedImageFile;
    });
  }

  createPostInFirestore(
      {String mediaUrl, String location, String description}) {
    postsRef
        .document(widget.currentUser.id)
        .collection('userPosts')
        .document(postId)
        .setData({
      'postId': postId,
      'ownerId': widget.currentUser.id,
      'username': '${widget.currentUser.firstName} ${widget.currentUser.lastName}',
      'mediaUrl': mediaUrl,
      'description': description,
      'location': location,
      'timestamp': DateTime.now(),
      'likes': {}
    });
  }

  selectImage(parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: Row(
            children: <Widget>[
              Icon(FeatherIcons.upload),
              SizedBox(
                width: 10,
              ),
              Text("Create Post")
            ],
          ),
          children: <Widget>[
            SimpleDialogOption(
                child: Row(
                  children: <Widget>[
                    Icon(FeatherIcons.camera),
                    SizedBox(
                      width: 10,
                    ),
                    Text("Photo with Camera")
                  ],
                ),
                onPressed: handleTakePhoto),
            SimpleDialogOption(
                child: Row(
                  children: <Widget>[
                    Icon(FeatherIcons.image),
                    SizedBox(
                      width: 10,
                    ),
                    Text("Image from Gallery")
                  ],
                ),
                onPressed: handleChooseFromGallery),
          ],
        );
      },
    );
  }

  handleTakePhoto() async {
    clearImage();
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      this.file = file;
    });
  }

  handleChooseFromGallery() async {
    clearImage();
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      this.file = file;
    });
  }

  getUserLocation() async {
    setState(() {
      isUploading = true;
    });
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    String completeAddress =
        '${placemark.subThoroughfare} ${placemark.thoroughfare}, ${placemark.subLocality} ${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea} ${placemark.postalCode}, ${placemark.country}';
    print(completeAddress);
    String formattedAddress = '${placemark.locality}, ${placemark.country}';
    print(formattedAddress);
    locationController.text = formattedAddress;
    setState(() {
      isUploading = false;
    });
  }
}
