import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizarea/core/LocaleManager.dart';

class IntroPage3 extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final localManager = Provider.of<LocalManager>(context);  // listen: true yapıyoruz

    return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [


          // Resim ekleme
          Image.asset(
            'assets/images/image3.png', // Kendi resim yolunu buraya yaz
            height: 300,
          ),
          const SizedBox(height: 20),

          // Açıklama yazısı
           Text(
            localManager.translate("register"),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),

           Text(
             localManager.translate("onb_register_text"),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
