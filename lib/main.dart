import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:quizarea/core/LocaleManager.dart';
import 'package:quizarea/core/ThemeManager.dart';
import 'package:quizarea/data/json_upload.dart';
import 'package:quizarea/models/authentication_model.dart';
import 'package:quizarea/onboarding/onboard.dart';
import 'package:quizarea/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();


  // Firestore ayarlarını yapıyoruz
  FirebaseFirestore.instance.settings = Settings(
    persistenceEnabled: true, // Çevrimdışı verileri etkinleştiriyoruz
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED, // Cache boyutunu sınırsız yapıyoruz
  );
 //await uploadWords(); // JSON verisini yüklemek için
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager()),
        ChangeNotifierProvider(create: (_) => LocalManager()),
        ChangeNotifierProvider(create: (_) => AuthenticationModel()), // AuthenticationModel'ı burada sağlıyoruz
      ],
      child: Consumer2<ThemeManager, LocalManager>(
        builder: (context, themeManager, localManager, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Firebase Demo',
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: themeManager.themeMode,
            locale: localManager.currentLocale,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('tr'),
            ],
            home: AuthCheck(),
          );
        },
      ),
    );
  }
}

class AuthCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authModel = Provider.of<AuthenticationModel>(context);

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return HomeScreen(); // Kullanıcı giriş yaptı
        } else {
          return OnBoardingScreen(); // Kullanıcı giriş yapmadı
        }
      },
    );
  }
}
