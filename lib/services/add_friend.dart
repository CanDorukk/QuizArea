import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:quizarea/core/LocaleManager.dart';

class AddFriendScreen extends StatefulWidget {
  @override
  _AddFriendScreenState createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    final usersCollection = FirebaseFirestore.instance.collection('users');
    final results = await usersCollection
        .where('fullName', isGreaterThanOrEqualTo: query)
        .where('fullName', isLessThan: query + 'z')
        .get();

    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final filteredResults = results.docs
        .where((doc) {
      final userId = doc.id;
      return userId != currentUserId; // Prevent sending friend request to self
    })
        .map((doc) => {
      'uid': doc.id,
      'fullName': doc['fullName'],
    })
        .toList();

    setState(() {
      _searchResults = filteredResults;
    });
  }

  Future<void> sendFriendRequest(String senderId, String receiverId) async {
    final localManager = Provider.of<LocalManager>(context, listen: false);
    if (senderId == receiverId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You cannot send a friend request to yourself.")),
      );
      return; // Prevent sending a request to oneself
    }

    try {
      final requestRef = FirebaseFirestore.instance.collection('friend_requests').doc('$senderId-$receiverId');
      final doc = await requestRef.get();

      if (doc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localManager.translate("alread_set_friend_req_message"))),
        );
        return;
      }

      await requestRef.set({
        'senderId': senderId,
        'receiverId': receiverId,
        'status': 'pending', // Initial status is 'pending'
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Friend request sent!")),
      );
    } catch (e) {
      print("${localManager.translate("friend_request_error_message")}: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localManager.translate("error_occoured_message"),)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localManager = Provider.of<LocalManager>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(localManager.translate("profile_add_friend")),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Field
            TextField(
              controller: _searchController,
              onChanged: searchUsers,
              decoration: InputDecoration(
                labelText: localManager.translate("profile_search_friend"),
                suffixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              ),
            ),
            SizedBox(height: 16),

            // Search Results
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final user = _searchResults[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      title: Text(
                        user['fullName'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.person_add),
                        onPressed: () async {
                          final currentUserId = FirebaseAuth.instance.currentUser!.uid;
                          await sendFriendRequest(currentUserId, user['uid']);
                        },
                        iconSize: 30,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
