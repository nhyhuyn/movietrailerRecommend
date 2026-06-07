// ignore_for_file: prefer_final_fields

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:movie_app/OnboardingPage/GenereSelection/GenreSelection.dart';
import 'package:vibration/vibration.dart';
import 'package:movie_app/Util/RoundRectangleButton.dart';
import 'package:movie_app/main.dart';

String stname = "";

class AskName extends StatefulWidget {
  const AskName({super.key});

  @override
  State<AskName> createState() => _AskNameState();
}

class _AskNameState extends State<AskName> {
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: screenHeight,
        width: screenWidth,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 7.0),
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Let us know you better",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _controller,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person, color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(90.0)),
                      borderSide: BorderSide.none,
                    ),
                    hintStyle: TextStyle(
                      color: Colors.white,
                      fontFamily: "WorkSansLight",
                    ),
                    filled: true,
                    fillColor: Colors.white24,
                    hintText: 'Enter your name',
                  ),
                ),
                SizedBox(height: 20),
                RoundRectangleButton(
                  text: "Continue",
                  onPressed: () async {
                    if (_controller.text.isEmpty) {
                      if (await Vibration.hasVibrator()) {
                        Vibration.vibrate();
                      }
                      return;
                    }

                    stname = _controller.text;
                    preferences.setString("keyusername", _controller.text);

                    if (await Vibration.hasVibrator()) {
                      Vibration.vibrate();
                    } else {
                      stname = _controller.text;
                      preferences.setString(
                        "keyusername",
                        _controller.text.toString(),
                      );
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return GenreSelection();
                          },
                        ),
                        ModalRoute.withName('/ask'),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
