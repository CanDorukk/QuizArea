import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizarea/core/LocaleManager.dart';
import 'package:quizarea/core/ThemeManager.dart';

class IntroPage1 extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final localManager = Provider.of<LocalManager>(context);  // listen: true yapıyoruz
    final themeManager = Provider.of<ThemeManager>(context);

    Color textColor = Theme.of(context).textTheme.bodyLarge!.color!;
    Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Container(
      color: backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Resim ekleme
          Image.asset(
            'assets/images/image1.png', // Kendi resim yolunu buraya yaz
            height: 300,
          ),
          const SizedBox(height: 20),

          // Açıklama yazısı
          Text(
            '${localManager.translate("welcome")}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            localManager.translate("onb_welcome_qa"),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color:textColor,
            ),
          ),
        ],
      ),
    );
  }
}
