import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:livegreen_final/publish_event.dart';
import 'package:livegreen_final/publish_post.dart';
import 'package:livegreen_final/screens/login_screen.dart';
import 'package:livegreen_final/screens/profile_screen.dart';
import 'package:livegreen_final/topBar.dart';

class TypeSelector extends StatefulWidget {
  TypeSelector({Key? key}) : super(key: key);

  @override
  State<TypeSelector> createState() => _TypeSelectorState();
}

class _TypeSelectorState extends State<TypeSelector> {
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
                    child: loggedInUser.profilePic != null
                        ? Image.network(
                            loggedInUser.profilePic!,
                            fit: BoxFit.contain,
                            height: 50,
                          )
                        : Container()),
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
              text: "Event",
            ),
            Tab(
              text: "Post",
            )
          ]),
          Expanded(
              child: Container(
            color: Colors.white,
            child: TabBarView(children: [
              Padding(padding: EdgeInsets.all(15), child: PublishEventPage()),
              Padding(padding: EdgeInsets.all(15), child: PublishPostPage()),
            ]),
          ))
        ]),
      ),
    );
  }
}

Future<void> logout(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  Navigator.of(context)
      .pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
}


/* Scaffold(
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
              child: CircleAvatar(
                backgroundColor: Colors.green,
                backgroundImage: NetworkImage(loggedInUser.profilePic != null
                    ? loggedInUser.profilePic.toString()
                    : "https://firebasestorage.googleapis.com/v0/b/livegreen-66455.appspot.com/o/index.png?alt=media&token=94763165-7215-4a54-a313-367bc43d8547"),
                radius: 25,
              ),
            ),
          ),
        ),
      ],
    )
    ,
        body: Center(
          child: Column(
            children: [
              Expanded(
                  child: ButtonTheme(
                      child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => PublishPostPage()));
                },
                child: const Text(
                  "New Post",
                  style: TextStyle(fontSize: 50),
                ),
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50)),
              ))),
              Expanded(
                  child: ButtonTheme(
                      child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => PublishEventPage()));
                },
                child: const Text("New Event", style: TextStyle(fontSize: 50)),
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50)),
              )))
            ],
          ),
        )); */