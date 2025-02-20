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
      return userId != currentUserId; // Kendisine arkadaşlık isteği gönderemesin
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

  // Arkadaşlık isteği gönderme fonksiyonu
  Future<void> sendFriendRequest(String senderId, String receiverId) async {
    final localManager = Provider.of<LocalManager>(context, listen: false);
    if (senderId == receiverId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Kendinize arkadaşlık isteği gönderemezsiniz.")),
      );
      return; // Kullanıcı kendisine isteği gönderemez.
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
        'status': 'pending', // Başlangıçta istek 'pending' durumda
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Arkadaşlık isteği gönderildi!")),
      );
    } catch (e) {
      print("${localManager.translate("friend_request_error_message")}: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localManager.translate("error_occoured_message"),)),
      );
    }
  }


  // Arkadaşlık isteğini reddetme fonksiyonu
  Future<void> rejectFriendRequest(String currentUserId, String friendUserId) async {
    final localManager = Provider.of<LocalManager>(context, listen: false);
    try {
      final friendRequestRef = FirebaseFirestore.instance.collection('friend_requests');
      // Belgeyi bulup status'u 'rejected' olarak güncelleriz
      await friendRequestRef.doc('$friendUserId-$currentUserId').update({
        'status': 'rejected',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localManager.translate("friend_req_rejected_message"))),
      );
    } catch (e) {
      print("${localManager.translate("friend_req_rejected_error_message")} $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bir hata oluştu, lütfen tekrar deneyin.")),
      );
    }
  }

  Future<void> addFriend(String currentUserId, String friendUserId) async {
    try {
      final userRef = FirebaseFirestore.instance.collection('users').doc(currentUserId);
      final friendRef = FirebaseFirestore.instance.collection('users').doc(friendUserId);

      // Kullanıcı A'nın arkadaş listesine B'yi ekle
      await userRef.update({
        'friends': FieldValue.arrayUnion([friendUserId]),
      });

      // Kullanıcı B'nin arkadaş listesine A'yı ekle
      await friendRef.update({
        'friends': FieldValue.arrayUnion([currentUserId]),
      });
    } catch (e) {
      print("Arkadaş eklerken hata oluştu: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final localManager = Provider.of<LocalManager>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(localManager.translate("profile_add_friend")),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: searchUsers,
              decoration: InputDecoration(
                labelText: localManager.translate("profile_search_friend"),
                suffixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final user = _searchResults[index];
                  return ListTile(
                    title: Text(user['fullName']),
                    trailing: IconButton(
                      icon: Icon(Icons.person_add),
                      onPressed: () async {
                        // Mevcut kullanıcıyı ve arkadaşı kullanarak isteği gönder
                        final currentUserId = FirebaseAuth.instance.currentUser!.uid;
                        await sendFriendRequest(currentUserId, user['uid']);
                      },
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
