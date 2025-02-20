import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:quizarea/core/LocaleManager.dart';
import 'package:quizarea/services/add_friend.dart';
import 'package:quizarea/services/friend_list.dart';
import 'package:quizarea/services/friend_request.dart';

class ProfileScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>?> _getUserInfo() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (doc.exists) {
      return doc.data();
    }
    return null;
  }

  Future<int?> _getUserScore() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (doc.exists && doc.data() != null) {
      return doc.data()?['score'];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = _auth.currentUser;
    final localManager = Provider.of<LocalManager>(context, listen: false); // 🔹 listen: false ekledik

    return Scaffold(
      backgroundColor: Colors.blue.shade500,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.orange,
                  child: Icon(Icons.person, size: 30, color: Colors.white),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: FutureBuilder<Map<String, dynamic>?>(
                    future: _getUserInfo(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(color: Colors.white);
                      }
                      if (snapshot.hasError || snapshot.data == null) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${localManager.translate("welcome")}", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            Text("${currentUser?.displayName}", style: TextStyle(color: Colors.white, fontSize: 16)),
                          ],
                        );
                      }

                      final userInfo = snapshot.data!;
                      final fullName = "${userInfo['fullName']}";

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${localManager.translate("welcome")}", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(fullName, style: TextStyle(color: Colors.white, fontSize: 16)),
                        ],
                      );
                    },
                  ),
                ),
                FutureBuilder<int?>(
                  future: _getUserScore(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(color: Colors.white);
                    }
                    if (snapshot.hasError || snapshot.data == null) {
                      return Text("${localManager.translate("profile_score")}: 0", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold));
                    }

                    final score = snapshot.data ?? 0;
                    return Text("${localManager.translate("profile_score")}: $score", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold));
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 32,),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade500,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30), topRight: Radius.circular(30),
                ),
              ),
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildMenuItem(context, localManager.translate("profile_add_friend"), Icons.person_add, AddFriendScreen()),
                        _buildMenuItem(context, localManager.translate("profile_see_friend_requests"), Icons.list, FriendRequestsScreen()),
                        _buildMenuItem(context, localManager.translate("profile_see_friends"), Icons.people, FriendListScreen()),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon, Widget screen) {
    return ListTile(
      title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
      trailing: Icon(icon, size: 18, color: Colors.blue.shade400),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
      },
    );
  }
}
