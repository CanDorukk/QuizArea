import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' as root_bundle;
import 'dart:convert';

Future<void> uploadWords() async {
  final firestore = FirebaseFirestore.instance;

  final String jsonString =
  await root_bundle.rootBundle.loadString('assets/json/upload_new_words.json');

  final Map<String, dynamic> data = jsonDecode(jsonString);

  await firestore.collection('words').doc('Level_20').set(data);

  print('Veri Firestore\'a yüklendi!');
}
