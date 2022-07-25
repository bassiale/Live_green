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
import 'package:intl/intl.dart';

class PublishEventPage extends StatefulWidget {
  const PublishEventPage({Key? key}) : super(key: key);

  @override
  State<PublishEventPage> createState() => _PublishEventPageState();
}

class _PublishEventPageState extends State<PublishEventPage> {
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
      dateInput.text = "";
      setState(() {});
    });
  }

  final picker = ImagePicker();
  final storageRef = FirebaseStorage.instance;
  final TextEditingController descriptionEditingController =
      TextEditingController();
  final TextEditingController dateInput = TextEditingController();
  final TextEditingController titleController = TextEditingController();

  File? imageFile;
  String? image;
  DateTime? eventDate;
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

  Future<void> PublishEvent(
      String? username,
      String? description,
      String? profileImage,
      String? uid,
      String? image,
      int? likes,
      int? comments,
      DateTime? dateTime,
      bool? isEvent,
      DateTime? eventDate,
      String? title) {
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
      'eventDate': eventDate,
      'title': title,
    }).then((value) {
      Fluttertoast.showToast(msg: "Event published");
      FirebaseFirestore.instance
          .collection("posts")
          .doc(value.id)
          .update({"pid": value.id});
    }).catchError((error) =>
            Fluttertoast.showToast(msg: "Event couldn't be published"));
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
        TextField(
          controller: titleController,
          maxLength: 100,
          decoration: InputDecoration(
            hintText: 'Event title',
            contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        postText,
        TextField(
          controller: dateInput,
          //editing controller of this TextField
          decoration: InputDecoration(
              icon: Icon(Icons.calendar_today), //icon of text field
              labelText: "Enter Date" //label text of field
              ),
          readOnly: true,
          //set it true, so that user will not able to edit text
          onTap: () async {
            eventDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                //DateTime.now() - not to allow to choose before today.
                lastDate: DateTime(2100));

            if (eventDate != null) {
              print(
                  eventDate); //eventDate output format => 2021-03-10 00:00:00.000
              String formattedDate =
                  DateFormat('yyyy-MM-dd').format(eventDate!);
              print(
                  formattedDate); //formatted date output using intl package =>  2021-03-16
              setState(() {
                dateInput.text =
                    formattedDate; //set output date to TextField value.
              });
            } else {}
          },
        ),
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
              },
              child: const Text("Remove Image")),
        OutlinedButton(
            onPressed: () async {
              await uploadImage();
              PublishEvent(
                  loggedInUser.username,
                  descriptionEditingController.text,
                  loggedInUser.profilePic,
                  loggedInUser.uid,
                  image,
                  0,
                  0,
                  DateTime.now(),
                  true,
                  eventDate,
                  titleController.text);
            },
            child: const Text("publish"))
      ])),
    );
  }
}
