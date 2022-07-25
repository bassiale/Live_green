import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:livegreen_final/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livegreen_final/screens/login_screen.dart';
import 'package:livegreen_final/screens/profile_screen.dart';

User? user = FirebaseAuth.instance.currentUser;
UserModel loggedInUser = UserModel();
void initState() async {
  await FirebaseFirestore.instance
      .collection("users")
      .doc(user!.uid)
      .get()
      .then((value) {
    loggedInUser = UserModel.fromJson(value.data());
  });
}

class MyCustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.green,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  child: const Text("Logout"),
                  onTap: () {
                    logout(context);
                  },
                ),
                const Text(
                  "LiveGreen",
                  style: TextStyle(
                    fontSize: 22,
                  ),
                ),
                Material(
                    child: GestureDetector(
                  onTap: () {
                    if (loggedInUser.uid != null) {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => ProfilePage(
                                    uid: loggedInUser.uid!,
                                    currentUid: loggedInUser.uid!,
                                  )),
                          (route) => false);
                    }
                  },
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.network(
                        loggedInUser.profilePic != null
                            ? loggedInUser.profilePic.toString()
                            : "https://firebasestorage.googleapis.com/v0/b/livegreen-66455.appspot.com/o/index.png?alt=media&token=94763165-7215-4a54-a313-367bc43d8547",
                        height: 100,
                      )),
                )),
              ],
            ),
          ),
        ));
  }

  @override
  Size get preferredSize => Size.fromHeight(60);
}

Future<void> logout(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  Navigator.of(context)
      .pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
}
