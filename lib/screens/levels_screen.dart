import 'package:flutter/material.dart';

class LevelsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Levels Screen"),
        centerTitle: true,
        automaticallyImplyLeading: false,  // This will remove the back button
      ),
      body: CustomLevelPath(),
    );
  }
}

class CustomLevelPath extends StatelessWidget {
  final List<Offset> levelPositions = [
    Offset(100, 100), // 1. yuvarlak: Sol-orta
    Offset(250, 200), // 2. yuvarlak: Orta-sağ
    Offset(100, 300), // 3. yuvarlak: Sol-orta
    Offset(250, 400), // 4. yuvarlak: Orta-sağ
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Eğri çizgiler
        CustomPaint(
          size: Size.infinite,
          painter: LevelLinePainter(levelPositions),
        ),
        // Yuvarlak butonlar
        for (int i = 0; i < levelPositions.length; i++)
          Positioned(
            left: levelPositions[i].dx - 40, // Yuvarlak butonun merkezi
            top: levelPositions[i].dy - 40, // Yuvarlak butonun merkezi
            child: LevelButton(
              level: 'Seviye ${i + 1}',
              onPressed: () {
                _showLevelCard(context, 'Seviye ${i + 1}', levelPositions[i]);
              },
            ),
          ),
      ],
    );
  }

  void _showLevelCard(BuildContext context, String level, Offset buttonPosition) {
    // OverlayEntry'yi üst seviyede tanımla
    late OverlayEntry overlayEntry;

    // OverlayEntry oluştur
    overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        // Ekranın herhangi bir yerine tıklandığında kartı kapat
        onTap: () {
          overlayEntry.remove(); // Kartı kapat
        },
        child: Material(
          color: Colors.black.withOpacity(0.5), // Arka planı karart
          child: Center(
            child: GestureDetector(
              // Kartın içine tıklandığında kapatma
              onTap: () {}, // Kartın içine tıklandığında hiçbir şey yapma
              child: Card(
                elevation: 4.0, // Gölge efekti
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0), // Köşeleri yuvarlak
                ),
                child: Container(
                  width: 300.0, // Kartın genişliği
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Kartın boyutunu içeriğe göre ayarla
                    children: [
                      Text(
                        level,
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16.0), // Boşluk
                      ElevatedButton(
                        onPressed: () {
                          // Başlat butonuna tıklandığında yapılacak işlem
                          overlayEntry.remove(); // Kartı kapat
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

    // Overlay'e kartı ekle
    if (Overlay.of(context) != null) {
      Overlay.of(context)!.insert(overlayEntry);
    } else {
      print("Overlay bulunamadı!"); // Hata durumunda log
    }
  }

  void _startLevel(BuildContext context, String level) {
    // Bölümü başlatma işlemleri burada yapılır
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$level başlatıldı!'),
      ),
    );
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
  final String level;
  final VoidCallback onPressed;

  const LevelButton({
    required this.level,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 80.0, // Yuvarlak buton boyutu
        height: 80.0, // Yuvarlak buton boyutu
        decoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle, // Yuvarlak buton
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown, // Yazıyı otomatik sığdır
            child: Text(
              level,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0, // Yazı boyutu
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center, // Yazıyı ortala
              maxLines: 2, // Maksimum satır sayısı
              overflow: TextOverflow.ellipsis, // Taşan yazıyı "..." ile göster
            ),
          ),
        ),
      ),
    );
  }
}