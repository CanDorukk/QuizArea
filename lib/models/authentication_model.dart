import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthenticationModel extends ChangeNotifier {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    User? _currentUser;

    User? get currentUser => _currentUser;

    AuthenticationModel() {
        _auth.authStateChanges().listen((user) {
            _currentUser = user;
            notifyListeners(); // Oturum durumu değiştiğinde listeners'ları bilgilendir
        });
    }

    Future<User?> loginWithEmailAndPassword(String email, String password) async {
        try {
            UserCredential userCredential = await _auth.signInWithEmailAndPassword(
                email: email.trim(),
                password: password.trim(),
            );
            _currentUser = userCredential.user;
            notifyListeners(); // Oturum durumu değiştiği için listeners'ları bilgilendir
            return _currentUser;
        } on FirebaseAuthException catch (e) {
            throw Exception(e.message);
        }
    }

    Future<User?> registerWithEmailAndPassword(
        String email, String password, String name, String surname) async {
        try {
            UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
                email: email.trim(),
                password: password.trim(),
            );

            // Kullanıcı profilini güncelle (İsim ekle)
            await userCredential.user?.updateDisplayName(name);
            await userCredential.user?.reload(); // Firebase'de güncellemeleri yansıt

            _currentUser = _auth.currentUser;
            notifyListeners(); // Oturum durumu değiştiği için listeners'ları bilgilendir
            return _currentUser;
        } on FirebaseAuthException catch (e) {
            throw Exception(e.message);
        }
    }

    Future<void> signOut() async {
        await _auth.signOut();
        _currentUser = null;
        notifyListeners(); // Oturum durumu değiştiği için listeners'ları bilgilendir
    }
}
