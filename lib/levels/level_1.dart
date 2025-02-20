import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:quizarea/core/LocaleManager.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final User? user = _auth.currentUser;

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
  List<Map<String, dynamic>> _words = [];

  @override
  void initState() {
    super.initState();
    _wordsFuture = _fetchWords();
  }

  Future<List<dynamic>> _fetchWords() async {
    final localManager = Provider.of<LocalManager>(context, listen: false);
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('words')
          .doc(widget.level)
          .get();

      if (!snapshot.exists) {
        throw Exception('Firestore\'da "${widget.level}" adında bir doküman bulunamadı.');
      }

      var data = snapshot.data();
      if (data == null || !data.containsKey(widget.level)) {
        throw Exception('"${widget.level}" dokümanında "${widget.level}" alanı bulunamadı.');
      }

      List<dynamic> words = data[widget.level];

      if (words.isEmpty) {
        throw Exception('"${widget.level}" ${localManager.translate("no_words_found_message")}.');
      }

      words.shuffle();
      return words.take(10).toList();
    } catch (e) {
      print('Hata: $e');
      throw Exception('${localManager.translate("loading_words_occurred_message")}: $e');
    }
  }


  void _nextWord(String correctTurkish) {
    setState(() {
      if (_currentIndex < _words.length - 1) {
        _currentIndex++;
        _resetWordState(_words[_currentIndex]['turkish']); // Bu satır önemli
      } else {
        _showLevelCompletedDialog();
      }
    });
  }


  void _resetWordState(String correctTurkish) {
    _controller.clear();
    _isAnswerIncorrect = false;
    _incorrectAttempts = 0;
    _imageAsset = 'assets/images/hangman_1.png';

    // Kelimenin uzunluğu kadar boş alan ayarla
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
    final localManager = Provider.of<LocalManager>(context, listen: false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(localManager.translate("guess_rights_over_message")),
        content: Text(localManager.translate("return_homepage_or_restart")),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Ana sayfa
            },
            child: Text(localManager.translate("home")),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _restartLevel();
            },
            child: Text(localManager.translate("play_again")),
          ),
        ],
      ),
    );
  }


  void _updateUserScore() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('Kullanıcı oturumu açık değil!');
      return;
    }

    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    try {
      final snapshot = await docRef.get();
      if (!snapshot.exists) {
        print('Kullanıcı belgesi bulunamadı!');
        return;
      }

      final currentScore = (snapshot.data()?['score'] ?? 0) as int;
      final newScore = currentScore + 5;

      await docRef.update({'score': newScore});

      print('Puan güncellendi: $newScore');
    } catch (e) {
      print('Puan güncelleme hatası: $e');
    }
  }


  // Kullanıcının tamamladığı seviyelerin veri tabanında completed_levels içerisine eklenmesi
  void _updateCompletedLevels() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('Kullanıcı oturumu açık değil!');
      return;
    }

    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    try {
      final snapshot = await docRef.get();
      if (!snapshot.exists) {
        print('Kullanıcı belgesi bulunamadı!');
        return;
      }

      // Mevcut completed_levels dizisini al
      List<dynamic> completedLevels = List.from(snapshot.data()?['completed_levels'] ?? []);

      // Seviye zaten eklenmişse, bir şey yapma
      if (!completedLevels.contains(widget.level)) {
        completedLevels.add(widget.level);
        await docRef.update({'completed_levels': completedLevels});
        print('Tamamlanan seviye güncellendi!');
      } else {
        print('Bu seviye zaten tamamlanmış!');
      }
    } catch (e) {
      print('Seviye güncelleme hatası: $e');
    }
  }


  void _showLevelCompletedDialog() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print('Kullanıcı oturumu açık değil!');
      return;
    }

    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    try {
      final snapshot = await docRef.get();
      if (!snapshot.exists) {
        print('Kullanıcı belgesi bulunamadı!');
        return;
      }
      final localManager = Provider.of<LocalManager>(context , listen: false);
      List<dynamic> completedLevels = List.from(snapshot.data()?['completed_levels'] ?? []);

      // Seviye tamamlanmamışsa, puan ekle ve tamamlanan seviyeye ekle
      if (!completedLevels.contains(widget.level)) {
        // Seviye tamamlanmamışsa, kullanıcıya 5 puan ekle
        _updateUserScore();
        completedLevels.add(widget.level);
        await docRef.update({'completed_levels': completedLevels});
        print('Seviye tamamlandı ve puan eklendi!');
        // Diğer işlemler
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text(localManager.translate("level_complated")),
            content: Text(localManager.translate("level_completed_congrats_message")),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Ana sayfaya dön
                },
                child: Text(localManager.translate("home")),
              ),
            ],
          ),
        );
      } else {
        // Seviye daha önce tamamlandıysa, sadece kullanıcıya mesaj göster
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text(localManager.translate("level_complated")),
            content: Text(localManager.translate("level_completed_before_message")),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Ana sayfaya dön
                },
                child: Text(localManager.translate("home")),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Seviye güncelleme hatası: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    final localManager = Provider.of<LocalManager>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: Text(widget.level)),
      body: FutureBuilder<List<dynamic>>(
        future: _wordsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print('${localManager.translate("error")}: ${snapshot.error}'); // Debug ekle
            return Center(child: Text('${localManager.translate("error")}: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(localManager.translate("data_not_found")));
          }

          _words = snapshot.data!.cast<Map<String, dynamic>>();
          print("${localManager.translate("selected_words")} $_words"); // Debug ekle

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
                  word['english'] ?? localManager.translate("unknown"),
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
                          color: letter == null
                              ? (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white // white for dark theme
                              : Colors.black) // black for light theme
                              : Colors.transparent, // Don't show underline for revealed letters
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
                      labelText: localManager.translate("turkish_meaning"),
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (input) => _checkAnswer(input, correctTurkish),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _checkAnswer(_controller.text, correctTurkish),
                  child: Text(localManager.translate("check")),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}