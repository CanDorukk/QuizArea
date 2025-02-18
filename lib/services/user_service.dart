import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateUserScore(String uid, int newScore) async {
    await _firestore.collection('users').doc(uid).update({
      'score': newScore,
    });
  }

  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .orderBy('score', descending: true)
        .limit(10)
        .get();

    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }
}


/*

Örneğin, bir butona tıkladığında puanı artırmak istiyorsun diyelim:

final userService = UserService();
await userService.updateUserScore(currentUser!.uid, yeniPuan);

Liderlik tablosunu çekmek için:

final leaderboard = await userService.getLeaderboard();
print(leaderboard);

*/

