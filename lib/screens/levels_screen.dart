import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quizarea/levels/level_1.dart';


class LevelsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(// Gri arka plan rengi #4b4b4b
        child: CustomLevelPath(),
      ),
    );
  }
}
class CustomBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

class CustomLevelPath extends StatelessWidget {
  final List<Offset> levelPositions = [
    Offset(100, 100),
    Offset(250, 200),
    Offset(100, 300),
    Offset(250, 400),
    Offset(100, 500),
    Offset(250, 600),
    Offset(100, 700),
    Offset(250, 800),
    Offset(100, 900),
    Offset(250, 1000),
    Offset(100, 1100),
    Offset(250, 1200),
    Offset(100, 1300),
    Offset(250, 1400),
    Offset(100, 1500),
    Offset(250, 1600),
    Offset(100, 1700),
    Offset(250, 1800),
    Offset(100, 1900),
    Offset(250, 2000),
  ];

  final List<IconData> levelIcons = [
    Icons.star,
    Icons.book,
    Icons.music_note,
    Icons.ac_unit,
    Icons.star,
    Icons.book,
    Icons.music_note,
    Icons.ac_unit,
    Icons.star,
    Icons.book,
    Icons.music_note,
    Icons.ac_unit,
    Icons.star,
    Icons.book,
    Icons.music_note,
    Icons.ac_unit,
    Icons.star,
    Icons.book,
    Icons.music_note,
    Icons.ac_unit,
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .snapshots(), // Anlık veri akışı
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Hata: ${snapshot.error}'));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(child: Text('Kullanıcı verisi bulunamadı.'));
        }

        List<dynamic> completedLevels = List.from(snapshot.data!['completed_levels'] ?? []);

        return SingleChildScrollView(
          child: Container(
            height: 2200, // Tüm seviyelerin sığacağı yükseklik
            child: Stack(
              children: [
                CustomPaint(
                  size: Size(MediaQuery.of(context).size.width, 2200),
                  painter: LevelLinePainter(levelPositions),
                ),
                for (int i = 0; i < 20; i++) // 20 seviye için
                  Positioned(
                    left: levelPositions[i].dx - 40,
                    top: levelPositions[i].dy - 40,
                    child: LevelButton(
                      icon: levelIcons[i],
                      isEnabled: i == 0 || completedLevels.contains('Level_${i}'),
                      onPressed: () {
                        if (i == 0 || completedLevels.contains('Level_${i}')) {
                          _showLevelCard(context, 'Seviye ${i + 1}');
                        } else {
                          // Seviye tamamlanmamışsa uyarı göster
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Bu seviyeyi açmak için önceki seviyeyi tamamlamalısınız!'))
                          );
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLevelCard(BuildContext context, String level) {
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: () {
          overlayEntry.remove();
        },
        child: Material(
          color: Colors.black.withOpacity(0.5),
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: Card(
                elevation: 8.0,  // Daha belirgin gölge
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0), // Yumuşak köşeler
                ),
                child: Container(
                  width: 320.0,
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        level,
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      SizedBox(height: 20.0),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.blue, // Buton rengi
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        onPressed: () {
                          overlayEntry.remove();
                          _startLevel(context, level);
                        },
                        child: Text('Başlat'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context)?.insert(overlayEntry);
  }


  void _startLevel(BuildContext context, String level) {
    // Seviye adını dinamik olarak oluştur
    String firestoreLevelName = _getFirestoreLevelName(level);
    print("Firestore Doküman Adı: $firestoreLevelName"); // Debug ekle
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LevelDetailScreen(level: firestoreLevelName),
      ),
    );
  }

  String _getFirestoreLevelName(String level) {
    // Örnek: "Seviye 1" -> "A1_first_50", "Seviye 2" -> "A1_first_100", vb.
    int levelNumber = int.tryParse(level.replaceAll("Seviye ", "")) ?? 1;

    if (levelNumber <= 10) {
      return "Level_${levelNumber}";
    } else if (levelNumber <= 20) {
      return "Level_${levelNumber}";
    }
    // Diğer seviyeler için genişletilebilir
    return "A1_first_50"; // Varsayılan
  }
}


class LevelLinePainter extends CustomPainter {
  final List<Offset> levelPositions;

  LevelLinePainter(this.levelPositions);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueGrey
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round; // Yumuşak uçlar

    final path = Path();
    path.moveTo(levelPositions[0].dx, levelPositions[0].dy);

    for (int i = 1; i < levelPositions.length; i++) {
      path.quadraticBezierTo(
        levelPositions[i - 1].dx,
        levelPositions[i - 1].dy,
        levelPositions[i].dx,
        levelPositions[i].dy,
      );
    }

    // Gradient arka plan
    final gradient = LinearGradient(
      colors: [Colors.blue.withOpacity(0.8), Colors.transparent],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final gradientPaint = paint..shader = gradient.createShader(Rect.fromCircle(center: Offset(size.width / 3, size.height / 3), radius: 2000));

    canvas.drawPath(path, gradientPaint);  // Çizgiyi gradient ile çizin
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LevelButton extends StatelessWidget {
  final IconData icon;
  final bool isEnabled;
  final VoidCallback onPressed;

  const LevelButton({
    required this.icon,
    required this.isEnabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Transform.rotate(
        angle: 25 * 3.14159 / 180, // 25 dereceyi radian cinsine çeviriyoruz
        child: Container(
          width: 80.0,
          height: 90.0, // Yüksekliği biraz artırıyoruz
          decoration: BoxDecoration(
            color: isEnabled ? Colors.blue : Colors.grey,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40.0), // Alt kısmı genişletiyoruz
              bottomRight: Radius.circular(40.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                offset: Offset(6, 6), // Yüksekliğini artırarak perspektif etkisi
                blurRadius: 8.0, // Yumuşak gölge
              ),
            ],
          ),
          child: Center(
            child: Icon(
              icon,
              color: Colors.white,
              size: 40.0,
            ),
          ),
        ),
      ),
    );
  }
}