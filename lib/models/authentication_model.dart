import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthenticationModel extends ChangeNotifier {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    User? _currentUser;

    User? get currentUser => _currentUser;

    AuthenticationModel() {
        _auth.authStateChanges().listen((user) {
            _currentUser = user;
            notifyListeners();
        });
    }

    Future<User?> loginWithEmailAndPassword(String email, String password) async {
        try {
            UserCredential userCredential = await _auth.signInWithEmailAndPassword(
                email: email.trim(),
                password: password.trim(),
            );
            _currentUser = userCredential.user;
            notifyListeners();
            return _currentUser;
        } on FirebaseAuthException catch (e) {
            throw Exception(e.message);
        }
    }

    Future<User?> registerWithEmailAndPassword(
        String email, String password, String name, String surname) async {
        try {
            // Create user with email and password
            UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
                email: email.trim(),
                password: password.trim(),
            );

// User'u almak ve Firestore işlemini gerçekleştirmeden önce kontrol etmek
            User? user = _auth.currentUser;
            if (user == null) {
                throw Exception("Kullanıcı doğrulaması yapılamadı.");
            }

            // Update user profile
            await user.updateDisplayName('$name $surname');
            await user.reload();

            // Save user info to Firestore
            await _firestore.collection('users').doc(user.uid).set({
                'uid': user.uid,
                'email': email,
                'name': name,
                'surname': surname,
                'fullName': '$name $surname',
                'score': 0, // starting score
                'level': 1, // starting level
                'createdAt': FieldValue.serverTimestamp(),
                "completed_levels":[],
            });

            _currentUser = _auth.currentUser;
            notifyListeners();

            return _currentUser;
        } on FirebaseAuthException catch (e) {
            print("Error code: ${e.code}");
            print("Error message: ${e.message}");
            throw Exception(e.message);
        } catch (e) {
            print("Unknown error: $e");
            if (e is FirebaseException) {
                print("Firestore Error: ${e.message}");
            }
            throw Exception('An unknown error occurred');
        }

    }


    Future<void> signOut() async {
        await _auth.signOut();
        _currentUser = null;
        notifyListeners();
    }
}
