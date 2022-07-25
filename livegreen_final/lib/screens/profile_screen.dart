import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:livegreen_final/home.dart';
import 'package:livegreen_final/models/like.dart';
import 'package:livegreen_final/models/post.dart';
import 'package:livegreen_final/models/user.dart';
import 'package:livegreen_final/screens/comment_screen.dart';
import 'package:livegreen_final/screens/login_screen.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  final String currentUid;
  ProfilePage({
    Key? key,
    required this.uid,
    required this.currentUid,
  }) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserModel pUser = UserModel();
  UserModel loggedInUser = UserModel();
  bool ready = false;
  List<PostModel> posts = [];
  List<String> liked = [];
  List<String> likesId = [];

  void follow() {
    pUser.followers!.add(widget.currentUid);
    FirebaseFirestore.instance
        .collection("users")
        .doc(widget.uid)
        .update({"followers": pUser.followers});
    loggedInUser.following!.add(pUser.uid);
    FirebaseFirestore.instance
        .collection("users")
        .doc(widget.currentUid)
        .update({"following": loggedInUser.following}).then(
      (value) => setState(() {}),
    );
  }

  void unfollow() {
    pUser.followers!.remove(widget.currentUid);
    FirebaseFirestore.instance
        .collection("users")
        .doc(widget.uid)
        .update({"followers": pUser.followers});
    loggedInUser.following!.remove(pUser.uid);
    FirebaseFirestore.instance
        .collection("users")
        .doc(widget.currentUid)
        .update({"following": loggedInUser.following}).then(
      (value) => setState(() {}),
    );
  }

  void getPosts() {
    FirebaseFirestore.instance
        .collection('posts')
        .orderBy('dateTime', descending: true)
        .get()
        .then((event) async {
      posts = [];
      for (var element in event.docs) {
        if (PostModel.fromJson(element.data()).uid == widget.uid) {
          posts.add(PostModel.fromJson(element.data()));
          FirebaseFirestore.instance
              .collection('posts')
              .doc(element.id)
              .collection("likes")
              .get()
              .then((evento) async {
            for (var element2 in evento.docs) {
              LikesModel temp = LikesModel.fromJson(element2.data());
              print(temp.uid);
              print(loggedInUser.uid);
              if (temp.uid == loggedInUser.uid) {
                liked.add(element.id);
                likesId.add(temp.lid!);
              }
            }
            setState(() {});
          });
        }
        setState(() {});
      }
    });
  }

  Future<void> addLike(
    PostModel post,
    String? image,
    String? username,
    String? uid,
  ) {
    // Calling the collection to add a new user
    liked.add(post.pid!);
    return FirebaseFirestore.instance
        .collection("posts")
        .doc(post.pid)
        .collection("likes")
        .add({
      'username': username,
      'uid': uid,
      'image': image,
    }).then((value) {
      FirebaseFirestore.instance
          .collection("posts")
          .doc(post.pid)
          .collection("likes")
          .doc(value.id)
          .update({"lid": value.id});
      post.likes = post.likes! + 1;
      FirebaseFirestore.instance
          .collection("posts")
          .doc(post.pid)
          .update({"likes": post.likes});
      likesId.add(value.id);
      setState(() {});
    });
  }

  Future<void> removeLike(
    PostModel post,
  ) {
    // Calling the collection to add a new user
    liked.remove(post.pid!);
    return FirebaseFirestore.instance
        .collection("posts")
        .doc(post.pid)
        .collection("likes")
        .get()
        .then((value) {
      for (var element in value.docs) {
        LikesModel temp = LikesModel.fromJson(element.data());
        if (likesId.contains(temp.lid)) {
          FirebaseFirestore.instance
              .collection("posts")
              .doc(post.pid)
              .collection("likes")
              .doc(temp.lid)
              .delete();
          post.likes = post.likes! - 1;
          FirebaseFirestore.instance
              .collection("posts")
              .doc(post.pid)
              .update({"likes": post.likes});
          likesId.remove(temp.lid);
        }
        setState(() {});
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getPosts();
    FirebaseFirestore.instance
        .collection("users")
        .doc(widget.uid)
        .get()
        .then((value) {
      pUser = UserModel.fromJson(value.data());
      ready = true;

      setState(() {});
    });
    FirebaseFirestore.instance
        .collection("users")
        .doc(widget.currentUid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromJson(value.data());
      setState(() {});
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Your profile"),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () =>
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => HomePage(
                          index: 0,
                        ))),
          ),
          actions: [
            Padding(
                padding: EdgeInsets.all(10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                      child: const Text("Logout"),
                      onTap: () {
                        logout(context);
                      }),
                ))
          ],
        ),
        body: ready == true
            ? Padding(
                padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                child: SingleChildScrollView(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        decoration:
                            BoxDecoration(), //border: Border.all(color: Colors.green, width: 3)),
                        child: Row(children: [
                          ClipRRect(
                              borderRadius: BorderRadius.circular(200),
                              child: Image.network(
                                pUser.profilePic != null
                                    ? pUser.profilePic.toString()
                                    : "https://firebasestorage.googleapis.com/v0/b/livegreen-66455.appspot.com/o/index.png?alt=media&token=94763165-7215-4a54-a313-367bc43d8547",
                                fit: BoxFit.contain,
                                height: 50,
                              )),
                          Column(children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    pUser.username!,
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  Text(
                                    pUser.bio!,
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ]),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 30,
                                ),
                                OutlinedButton(
                                    onPressed: () {},
                                    child: Text(
                                        "Followers\n${pUser.followers!.length}",
                                        textAlign: TextAlign.center)),
                                Container(
                                  width: 50,
                                ),
                                OutlinedButton(
                                    onPressed: () {},
                                    child: Text(
                                        "Following\n${pUser.following!.length}",
                                        textAlign: TextAlign.center)),
                              ],
                            ),
                          ]),
                        ])),
                    Container(
                      height: 10,
                    ),
                    widget.uid != widget.currentUid
                        ? Container(
                            child: pUser.followers!.contains(widget.currentUid)
                                ? OutlinedButton(
                                    onPressed: () {
                                      unfollow();
                                    },
                                    child: const Text("Unfollow"))
                                : OutlinedButton(
                                    onPressed: () {
                                      follow();
                                    },
                                    child: const Text("Follow")))
                        : Container(width: 5),
                    ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: posts.length,
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
                                GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pushAndRemoveUntil(
                                          MaterialPageRoute(
                                              builder: (context) => ProfilePage(
                                                    uid: posts[index].uid!,
                                                    currentUid:
                                                        loggedInUser.uid!,
                                                  )),
                                          (route) => false);
                                    },
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 10,
                                        ),
                                        CircleAvatar(
                                          backgroundColor: Colors.green,
                                          backgroundImage: NetworkImage(
                                              posts[index].profileImage!),
                                          radius: 35,
                                        ),
                                        Container(
                                          width: 20,
                                        ),
                                        Text(posts[index].username!)
                                      ],
                                    )),
                                Container(
                                  height: 5,
                                ),
                                if (posts[index].title != null)
                                  Row(children: [
                                    Container(
                                      width: 10,
                                    ),
                                    Flexible(
                                        child: Text(
                                      posts[index].title!,
                                      textAlign: TextAlign.left,
                                      overflow: TextOverflow.visible,
                                      style: const TextStyle(
                                        fontSize: 30,
                                      ),
                                    )),
                                  ]),
                                Container(
                                  height: 5,
                                ),
                                if (posts[index].image != null)
                                  Image.network(
                                    posts[index].image!,
                                    width:
                                        MediaQuery.of(context).size.width - 20,
                                  ),
                                Container(
                                  height: 5,
                                ),
                                if (posts[index].description != null)
                                  Row(children: [
                                    Container(
                                      width: 10,
                                    ),
                                    Flexible(
                                        child: Text(
                                      posts[index].description!,
                                      textAlign: TextAlign.left,
                                      overflow: TextOverflow.visible,
                                      style: const TextStyle(
                                        fontSize: 20,
                                      ),
                                    )),
                                  ]),
                                Container(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: 10,
                                    ),
                                    if (posts[index].eventDate != null)
                                      Text(
                                        "Event date: " +
                                            DateFormat('dd-MM-yyyy').format(
                                                posts[index]
                                                    .eventDate!
                                                    .toDate()),
                                        style: TextStyle(fontSize: 20),
                                      )
                                  ],
                                ),
                                Row(
                                  children: [
                                    if (!liked.contains(posts[index].pid))
                                      IconButton(
                                          onPressed: () {
                                            addLike(
                                                posts[index],
                                                loggedInUser.profilePic,
                                                loggedInUser.username,
                                                loggedInUser.uid);
                                          },
                                          icon: FaIcon(
                                            FontAwesomeIcons.leaf,
                                          )),
                                    if (liked.contains(posts[index].pid))
                                      IconButton(
                                          onPressed: () {
                                            removeLike(posts[index]);
                                          },
                                          icon: FaIcon(
                                            FontAwesomeIcons.leaf,
                                          ),
                                          color: Colors.green),
                                    Text(posts[index].likes.toString()),
                                    Container(
                                      width: 5,
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pushAndRemoveUntil(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          CommentScreen(
                                                            pid: posts[index]
                                                                .pid!,
                                                            comNumb:
                                                                posts[index]
                                                                    .comments!,
                                                          )),
                                                  (route) => false);
                                        },
                                        icon: FaIcon(
                                          FontAwesomeIcons.solidComment,
                                        )),
                                    Text(posts[index].comments.toString()),
                                  ],
                                ),
                                Container(
                                  height: 15,
                                )
                              ],
                            ));
                      },
                    ),
                  ],
                )))
            : Container());
  }
}

Future<void> logout(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  Navigator.of(context)
      .pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
}
