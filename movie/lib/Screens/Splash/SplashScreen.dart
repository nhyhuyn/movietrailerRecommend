import 'dart:async';

import 'package:flutter/material.dart';
import 'package:movie_app/Screens/Home/HomePage.dart';
import 'package:movie_app/Screens/Introduction/IntroductionPage.dart';
import 'package:movie_app/configs/theme/appColors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  static bool saw = false;
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _progress = 0;
  @override
  void initState() {
    super.initState();
    redirect();
  }

  Future<void> redirect() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool seen = prefs.getBool('seen') ?? false;

    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (mounted) {
        setState(() {
          _progress += 0.1;
        });

        if (_progress >= 2) {
          timer.cancel();
          if (seen) {
            SplashScreen.saw = true;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          } else {
            SplashScreen.saw = false;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => IntroductionPage()),
            );
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _backgroundGradient(),
          _logoWidget(),
          _logoBanner(),
          _decorativeLine(),
          _loadingBar(),
        ],
      ),
    );
  }

  Widget _decorativeLine() {
    return Align(
      alignment: Alignment(-0.8, -0.82),
      child: Container(
        width: 50,
        height: 10,
        decoration: BoxDecoration(
          color: AppColors.defaultColor,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _backgroundGradient() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.splashColor,
        ),
      ),
    );
  }

  Widget _logoWidget() {
    return Align(
      alignment: Alignment(0, -0.5),
      child: Image.asset(
        'assets/images/logo.png',
        width: 200,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _logoBanner() {
    return Align(
      alignment: Alignment(0, 0.1),
      child: Text(
        'MOVIES ONLINE',
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _loadingBar() {
    return Align(
      alignment: Alignment(0, 0.6),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        height: 10,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              width: MediaQuery.of(context).size.width * 0.3 * _progress,
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.defaultColor,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
