import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quizarea/core/LocaleManager.dart';
import 'package:quizarea/core/ThemeManager.dart';
import 'package:quizarea/main.dart';
import 'package:quizarea/models/authentication_model.dart';
import 'package:quizarea/screens/leaderboard_screen.dart';
import 'package:quizarea/screens/levels_screen.dart';
import 'package:quizarea/screens/login_screen.dart';
import 'package:quizarea/screens/proife_screen.dart';
import 'package:quizarea/screens/register_screen.dart';
import 'package:quizarea/widget/bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Map<String, Object>> _screens = [
    {'screen': LevelsScreen(), 'title': 'levels'},
    {'screen': LeaderBoard(), 'title': 'leaderboard'},
    {'screen': ProfileScreen(), 'title': 'profile'},
  ];

  void _onItemTapped(int index) async {
    final localManager = Provider.of<LocalManager>(context, listen: false);
    if (index == 15) { // Profil ekranı seçildiğinde
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        // Eğer kullanıcı giriş yapmadıysa SnackBar göster ve sonra LoginScreen'e yönlendir
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localManager.translate("loginization_message")),
            duration: Duration(milliseconds: 1000),
          ),
        );

        // Kullanıcıyı LoginScreen'e yönlendiriyoruz
        Future.delayed(Duration(milliseconds: 1000), () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        });
      } else {
        setState(() {
          _selectedIndex = index;
        });
      }
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localManager = Provider.of<LocalManager>(context);
    final themeManager = Provider.of<ThemeManager>(context);
    final authModel = Provider.of<AuthenticationModel>(context);

    // Sayfanın başlığını çeviriyoruz
    String title = localManager.translate(_screens[_selectedIndex]['title'] as String);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 80.0,
        title: _selectedIndex == 2
            ? Align(
          alignment: FractionalOffset(0.0, 0.5),
          child: Padding(
            padding: const EdgeInsets.only(left: 140.0),
            child: Text(title),
          ),
        )
            : Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Center(
            child: Text(title),
          ),
        ),
        actions: _selectedIndex == 2 // Profile ekranında ikonu göster
            ? [
          Builder(
            builder: (BuildContext context) => IconButton(
              icon: Icon(Icons.settings), // Gear icon
              onPressed: () {
                Scaffold.of(context).openEndDrawer(); // Sağdaki endDrawer'ı aç
              },
            ),
          ),
        ]
            : [], // Diğer ekranlarda ikon görünmesin
      ),
      endDrawer: _selectedIndex == 2
          ? Drawer( // Only show the endDrawer when on the profile screen
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                localManager.translate("settings"),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            // Tema ve dil seçenekleri...
            SwitchListTile(
              title: Text(localManager.translate('dark_theme')),
              value: themeManager.themeMode == ThemeMode.dark,
              onChanged: (bool value) {
                themeManager.toggleTheme();
              },
              secondary: Icon(Icons.brightness_6),
            ),
            ListTile(
              leading: Icon(Icons.language),
              title: Text(localManager.translate('language')),
              trailing: DropdownButton<Locale>(
                value: localManager.currentLocale,
                onChanged: (Locale? newLocale) {
                  if (newLocale != null) {
                    localManager.changedLocale(newLocale);
                  }
                },
                items: const [
                  DropdownMenuItem(
                    value: Locale('en'),
                    child: Text('English'),
                  ),
                  DropdownMenuItem(
                    value: Locale('tr'),
                    child: Text('Türkçe'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  authModel.currentUser == null
                      ? ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: Text(localManager.translate('login')),
                  )
                      : ElevatedButton(
                    onPressed: () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(localManager.translate('logging_out')),
                          duration: Duration(milliseconds: 1500),
                        ),
                      );

                      await Future.delayed(Duration(milliseconds: 1500));

                      await authModel.signOut();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => AuthCheck()),
                            (route) => false,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(localManager.translate('logout_success')),
                          duration: Duration(milliseconds: 1500),
                        ),
                      );
                    },
                    child: Text(localManager.translate('logout')),
                  ),
                ],
              ),
            ),
          ],
        ),
      )
          : null, // Diğer ekranlarda endDrawer gösterilmesin
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          LevelsScreen(),
          LeaderBoard(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTop: _onItemTapped,
      ),
    );
  }
}
