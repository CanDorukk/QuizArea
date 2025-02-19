import 'package:flutter/material.dart';
import 'package:quizarea/levels/level_1.dart';

class LevelsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Levels Screen"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: CustomLevelPath(),
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
    return SingleChildScrollView(
      child: Container(
        height: 2200, // Tüm seviyelerin sığacağı yükseklik
        child: Stack(
          children: [
            CustomPaint(
              size: Size(MediaQuery.of(context).size.width, 2200), // Canvas boyutu
              painter: LevelLinePainter(levelPositions),
            ),
            for (int i = 0; i < 20; i++) // 20 seviye için
              Positioned(
                left: levelPositions[i].dx - 40,
                top: levelPositions[i].dy - 40,
                child: LevelButton(
                  icon: levelIcons[i],
                  onPressed: () {
                    _showLevelCard(context, 'Seviye ${i + 1}');
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }


  void _showLevelCard(BuildContext context, String level) {
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) =>
          GestureDetector(
            onTap: () {
              overlayEntry.remove();
            },
            child: Material(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: GestureDetector(
                  onTap: () {},
                  child: Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Container(
                      width: 300.0,
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            level,
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16.0),
                          ElevatedButton(
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
      return "A2_first_${50 * (levelNumber - 10)}";
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
      ..color = Colors.grey
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

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

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LevelButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const LevelButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 80.0,
        height: 80.0,
        decoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: Offset(-1, 5),
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
    );
  }
}