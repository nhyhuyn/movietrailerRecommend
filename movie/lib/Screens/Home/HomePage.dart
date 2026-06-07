import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:movie_app/Screens/Home/components/CollaborativeHomepage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor("#121212"),
      resizeToAvoidBottomInset: false,
      //body: HomepageBody(),
      body: CollaborativeHomePage(),
    );
  }
}
