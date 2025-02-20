import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddFriendScreen extends StatefulWidget {
  @override
  _AddFriendScreenState createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];

  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Kullanıcıları aramak
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

    setState(() {
      _searchResults = results.docs
          .map((doc) => {
        'uid': doc.id,
        'fullName': doc['fullName'],
      })
          .toList();
    });
  }

  // Arkadaş ekleme
  Future<void> addFriend(String friendUserId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        print("Giriş yapılmamış");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lütfen giriş yapın!")),
        );
        return;
      }

      print("Arkadaş ekleniyor: $currentUserId -> $friendUserId");

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

      print("Arkadaş başarıyla eklendi");

      // Başarı mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Arkadaş eklendi!")),
      );
    } catch (e) {
      print("Arkadaş eklerken hata oluştu: $e");

      // Hata mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bir hata oluştu, lütfen tekrar deneyin.")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Arkadaş Ekle"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: searchUsers,
              decoration: InputDecoration(
                labelText: 'Arkadaş Ara',
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
                      onPressed: () => addFriend(user['uid']), // Arkadaş ekleme
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
