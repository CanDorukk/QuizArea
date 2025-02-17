import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notetaking/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CrudScreen extends StatefulWidget {
  @override
  _CrudScreenState createState() => _CrudScreenState();
}

class _CrudScreenState extends State<CrudScreen> {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final TextEditingController _controller = TextEditingController();
  String? _userId; // Kullanıcı kimliği (misafir veya giriş yapan)

  StreamSubscription<User?>? _authSubscription;

  @override
  void initState() {
    super.initState();

    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
          if (user == null) {
            _getGuestId();
          } else {
            setState(() {
              _userId = user.uid;
            });
          }
        });

    // Uygulama ilk açıldığında kullanıcı oturum durumunu kontrol et
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _getGuestId();
    } else {
      _userId = currentUser.uid;
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _getGuestId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? guestId = prefs.getString('guest_id');

    if (guestId == null) {
      guestId = DateTime.now().millisecondsSinceEpoch.toString();
      await prefs.setString('guest_id', guestId);
    }

    setState(() {
      _userId = guestId;
    });
  }


  // Veri ekleme fonksiyonu
  Future<void> _createItem(String value) async {
    if (_userId == null) {
      print("Kullanıcı kimliği belirlenmemiş!");
      return;
    }

    await _fireStore.collection("items").add({
      'name': value,
      'userId': _userId,  // Misafir veya giriş yapmış kullanıcı kimliği
    });
  }

  // Veritabanına item güncelleme
  Future<void> _updateItems(String id, String newValue) async {
    await _fireStore.collection("items").doc(id).update({'name': newValue});
  }

  // Veritabanından item silme
  Future<void> _deleteItems(String id) async {
    await _fireStore.collection("items").doc(id).delete();
  }

  Future<void> _showUpdateDialog(String id, String currentName) async {
    final TextEditingController updateController =
    TextEditingController(text: currentName);

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Güncelle"),
            content: TextField(
              controller: updateController,
              decoration: InputDecoration(
                labelText: 'Yeni Değer',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("İptal")),
              TextButton(
                  onPressed: () {
                    if (updateController.text.isNotEmpty) {
                      _updateItems(id, updateController.text);
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text("Güncelle")),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Firebase CRUD"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: "Yeni veri ekle",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  _createItem(_controller.text);
                  _controller.clear();
                }
              },
              child: Text('Ekle')),
          Expanded(
            child: _userId == null
                ? Center(child: CircularProgressIndicator())
                : StreamBuilder<QuerySnapshot>(
              stream: _fireStore
                  .collection('items')
                  .where('userId', isEqualTo: _userId)
                  .snapshots(),
              builder: (context, snapshots) {
                if (snapshots.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshots.hasError) {
                  return Center(
                    child: Text('Hata: ${snapshots.error}'),
                  );
                }

                if (!snapshots.hasData || snapshots.data!.docs.isEmpty) {
                  return Center(
                    child: Text("Henüz veri yok"),
                  );
                }

                final docs = snapshots.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final name = doc['name'];
                    return ListTile(
                      title: Text(name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              _showUpdateDialog(doc.id, name);
                            },
                            icon: Icon(Icons.edit),
                          ),
                          IconButton(
                            onPressed: () {
                              _deleteItems(doc.id);
                            },
                            icon: Icon(Icons.delete),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          )

        ],
      ),
    );
  }
}