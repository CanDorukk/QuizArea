import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quizarea/core/LocaleManager.dart';
import 'package:quizarea/core/ThemeManager.dart';
import 'package:quizarea/main.dart';
import 'package:quizarea/models/authentication_model.dart';
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

  final List<Widget> _screens = [
    LevelsScreen(),
    ProfileScreen(),
    RegisterScreen(),

  ];

  void _onItemTapped(int index) async {
    final localManager = Provider.of<LocalManager>(context, listen: false); // 🔹 listen: false ekledik
    if (index == 2) { // Profil ekranı seçildiğinde
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

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(localManager.translate('title')),
        ),
      ),

      drawer: Drawer(
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

            // 📌 Tema Değiştirme Seçeneği
            SwitchListTile(
              title: Text(localManager.translate('dark_theme')),
              value: themeManager.themeMode == ThemeMode.dark,
              onChanged: (bool value) {
                themeManager.toggleTheme();
              },
              secondary: Icon(Icons.brightness_6),
            ),

            // 📌 Dil Değiştirme Seçeneği
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

            // 📌 Giriş Yap & Çıkış Yap Butonu
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
                      // 1. "Çıkış yapılıyor..." mesajını göster
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(localManager.translate('logging_out')),
                          duration: Duration(milliseconds: 1500), // 1.5 saniye
                        ),
                      );

                      await Future.delayed(Duration(milliseconds: 1500));

                      // 2. Firebase'den çıkış yap
                      await authModel.signOut();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => AuthCheck()),
                            (route) => false,
                      );

                      // 3. "Başarıyla çıkış yapıldı." mesajını göster
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(localManager.translate('logout_success')),
                          duration: Duration(milliseconds: 1500), // 1.5 saniye
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
      ),

      body: IndexedStack(
        index: _selectedIndex,
        children: [
          LevelsScreen(),
          ProfileScreen(),
          RegisterScreen(),
        ],
      ),

      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTop: _onItemTapped,
      ),
    );
  }
}
