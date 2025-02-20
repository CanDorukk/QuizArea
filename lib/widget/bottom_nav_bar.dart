import 'package:flutter/material.dart';
import 'package:quizarea/core/LocaleManager.dart';
import 'package:provider/provider.dart';
class BottomNavBar extends StatelessWidget{
  final int selectedIndex;
  final Function(int) onTop;

  const BottomNavBar({required this.selectedIndex, required this.onTop});

  @override
  Widget build(BuildContext context) {
    final localManager = Provider.of<LocalManager>(context);
    return BottomNavigationBar(
        currentIndex: selectedIndex,
        backgroundColor: Colors.white,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.red,
        onTap: onTop,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/quizarea.ico',
              width: 24.0,  // Boyutu 24x24 yapmak için
              height: 24.0, // Boyutu 24x24 yapmak için
            ),
            label: localManager.translate('home'),
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/leaderboard.ico',
              width: 24.0,  // Boyutu 24x24 yapmak için
              height: 24.0, // Boyutu 24x24 yapmak için
            ),
            label: localManager.translate('leaderboard'),
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/profile.ico',
              width: 24.0,  // Boyutu 24x24 yapmak için
              height: 24.0, // Boyutu 24x24 yapmak için
            ),
            label: localManager.translate('profile'),
          )

        ]
    );
  }
}