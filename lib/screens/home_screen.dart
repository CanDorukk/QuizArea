import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notetaking/core/LocaleManager.dart';
import 'package:notetaking/core/ThemeManager.dart';
import 'package:notetaking/screens/crud_screen.dart';
import 'package:notetaking/screens/login_screen.dart';
import 'package:notetaking/screens/settings_screen.dart';
import 'package:notetaking/widget/bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  User? _currentUser;

  final List<Widget> _screens = [
    Center(child: Text('Ana Sayfa', style: TextStyle(fontSize: 24))),
    SettingsScreen(),
    CrudScreen()
  ];

  @override
  void initState() {
    super.initState();

    _currentUser = FirebaseAuth.instance.currentUser;
    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  void _onItemTapped(int index) async {
    final localManager = Provider.of<LocalManager>(context, listen: false);
    if (index == 3) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localManager.translate("loginization_message")),
            duration: Duration(milliseconds: 1000),
          ),
        );

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
                  _currentUser == null
                      ? ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Menüyü kapat
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LoginScreen()),
                      );
                    },
                    child: Text(localManager.translate('login')),
                  )
                      : ElevatedButton(
                    onPressed: () async {
                      // Menüyü otomatik olarak kapat
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              localManager.translate('logging_out')),
                          duration: Duration(milliseconds: 1500),
                        ),
                      );

                      await Future.delayed(
                          Duration(milliseconds: 1500));

                      await FirebaseAuth.instance.signOut();

                      // Ana sayfaya dön
                      setState(() {
                        _selectedIndex = 0; // Ana sayfaya dön
                        _currentUser = null; // Kullanıcıyı null yap
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              localManager.translate('logout_success')),
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
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          Center(
            child: Text(
              localManager.translate('home'),
              style: TextStyle(fontSize: 24),
            ),
          ),
          SettingsScreen(),
          CrudScreen(),
        ],
      ),
      bottomNavigationBar:
      BottomNavBar(selectedIndex: _selectedIndex, onTop: _onItemTapped),
    );
  }
}