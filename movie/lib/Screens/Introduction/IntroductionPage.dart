import 'package:flutter/material.dart';
import 'package:movie_app/Screens/Introduction/Components/IntroductionBody.dart';

class IntroductionPage extends StatefulWidget {
  const IntroductionPage({super.key});

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
     
      resizeToAvoidBottomInset: false,
      body: IntroductionBody(),
    );
  }
}