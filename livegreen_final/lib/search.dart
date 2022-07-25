import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:livegreen_final/models/like.dart';
import 'package:livegreen_final/models/post.dart';
import 'package:livegreen_final/screens/comment_screen.dart';
import 'package:livegreen_final/topBar.dart';
import 'package:livegreen_final/screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:livegreen_final/screens/login_screen.dart';
import 'package:livegreen_final/models/user.dart';
import 'package:firebase_core/firebase_core.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController searchText = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  bool ready = false;
  bool searching = false;
  List<PostModel> posts = [];
  List<String> liked = [];
  List<String> likesId = [];
  List<UserModel> searchedUsers = [];

  void searchUsers(query) {
    FirebaseFirestore.instance
        .collection("users")
        .where("username", isEqualTo: query)
        .get()
        .then((value) {
      searchedUsers = [];
      for (var element in value.docs) {
        if (UserModel.fromJson(element.data()).username!.contains(query)) {
          searchedUsers.add(UserModel.fromJson(element.data()));
          print(UserModel.fromJson(element.data()).uid);
        }
      }
      searching = true;
      print("finito");
      setState(() {});
    });
  }

  void getPosts() {
    FirebaseFirestore.instance
        .collection('posts')
        .orderBy('dateTime', descending: true)
        .get()
        .then((event) async {
      posts = [];
      for (var element in event.docs) {
        if (true) {
          posts.add(PostModel.fromJson(element.data()));
          FirebaseFirestore.instance
              .collection('posts')
              .doc(element.id)
              .collection("likes")
              .get()
              .then((evento) async {
            for (var element2 in evento.docs) {
              LikesModel temp = LikesModel.fromJson(element2.data());
              if (temp.uid == loggedInUser.uid) {
                liked.add(element.id);
                likesId.add(temp.lid!);
              }
            }
            setState(() {});
          });
        }
        setState(() {});
        ready = true;
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
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromJson(value.data());
      getPosts();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "LiveGreen",
            style: TextStyle(
              fontSize: 22,
            ),
          ),
          leading: Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              child: const Text("Logout"),
              onTap: () {
                logout(context);
              },
            ),
          ),
          actions: [
            Material(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => ProfilePage(
                                uid: loggedInUser.uid!,
                                currentUid: loggedInUser.uid!,
                              )),
                      (route) => false);
                },
                child: Container(
                  color: Colors.green,
                  padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(200),
                      child: Image.network(
                        loggedInUser.profilePic != null
                            ? loggedInUser.profilePic.toString()
                            : "https://firebasestorage.googleapis.com/v0/b/livegreen-66455.appspot.com/o/index.png?alt=media&token=94763165-7215-4a54-a313-367bc43d8547",
                        fit: BoxFit.contain,
                        height: 50,
                      )),
                ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.fromLTRB(10, 20, 20, 0),
          child: Column(
            children: [
              SizedBox(
                height: 40,
                child: TextField(
                    controller: searchText,
                    decoration: InputDecoration(
                      suffix: IconButton(
                          onPressed: () {
                            searchUsers(searchText.text);
                            setState(() {});
                            print("eccosi");
                          },
                          icon: const Icon(Icons.search)),
                      hintText: "search a user",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    )),
              ),
              !searching
                  ? Expanded(
                      child: ListView.builder(
                        itemCount: posts.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.green, width: 2)),
                              child: Column(
                                children: [
                                  Container(
                                    height: 5,
                                  ),
                                  GestureDetector(
                                      onTap: () {
                                        Navigator.of(context)
                                            .pushAndRemoveUntil(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProfilePage(
                                                          uid:
                                                              posts[index].uid!,
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
                                          ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(200),
                                              child: Image.network(
                                                posts[index].profileImage!,
                                                fit: BoxFit.contain,
                                                height: 50,
                                              )),
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
                                      width: MediaQuery.of(context).size.width -
                                          20,
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
                                                              comNumb: posts[
                                                                      index]
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
                    )
                  : Expanded(
                      child: ListView.builder(
                      itemCount: searchedUsers.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          children: [
                            Container(
                              height: 5,
                            ),
                            GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (context) => ProfilePage(
                                                uid: searchedUsers[index].uid!,
                                                currentUid: loggedInUser.uid!,
                                              )),
                                      (route) => false);
                                },
                                child: Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.green, width: 3)),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 10,
                                        ),
                                        ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(200),
                                            child: Image.network(
                                              searchedUsers[index].profilePic!,
                                              fit: BoxFit.contain,
                                              height: 50,
                                            )),
                                        Container(
                                          width: 15,
                                        ),
                                        Text(
                                          searchedUsers[index].username!,
                                          style: TextStyle(fontSize: 40),
                                        )
                                      ],
                                    )))
                          ],
                        );
                      },
                    )),
            ],
          ),
        ));
  }
}

Future<void> logout(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  Navigator.of(context)
      .pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
}
