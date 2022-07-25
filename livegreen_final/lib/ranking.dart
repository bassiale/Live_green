import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:livegreen_final/home.dart';
import 'package:livegreen_final/models/task.dart';
import 'package:livegreen_final/models/user.dart';
import 'package:livegreen_final/screens/login_screen.dart';
import 'package:livegreen_final/screens/profile_screen.dart';
import 'package:livegreen_final/topBar.dart';

class Ranking extends StatefulWidget {
  Ranking({Key? key}) : super(key: key);

  @override
  State<Ranking> createState() => _RankingState();
}

class _RankingState extends State<Ranking> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  var users = [];
  var tasks = [];
  @override
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
    FirebaseFirestore.instance
        .collection('users')
        .orderBy('score', descending: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        users.add(UserModel.fromJson(element.data()));
      }
    });
    FirebaseFirestore.instance.collection('tasks').get().then((value) {
      for (var element in value.docs) {
        tasks.add(TaskModel.fromJson(element.data()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
        backgroundColor: Colors.green,
        body: DefaultTabController(
          length: 2,
          child: Column(children: [
            const TabBar(tabs: [
              Tab(
                text: "Tasks",
              ),
              Tab(
                text: "Ranking",
              )
            ]),
            Expanded(
              child: TabBarView(
                children: [
                  SizedBox(
                    height: 100,
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      color: Colors.white,
                      child: Center(
                          child: ListView.builder(
                        padding: EdgeInsets.all(15),
                        itemCount: tasks.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: EdgeInsets.all(5),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(200),
                                            child: Image.network(
                                              tasks[index].icon,
                                              fit: BoxFit.contain,
                                              height: 50,
                                            )),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Flexible(
                                          child: Text(
                                            tasks[index].title,
                                            overflow: TextOverflow.visible,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  OutlinedButton(
                                      onPressed: () {
                                        FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(loggedInUser.uid)
                                            .update({
                                          'score': loggedInUser.score! +
                                              tasks[index]!.points
                                        });
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        HomePage(index: 4)));
                                      },
                                      child: Text('+ ' +
                                          tasks[index].points.toString())),
                                ]),
                          );
                        },
                      )),
                    ),
                  ),
                  Container(
                      color: Colors.white,
                      child: SizedBox(
                        height: 100,
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                            child: ListView.builder(
                          padding: const EdgeInsets.all(15),
                          itemCount: users.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: EdgeInsets.all(5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(200),
                                          child: Image.network(
                                            users[index].profilePic,
                                            fit: BoxFit.contain,
                                            height: 50,
                                          )),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(users[index].username != null
                                                ? users[index].username
                                                : "username"),
                                            Text(users[index].bio != null
                                                ? users[index].bio
                                                : "hey there I'm using LiveGreen")
                                          ])
                                    ],
                                  ),
                                  Text(users[index].score != null
                                      ? users[index].score.toString()
                                      : "score"),
                                ],
                              ),
                            );
                          },
                        )),
                      ))
                ],
              ),
            )
          ]),
        ),
      ),
    );
  }
}

Future<void> logout(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  Navigator.of(context)
      .pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
}
