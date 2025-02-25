import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizarea/onboarding/introPages/intro_page_1.dart';
import 'package:quizarea/onboarding/introPages/intro_page_2.dart';
import 'package:quizarea/onboarding/introPages/intro_page_3.dart';
import 'package:quizarea/screens/login_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:quizarea/core/LocaleManager.dart';
import 'package:quizarea/core/ThemeManager.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardState();
}

class _OnboardState extends State<OnboardingScreen> {
  PageController _controller = PageController();
  bool onLastPage = false;

  @override
  Widget build(BuildContext context) {
    final localManager = Provider.of<LocalManager>(context);
    final themeManager = Provider.of<ThemeManager>(context);

    Color textColor = Theme.of(context).textTheme.bodyLarge!.color!;
    Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    Color buttonColor = themeManager.themeMode == ThemeMode.dark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                onLastPage = (index == 2);
              });
            },
            children: [
              IntroPage1(),
              IntroPage2(),
              IntroPage3(),
            ],
          ),
          Container(
            alignment: Alignment(0, 0.75),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    _controller.jumpToPage(2);
                  },
                  child: Text(
                    localManager.translate("skip"),
                    style: TextStyle(color: textColor),
                  ),
                ),
                SmoothPageIndicator(
                  controller: _controller,
                  count: 3,
                  effect: WormEffect(
                    dotColor: textColor.withOpacity(0.5),
                    activeDotColor: buttonColor,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (onLastPage) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    } else {
                      _controller.nextPage(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeIn,
                      );
                    }
                  },
                  child: Text(
                    localManager.translate(onLastPage ? "login" : "next"),
                    style: TextStyle(color: buttonColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
