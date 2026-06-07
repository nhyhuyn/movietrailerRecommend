import 'package:flutter/material.dart';
import 'package:movie_app/Screens/Search/Component/SearchPageBody.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SearchPageBody(),
      resizeToAvoidBottomInset: false,
    );
  }
}
