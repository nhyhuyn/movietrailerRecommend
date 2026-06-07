// ignore_for_file: use_build_context_synchronously, curly_braces_in_flow_control_structures, avoid_unnecessary_containers, use_super_parameters, missing_required_param, non_constant_identifier_names, override_on_non_overriding_member

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:movie_app/Screens/GenreList/GenreWiseMovies.dart';
import 'package:movie_app/Screens/Search/Component/SearchQuerys.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vibration/vibration.dart';

class SearchPageBody extends StatefulWidget {
  const SearchPageBody({Key? key}) : super(key: key);

  @override
  State<SearchPageBody> createState() => _SearchPageBodyState();
}

class _SearchPageBodyState extends State<SearchPageBody> {
  @override
  List movie_data = [
    {"name": "top", "color": Colors.red, "image": "assets/images/action.jpg"},
    {
      "name": "Bollywood",
      "color": Colors.blue,
      "image": "assets/images/adventu.jpg",
    },
    {
      "name": "Folk",
      "color": Colors.green,
      "image": "assets/images/animation.jpg",
    },
    {
      "name": "Hip Hop",
      "color": Colors.yellow,
      "image": "assets/images/comedy.jpg",
    },
    {"name": "top", "color": Colors.pink, "image": "assets/images/crime.jpg"},
    {
      "name": "Bollywood",
      "color": Colors.pinkAccent,
      "image": "assets/images/doc.jpg",
    },
    {"name": "Folk", "color": Colors.indigo, "image": "assets/images/dram.jpg"},
    {
      "name": "Hip Hop",
      "color": Colors.deepOrangeAccent,
      "image": "assets/images/family.jpg",
    },
    {
      "name": "Hip Hop",
      "color": Colors.purple,
      "image": "assets/images/fantasy.jpg",
    },
    {
      "name": "top",
      "color": Colors.lightGreenAccent,
      "image": "assets/images/history.jpg",
    },
    {
      "name": "Bollywood",
      "color": Colors.blueGrey,
      "image": "assets/images/horror.jpg",
    },
    {
      "name": "Folk",
      "color": Colors.green[200],
      "image": "assets/images/music.jpg",
    },
    {
      "name": "Hip Hop",
      "color": Colors.tealAccent,
      "image": "assets/images/mystery.jpg",
    },
    {
      "name": "top",
      "color": Colors.deepPurpleAccent,
      "image": "assets/images/romance.jpg",
    },
  ];

  List val = [];

  Future fetchresponse() async {
    var response = await Dio().get(
      "https://api.themoviedb.org/3/genre/movie/list?api_key=dbda4bb34573ea2b68379f1e476c3933&language=en-US",
    );
    var data = response.data;
    try {
      if (mounted) {
        setState(() {
          val = data["genres"];
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchresponse();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 30),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            getappbar(),
            searchbar(),
            gettopgeneres(),
            //gettopgeneresname(),
          ],
        ),
      ),
    );
  }

  Widget getappbar() {
    return Container(
      margin: EdgeInsets.all(12.0),
      child: Column(
        children: [
          Text(
            "Search Movies",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 25.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget searchbar() {
    return Container(
      margin: EdgeInsets.all(10.0),
      padding: EdgeInsets.all(8.0),
      height: 50,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: TextField(
        onTap: () async {
          if (await Vibration.hasVibrator()) {
            Vibration.vibrate(duration: 50); // Rung nhẹ khi chọn
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SearchQuery()),
          );
        },
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Search',
          suffixIcon: Icon(Icons.search, color: HexColor("#7220C9")),
        ),
      ),
    );
  }

  Widget gettopgeneres() {
    if (val.isEmpty)
      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: (140.0 / 70.0),
        ),
        shrinkWrap: true,
        itemCount: 6, // số lượng shimmer box khi loading
        controller: ScrollController(keepScrollOffset: false),
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[800]!,
            highlightColor: Colors.grey[600]!,
            child: Container(
              margin: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Container(
                      height: double.infinity,
                      width: double.infinity,
                      color: Colors.grey[700],
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 100,
                      height: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    else
      return Container(
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: (140.0 / 70.0),
          ),
          shrinkWrap: true,
          itemCount: 14,
          controller: ScrollController(keepScrollOffset: false),
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () async {
                if (await Vibration.hasVibrator()) {
                  Vibration.vibrate(duration: 50); // Rung nhẹ khi chọn
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => GenreWiseMovies(
                          genre: val[index]["name"],
                          id: val[index]["id"],
                        ),
                  ),
                );
              },
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(3.0),
                margin: EdgeInsets.all(3.3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image(
                          color: Color.fromRGBO(255, 255, 255, 0.6),
                          colorBlendMode: BlendMode.modulate,
                          fit: BoxFit.cover,
                          image: AssetImage(movie_data[index]["image"]),
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                        val[index]["name"],
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.grey[300],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
  }
}
