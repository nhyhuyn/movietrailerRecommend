// ignore_for_file: use_super_parameters, prefer_const_constructors_in_immutables, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_social_button/flutter_social_button.dart';
import 'package:url_launcher/url_launcher.dart';

class Aboutme extends StatefulWidget {
  Aboutme({Key? key}) : super(key: key);
  @override
  _AboutmeState createState() => _AboutmeState();
}

class _AboutmeState extends State<Aboutme> {
  List about = [
    "",
    "Hi there! Teams here.",
    "I am a computer science engineering student  with a passion for building beautiful and functional applications.",
    "I have used Flask,Flutter,Dart, and Python to build this app.",
    "I made a Movie Recommendation API using Flask which is  used  int MovieApp to recommend movies.",
    "Sentiment Analysis is used to analyse the sentiment of the movie reviews.",
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          "About Me",
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 1.h, left: 2.w, right: 2.w),
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 25.h,
                width: 40.w,
                child: Image.asset("assets/images/logo.png"),
              ),
              Text(
                "Movie App",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                about[0],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                about[1],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                about[2],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                about[3],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                about[4],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                about[5],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                "For any further queries contact me through:",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: 40.w, // <-- Button Width
                    height: 5.h, // <-- Button height
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HexColor("#202020"),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // <-- Radius
                        ),
                      ),
                      onPressed: () async {
                        String url = "https://github.com/DangDiem45";
                        if (await canLaunch(url)) {
                          await launch(url, forceSafariVC: false);
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                      icon: FaIcon(
                        FontAwesomeIcons.github,
                        color: Colors.white,
                      ),
                      label: Text(
                        "GitHub",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
