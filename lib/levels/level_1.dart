import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  ];

  final List<IconData> levelIcons = [
    Icons.star,
    Icons.book,
    Icons.music_note,
    Icons.ac_unit,
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          size: Size.infinite,
          painter: LevelLinePainter(levelPositions),
        ),
        for (int i = 0; i < levelPositions.length; i++)
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LevelDetailScreen(level: level),
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
class LevelDetailScreen extends StatefulWidget {
  final String level;

  LevelDetailScreen({required this.level});

  @override
  _LevelDetailScreenState createState() => _LevelDetailScreenState();
}

class _LevelDetailScreenState extends State<LevelDetailScreen> {
  late Future<List<dynamic>> _wordsFuture;
  int _currentIndex = 0;
  final TextEditingController _controller = TextEditingController();
  bool _isAnswerIncorrect = false;
  int _incorrectAttempts = 0;
  int _maxAttempts = 3;
  String _imageAsset = 'assets/images/hangman_1.png';
  List<String?> _revealedLetters = [];
  @override
  void initState() {
    super.initState();
    _wordsFuture = _fetchWords();
  }

  Future<List<dynamic>> _fetchWords() async {
    var snapshot = await FirebaseFirestore.instance.collection('words').doc("A1_first_50").get();
    var data = snapshot.data() as Map<String, dynamic>;
    return data['A1_first_50'] ?? [];
  }

  void _nextWord(String correctTurkish) {
    setState(() {
      if (_currentIndex < 49) {
        _currentIndex++;
        _controller.clear();
        _isAnswerIncorrect = false;
        _incorrectAttempts = 0;
        _imageAsset = 'assets/images/hangman_1.png';
        _wordsFuture.then((words) {
          var nextCorrectTurkish = words[_currentIndex]['turkish'];
          _resetWordState(nextCorrectTurkish);
        });
      }
    });
  }



  void _resetWordState(String correctTurkish) {
    _controller.clear();
    _isAnswerIncorrect = false;
    _incorrectAttempts = 0;
    _imageAsset = 'assets/images/hangman_1.png';
    _revealedLetters = List.filled(correctTurkish.length, null);
    _maxAttempts = correctTurkish.length < 7 ? 3 : 5;
  }

  void _checkAnswer(String input, String correctTurkish) {
    if (input.trim().toLowerCase() != correctTurkish.trim().toLowerCase()) {
      setState(() {
        _isAnswerIncorrect = true;
        _incorrectAttempts++;

        if (_incorrectAttempts == 1) {
          _imageAsset = 'assets/images/hangman_2.png';
        } else if (_incorrectAttempts == 2) {
          _imageAsset = 'assets/images/hangman_3.png';
        } else if (_incorrectAttempts == 3) {
          _imageAsset = 'assets/images/hangman_4.png';
        } else if (_incorrectAttempts >= 4) {
          _imageAsset = 'assets/images/hangman_5.png';
        }

        _revealRandomLetter(correctTurkish);

        if (_revealedLetters.isEmpty || _revealedLetters.length != correctTurkish.length) {
          _resetWordState(correctTurkish);
        }


        if (_incorrectAttempts >= _maxAttempts) {
          _showRetryDialog(correctTurkish);
        }
      });
    } else {
      _nextWord(correctTurkish);
    }
  }


  void _revealRandomLetter(String correctTurkish) {
    final random = Random();
    List<int> hiddenIndexes = [];

    for (int i = 0; i < correctTurkish.length; i++) {
      if (_revealedLetters[i] == null) {
        hiddenIndexes.add(i);
      }
    }

    if (hiddenIndexes.isNotEmpty) {
      int randomIndex = hiddenIndexes[random.nextInt(hiddenIndexes.length)];
      _revealedLetters[randomIndex] = correctTurkish[randomIndex];
    }
  }
  void _restartLevel() {
    setState(() {
      _currentIndex = 0;
      _resetWordState(_words[_currentIndex]['turkish']);
    });
  }

  void _showRetryDialog(String correctTurkish) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Tahmin Hakkın Bitti"),
        content: Text("Ana sayfaya dönmek veya tekrar başlamak ister misiniz?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Ana sayfa
            },
            child: Text("Ana Sayfa"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _restartLevel();
            },
            child: Text("Tekrar Başla"),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _words = [];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.level)),
      body: FutureBuilder<List<dynamic>>(
        future: _wordsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Veri bulunamadı'));
          }

          _words = snapshot.data!.cast<Map<String, dynamic>>(); // <<<<< EKLEDİK

          var word = _words[_currentIndex];
          String correctTurkish = word['turkish'] ?? '';


          if (_revealedLetters.isEmpty) {
            _resetWordState(correctTurkish);
          }

          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  _imageAsset,
                  height: 250.0,
                  width: 200,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 20),
                Text(
                  word['english'] ?? 'Bilinmiyor',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  children: _revealedLetters.map((letter) {
                    return Column(
                      children: [
                        Text(
                          letter ?? '',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          width: 24,
                          height: 2,
                          color: Colors.black,
                        ),
                      ],
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Türkçe anlamı',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (input) => _checkAnswer(input, correctTurkish),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _checkAnswer(_controller.text, correctTurkish),
                  child: Text('Kontrol Et'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


