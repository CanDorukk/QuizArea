import 'package:flutter/material.dart';

class LevelDetailScreen extends StatelessWidget {
  final String level;

  const LevelDetailScreen({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    // Burada veritabanından 'level' parametresine göre veri çekebilirsin.
    // Örneğin, Firebase veya SQLite gibi.
    // Şimdilik basitçe yazıyla gösterelim.

    String levelData = _fetchLevelData(level);

    return Scaffold(
      appBar: AppBar(
        title: Text('$level Detayı'),
      ),
      body: Center(
        child: Text(
          levelData,
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  String _fetchLevelData(String level) {
    // Burada veritabanından çekme işlemini yapacaksın
    // Örnek olması için statik veri:
    switch (level) {
      case 'Seviye 1':
        return 'Bu Seviye 1\'in içeriği';
      case 'Seviye 2':
        return 'Bu Seviye 2\'nin içeriği';
      case 'Seviye 3':
        return 'Bu Seviye 3\'ün içeriği';
      case 'Seviye 4':
        return 'Bu Seviye 4\'ün içeriği';
      default:
        return 'Bilinmeyen seviye!';
    }
  }
}
