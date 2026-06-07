import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
// import 'package:movie_app/AskName/AskName.dart';
import 'package:movie_app/Authentication/SignIn.dart';
import 'package:movie_app/Screens/Introduction/Model/model.dart';

class IntroductionBody extends StatefulWidget {
  const IntroductionBody({super.key});

  @override
  State<IntroductionBody> createState() => _IntroductionBodyState();
}

class _IntroductionBodyState extends State<IntroductionBody> {
  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      globalBackgroundColor: Colors.transparent,
      pages: getPages(),
      onDone: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) {
              return SignIn();
            },
          ),
          ModalRoute.withName('/signin'),
        );
      },

      showSkipButton: false,
      skip: Text(
        "Skip",
        style: TextStyle(
          fontSize: 15,
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
      next: const Icon(Icons.arrow_back, color: Colors.black),
      done: const Text(
        "Done",
        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
      ),
      dotsDecorator: DotsDecorator(
        size: const Size.square(10.0),
        activeSize: const Size(20.0, 10.0),
        activeColor: Colors.purple,
        color: Colors.black26,
        spacing: const EdgeInsets.symmetric(horizontal: 3.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
    );
  }
}
