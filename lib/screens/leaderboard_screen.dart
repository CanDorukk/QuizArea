import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LeaderBoard extends StatelessWidget {
  // Firestore'dan veri çekme
  Future<List<Map<String, dynamic>>> _fetchUsers() async {
    try {
      // Firestore'dan 'users' koleksiyonunu çekiyoruz
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').get();

      // Veriyi map'e dönüştürüp liste olarak döndürüyoruz
      List<Map<String, dynamic>> users = snapshot.docs
          .map((doc) {
        // Verinin Map olarak alındığını kontrol ediyoruz
        var data = doc.data() as Map<String, dynamic>;

        // completed_levels verisini kontrol edip düzgün biçimde dönüştürüyoruz
        var completedLevels = data.containsKey('completed_levels') && data['completed_levels'] is List
            ? List<String>.from(data['completed_levels'])
            : [];

        // Eğer 'Level_1' tamamlanmışsa kullanıcıyı döndürüyoruz
        if (completedLevels.contains('Level_1')) {
          return {
            'fullName': data['fullName'],// Kullanıcı adı
            'score': data['score'], // Kullanıcı puanı
            'completed_levels': completedLevels, // Kullanıcı tamamlanan seviyeler
          };
        }
        return null;
      })
      // null olmayan kullanıcıları filtreliyoruz
          .where((user) => user != null)
          .cast<Map<String, dynamic>>()
          .toList();

      // Kullanıcıları puanlarına göre büyükten küçüğe sıralıyoruz
      users.sort((a, b) => b['score'].compareTo(a['score'])); // Z'den A'ya sıralama (büyükten küçüğe)

      return users;
    } catch (e) {
      print('Hata: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Liderlik Tablosu"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Veri çekme hatası: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Liderlik tablosu boş.'));
          }

          List<Map<String, dynamic>> users = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.only(top: 24),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child:Text(user['fullName'][0], style: TextStyle(color: Colors.white)),
                  ),
                  title: Text(user['fullName'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  subtitle: Text('Tamamladığı Seviye Sayısı: ${user['completed_levels'].length}'),
                  trailing: Text('${user['score']} Puan', style: TextStyle(fontSize: 16)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
