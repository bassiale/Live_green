import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:livegreen_final/home.dart';
import 'package:livegreen_final/models/user.dart';
import 'package:path/path.dart' as path;

class PublishPostPage extends StatefulWidget {
  const PublishPostPage({Key? key}) : super(key: key);

  @override
  State<PublishPostPage> createState() => _PublishPostPageState();
}

class _PublishPostPageState extends State<PublishPostPage> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromJson(value.data());
      setState(() {});
    });
  }

  final picker = ImagePicker();
  final storageRef = FirebaseStorage.instance;
  final TextEditingController descriptionEditingController =
      TextEditingController();

  File? imageFile;
  String? image;
  CollectionReference posts = FirebaseFirestore.instance.collection('posts');
  void pickFile() async {
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
      image = pickedFile.path;
    }
    /* if (pickedFile != null) {
          final postImage = File(pickedFile);
        } else {
          if (kDebugMode) {
            print('No image selected');
          } */
    setState(() {});
  }

  Future<void> uploadImage() async {
    if (imageFile == null) {
      return;
    } else {
      await storageRef.ref(path.basename(imageFile!.path)).putFile(imageFile!);
      image =
          await storageRef.ref(path.basename(imageFile!.path)).getDownloadURL();
    }
  }

  Future<void> PublishPost(
      String? username,
      String? description,
      String? profileImage,
      String? uid,
      String? image,
      int? likes,
      int? comments,
      DateTime? dateTime,
      bool? isEvent) {
    // Calling the collection to add a new user
    return posts
        //adding to firebase collection
        .add({
      'username': username,
      'description': description,
      'comments': comments,
      'likes': likes,
      'uid': uid,
      'image': image,
      'profileImage': profileImage,
      'dateTime': dateTime,
      'isEvent': isEvent,
    }).then((value) {
      Fluttertoast.showToast(msg: "Post published");
      FirebaseFirestore.instance
          .collection("posts")
          .doc(value.id)
          .update({"pid": value.id});
    }).catchError((error) =>
            Fluttertoast.showToast(msg: "Post couldn't be published"));
  }

  @override
  Widget build(BuildContext context) {
    FocusNode node = FocusNode();
    final postText = TextField(
        autofocus: false,
        controller: descriptionEditingController,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        maxLength: 500,
        focusNode: node,
        decoration: InputDecoration(
          suffix: ElevatedButton(
            onPressed: () {
              node.unfocus();
              /* PublishPost(
                  loggedInUser.username,
                  descriptionEditingController.text,
                  loggedInUser.profilePic,
                  loggedInUser.uid,
                  image!.path,
                  0,
                  0,
                  DateTime.now(),
                  false); */
            },
            child: const Text("finish editing"),
          ),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "write a description...",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    return Container(
      child: SingleChildScrollView(
          child: Column(children: [
        postText,
        OutlinedButton(
          onPressed: () {
            pickFile();
          },
          child: const Text('add an image'),
        ),
        if (image != null)
          Image.file(
            imageFile!,
            width: 300,
            height: 300,
          ),
        if (image != null)
          OutlinedButton(
              onPressed: () {
                image = null;
                imageFile = null;
                setState(() {});
                print(FirebaseFirestore.instance.collection("posts").doc().id);
              },
              child: const Text("Remove Image")),
        OutlinedButton(
            onPressed: () async {
              await uploadImage();
              PublishPost(
                  loggedInUser.username,
                  descriptionEditingController.text,
                  loggedInUser.profilePic,
                  loggedInUser.uid,
                  image,
                  0,
                  0,
                  DateTime.now(),
                  false);
            },
            child: const Text("publish"))
      ])),
    );
  }
}
