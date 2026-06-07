// ignore_for_file: use_super_parameters, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:movie_app/Screens/MoreMoviesPage/Components/MoreMoviesPageBody.dart';

class MoreMoviesPage extends StatelessWidget {
  final originalmoviename;
  final url;
  const MoreMoviesPage({
    Key? key,
    required this.originalmoviename,
    required this.url,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor("#121212"),
      appBar: AppBar(
        backgroundColor: HexColor("#272727"),
        title: Text(
          this.originalmoviename,
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
        ),
        elevation: 4.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListMovies(originalmoviename: originalmoviename, url: url),
    );
  }
}
