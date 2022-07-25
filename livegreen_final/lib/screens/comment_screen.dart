import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:livegreen_final/home.dart';
import 'package:livegreen_final/models/comment.dart';
import 'package:livegreen_final/models/user.dart';

class CommentScreen extends StatefulWidget {
  final String pid;
  final int comNumb;
  const CommentScreen({Key? key, required this.pid, required this.comNumb})
      : super(key: key);

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  List<CommentModel> comments = [];
  FocusNode node = FocusNode();
  int number = 0;
  final TextEditingController commentInput = TextEditingController();

  void getComments() {
    FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.pid)
        .collection("comments")
        .orderBy('dateTime', descending: false)
        .get()
        .then((event) async {
      comments = [];
      for (var element in event.docs) {
        comments.add(CommentModel.fromJson(element.data()));
      }
      setState(() {});
    });
    setState(() {});
    print(comments.length);
  }

  Future<void> postComment(String? uid, String? username, String? commentText,
      String? image, DateTime? dateTime) {
    return FirebaseFirestore.instance
        .collection("posts")
        .doc(widget.pid)
        .collection("comments")
        .add({
      "uid": uid,
      "username": username,
      "commentText": commentText,
      "image": image,
      "dateTime": dateTime,
    }).then((value) {
      number += 1;
      FirebaseFirestore.instance
          .collection("posts")
          .doc(widget.pid)
          .collection("comments")
          .doc(value.id)
          .update({"pid": value.id});
      FirebaseFirestore.instance
          .collection("posts")
          .doc(widget.pid)
          .update({"comments": number});

      getComments();
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    number = widget.comNumb;
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromJson(value.data());
      getComments();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Comments"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () =>
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => HomePage(
                          index: 0,
                        ))),
          ),
        ),
        body: Column(children: [
          Expanded(
              child: Align(
                  alignment: Alignment.center,
                  child: ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.green, width: 2)),
                          child: Column(
                            children: [
                              Container(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 10,
                                  ),
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(200),
                                      child: Image.network(
                                        comments[index].image!,
                                        fit: BoxFit.contain,
                                        width: 35,
                                      )),
                                  Container(
                                    width: 20,
                                  ),
                                  Text(comments[index].username!)
                                ],
                              ),
                              Container(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 10,
                                  ),
                                  Flexible(
                                      child: Text(
                                    comments[index].commentText!,
                                    overflow: TextOverflow.visible,
                                    style: TextStyle(fontSize: 20),
                                  ))
                                ],
                              ),
                            ],
                          ));
                    },
                  ))),
          TextField(
            controller: commentInput,
            focusNode: node,
            decoration: InputDecoration(
                suffix: IconButton(
                    onPressed: () async {
                      if (commentInput.text != "") {
                        await postComment(
                            loggedInUser.uid,
                            loggedInUser.username,
                            commentInput.text,
                            loggedInUser.profilePic,
                            DateTime.now());
                        commentInput.text = "";
                        setState(() {});
                      }
                      node.unfocus();
                    },
                    icon: FaIcon(FontAwesomeIcons.share)),
                contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                hintText: "write a comment...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                )),
          )
        ]));
  }
}
