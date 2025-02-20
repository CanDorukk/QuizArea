import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizarea/onboarding/introPages/intro_page_1.dart';
import 'package:quizarea/onboarding/introPages/intro_page_2.dart';
import 'package:quizarea/onboarding/introPages/intro_page_3.dart';
import 'package:quizarea/screens/home_screen.dart';
import 'package:quizarea/screens/login_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:quizarea/core/LocaleManager.dart';
class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({Key? key}): super(key: key);

  @override
  State<OnBoardingScreen> createState() => _OnBoardState();
}

class _OnBoardState extends State<OnBoardingScreen> {

  // controller to keep track which page we are on
  PageController _controller = PageController();

  // keep track last page or not
  bool onLastPage = false;

  @override
  Widget build(BuildContext context) {
    final localManager = Provider.of<LocalManager>(context);
    return Scaffold(
     body: Stack(
       children: [
         // page view
         PageView(
           controller: _controller,
           onPageChanged: (index){
             setState(() {
               onLastPage = (index==2);
             });
           },
           children: [

             IntroPage1(),
             IntroPage2(),
             IntroPage3(),

           ],
         ),

         // dot indicators
         Container(
           alignment: Alignment(0, 0.75),
           child: Row(
             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
             children: [

               // skip
               GestureDetector(
                 onTap: (){
                   _controller.jumpToPage(2);
                 },
                 child: Text(localManager.translate("skip")),
               ),
               // dot indicator
               SmoothPageIndicator(controller: _controller,count: 3),


               // next or done
               onLastPage ?
               GestureDetector(
                 onTap: (){
                   Navigator.push(context, MaterialPageRoute(builder: (context){
                     return LoginScreen();
                   }
                   ),
                   );
                 },
                 child: Text(localManager.translate("login")),
               )
                   : GestureDetector(
                 onTap: (){
                   _controller.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeIn);
                 },
                 child: Text(localManager.translate("next")),
               ),
             ],
           ),
         ),
       ],
     )
    );
  }
}
