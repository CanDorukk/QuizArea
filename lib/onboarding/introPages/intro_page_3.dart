import 'package:flutter/material.dart';

class IntroPage3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
          const Text(
            'Hoş Geldiniz!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Uygulamamıza hoş geldiniz. Hemen başlayın ve harika deneyimin tadını çıkarın!',
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
