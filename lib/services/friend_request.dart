import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:quizarea/core/LocaleManager.dart';

class FriendRequestsScreen extends StatefulWidget {
  @override
  _FriendRequestsScreenState createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getUserName(String userId) async {
    final localManager = Provider.of<LocalManager>(context, listen: false);

    final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (doc.exists) {
      return doc.data()?['fullName'] ?? localManager.translate("unknown");
    }
    return localManager.translate("unknown");
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _auth.currentUser!.uid;
    final localManager = Provider.of<LocalManager>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(localManager.translate("friend_requests")),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('friend_requests')
            .where('receiverId', isEqualTo: currentUserId)
            .where('status', isEqualTo: 'pending') // Bekleyen istekler
            .snapshots(), // Stream ile veriyi al
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text(localManager.translate("have_no_friend_requests")));
          }

          final friendRequests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: friendRequests.length,
            itemBuilder: (context, index) {
              final request = friendRequests[index];
              final senderId = request['senderId'];

              return FutureBuilder<String>(
                future: getUserName(senderId), // Gönderenin ismini almak
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: Text(localManager.translate("loading")),
                    );
                  }

                  if (userSnapshot.hasError || !userSnapshot.hasData) {
                    return ListTile(
                      title: Text(localManager.translate("error_occurred")),
                    );
                  }

                  final senderName = userSnapshot.data!; // Gönderenin adı

                  return ListTile(
                    title: Text("${localManager.translate("friend_request_from")} '$senderName'"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.check),
                          onPressed: () async {
                            await acceptFriendRequest(senderId, currentUserId);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () async {
                            await rejectFriendRequest(senderId, currentUserId);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> acceptFriendRequest(String senderId, String receiverId) async {
    try {
      final userRef = FirebaseFirestore.instance.collection('users').doc(receiverId);
      final friendRef = FirebaseFirestore.instance.collection('users').doc(senderId);
      final localManager = Provider.of<LocalManager>(context, listen: false);

      // Her iki kullanıcıyı da arkadaş listesine ekle
      await userRef.update({
        'friends': FieldValue.arrayUnion([senderId]),
      });

      await friendRef.update({
        'friends': FieldValue.arrayUnion([receiverId]),
      });

      // Arkadaşlık isteğini kabul et
      final requestRef = FirebaseFirestore.instance.collection('friend_requests').doc('$senderId-$receiverId');
      await requestRef.delete(); // İstek kabul edildikten sonra isteği sil

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localManager.translate("friend_request_accepted"))),
      );
    } catch (e) {
      final localManager = Provider.of<LocalManager>(context, listen: false);
      print("Arkadaşlık isteği kabul edilirken hata oluştu: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localManager.translate("error_occured_message"))),
      );
    }
  }

  Future<void> rejectFriendRequest(String senderId, String receiverId) async {
    final localManager = Provider.of<LocalManager>(context, listen: false);

    try {
      final requestRef = FirebaseFirestore.instance.collection('friend_requests').doc('$senderId-$receiverId');

      // İsteği reddet
      await requestRef.delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localManager.translate("friend_req_rejected_message"))),
      );
    } catch (e) {
      print("Arkadaşlık isteği reddedilirken hata oluştu: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localManager.translate("error_occured_message"))),
      );
    }
  }
}
