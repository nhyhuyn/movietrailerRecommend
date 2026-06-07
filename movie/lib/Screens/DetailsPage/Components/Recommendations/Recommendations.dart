// ignore_for_file: unnecessary_const, unused_import, prefer_typing_uninitialized_variables, non_constant_identifier_names, use_super_parameters, library_private_types_in_public_api, unused_element

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:lottie/lottie.dart';
import 'package:movie_app/Screens/DetailsPage/Components/DetailPageBody.dart';
import 'package:movie_app/Util/ApiService.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import 'package:vibration/vibration.dart';
import '../../../../CustomSnackbar/Snackbar.dart';
import '../../../../Util/GreenSnackbar.dart';
import '../../../../main.dart';

class Recommendations extends StatefulWidget {
  final id;
  final movie_name;

  const Recommendations({Key? key, @required this.id, this.movie_name})
    : super(key: key);

  @override
  _RecommendationsState createState() => _RecommendationsState();
}

class _RecommendationsState extends State<Recommendations>
    with SingleTickerProviderStateMixin {
  List popularlist = [];
  List recommend = [];
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    contentbasedrecommendations();
    apibased();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _showMyDialog(movieid, moviename, posterpath) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: HexColor("#1A1A1A"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          content: Container(
            height: 160,
            width: 140,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 6,
                      ),
                      decoration: BoxDecoration(
                        color: HexColor("#2A2A2A"),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            color: HexColor("#FF3D71"),
                            size: 30,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "ADD TO WATCHLIST",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 15),
                    child: Divider(
                      color: Colors.grey.withOpacity(0.3),
                      thickness: 1,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 30,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: HexColor("#3366FF"),
                          width: 2,
                        ),
                      ),
                      child: Text(
                        "CLOSE",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: HexColor("#3366FF"),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void contentbasedrecommendations() async {
    try {
      var response = await Dio().get(
        "http://10.103.101.235:5000/send/" + widget.movie_name.toString(),
      );
      var data = response.data;
      if (mounted) {
        setState(() {
          if (mounted) {
            popularlist = data;
          }
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void apibased() async {
    try {
      var response = await Dio().get(
        "https://api.themoviedb.org/3/movie/" +
            widget.id.toString() +
            "/recommendations?api_key=dbda4bb34573ea2b68379f1e476c3933&language=en-US&page=1",
      );

      var data = response.data;
      if (mounted) {
        setState(() {
          recommend = data['results'];
        });
      }
    } catch (e) {
      print(e);
    }
  }

  List<String> movieimages = [];
  List<String> movietitles = [];

  void storedata(String name, String url, String id) async {
    movieimages.add(url.toString());
    recommemdedmovieimages =
        preferences.getStringList('recommemdedmovieimages') ?? [];
    for (int i = 0; i < recommemdedmovieimages.length; i++) {
      if (recommemdedmovieimages[i] == url) {
        return;
      }
    }
    recommemdedmovieimages.add(url.toString());
    recommemdedmovieimages.toSet().toList();
    preferences.setStringList("recommemdedmovieimages", recommemdedmovieimages);

    movietitles.add(name.toString());
    recommemdedmovienames =
        preferences.getStringList('recommemdedmovietitles') ?? [];
    for (int i = 0; i < recommemdedmovienames.length; i++) {
      if (recommemdedmovienames[i] == name) {
        return;
      }
    }
    recommemdedmovienames.add(name.toString());
    recommemdedmovienames.toSet().toList();
    preferences.setStringList("recommemdedmovietitles", recommemdedmovienames);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [HexColor("#121212"), HexColor("#1D1D1D")],
        ),
      ),
      height: double.infinity,
      width: double.infinity,
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildSectionHeader(
              "ML-Based Recommendations",
              "Personalized for you",
            ),
            SizedBox(height: 1.h),
            recommend.isNotEmpty
                ? _buildLikeRecommendationsButton()
                : SizedBox(),
            recommend.isNotEmpty ? _buildRecommendationsSection() : SizedBox(),
            _buildSectionHeader(
              "More Like This",
              "Similar content you might enjoy",
            ),
            SizedBox(height: 1.h),
            getallpopularmoviecard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Container(
      margin: EdgeInsets.only(top: 2.h, left: 4.w, right: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 24,
                width: 5,
                decoration: BoxDecoration(
                  color: HexColor("#7220C9"),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(left: 15),
            child: Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLikeRecommendationsButton() {
    return SlideTransition(
      position: Tween<Offset>(begin: Offset(0, 0.5), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOutQuart,
        ),
      ),
      child: FadeTransition(
        opacity: _animationController,
        child: InkWell(
          onTap: () async {
            if (await Vibration.hasVibrator()) {
              Vibration.vibrate(duration: 50);
            }

            bool success = true;

            // Process the first two recommended movies
            // for (int i = 0; i < 2 && i < recommend.length; i++) {
            //   String movieId = recommend[i]["id"].toString();
            //   String movieTitle = recommend[i]["original_title"].toString();
            //   String posterPath =
            //       recommend[i]["poster_path"] != null
            //           ? "https://image.tmdb.org/t/p/w780${recommend[i]["poster_path"]}"
            //           : '';

            //   // 1. Save to watched list (MySQL)
            //   bool watchedResult = await ApiService.syncWatchedMovie(
            //     movieId,
            //     movieTitle,
            //     posterPath,
            //   );
            //   if (!watchedResult) {
            //     success = false;
            //   }
            // }

            String posterPath = '';
            // Try to get poster path from TMDB API or another source
            try {
              var response = await Dio().get(
                "https://api.themoviedb.org/3/movie/${widget.id}?api_key=dbda4bb34573ea2b68379f1e476c3933&language=en-US",
              );
              if (response.statusCode == 200) {
                posterPath = response.data['poster_path'] != null
                    ? "https://image.tmdb.org/t/p/w780${response.data['poster_path']}"
                    : '';
              }
            } catch (e) {
              print('Error fetching movie details: $e');
            }

            bool watchedResult =
                await ApiService.syncWatchedMovie(
                  widget.id.toString(),
                  widget.movie_name.toString(),
                  posterPath,
                ).catchError((e) {
                  print('Error adding to watched: $e');
                  return false;
                });
            if (!watchedResult) {
              success = false;
            }
            storedata(
              recommend[0]["original_title"].toString(),
              "https://image.tmdb.org/t/p/w780" +
                  recommend[0]["poster_path"].toString(),
              recommend[0]["id"].toString(),
            );
            storedata(
              recommend[1]["original_title"].toString(),
              "https://image.tmdb.org/t/p/w780" +
                  recommend[1]["poster_path"].toString(),
              recommend[1]["id"].toString(),
            );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.transparent,
                elevation: 5,
                content: GreenSnackbar(
                  title: "Recommendations added to your watchlist",
                  message: 'Enjoy your movies!',
                ),
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [HexColor("#7220C9"), HexColor("#5C1DAE")],
              ),
              boxShadow: [
                BoxShadow(
                  color: HexColor("#7220C9").withOpacity(0.3),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cake_outlined, size: 24, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  "Like these recommendations?",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(opacity: _animationController.value, child: child);
      },
      child: getallpopularmoviecards(),
    );
  }

  Widget getlottie() {
    return Center(
      child: Container(
        height: 30.h,
        width: 80.w,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset("assets/images/analysing.json", height: 20.h),
            SizedBox(height: 10),
            Text(
              "Finding perfect movies for you...",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getallpopularmoviecard() {
    if (popularlist.isEmpty) {
      return getlottie();
    } else {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        margin: const EdgeInsets.only(top: 10),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: (130.0 / 190.0),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          shrinkWrap: true,
          itemCount: popularlist.isNotEmpty ? popularlist.length : 0,
          controller: ScrollController(keepScrollOffset: false),
          itemBuilder: (BuildContext context, int index) {
            return _buildMovieCard(
              popularlist[index],
              index,
              onTap: () async {
                if (await Vibration.hasVibrator()) {
                  Vibration.vibrate(duration: 50);
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DetailsPageBody(moviename: popularlist[index]["title"]),
                  ),
                );
              },
            );
          },
        ),
      );
    }
  }

  Widget getallpopularmoviecards() {
    if (recommend.isEmpty) {
      return getlottie();
    } else {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        margin: const EdgeInsets.only(top: 0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: (130.0 / 190.0),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          shrinkWrap: true,
          itemCount: recommend.isNotEmpty ? recommend.length : 0,
          controller: ScrollController(keepScrollOffset: false),
          itemBuilder: (BuildContext context, int index) {
            return _buildMovieCard(
              recommend[index],
              index,
              onTap: () async {
                if (await Vibration.hasVibrator()) {
                  Vibration.vibrate(duration: 50);
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DetailsPageBody(moviename: recommend[index]["title"]),
                  ),
                );
              },
            );
          },
        ),
      );
    }
  }

  Widget _buildMovieCard(dynamic movie, int index, {required Function onTap}) {
    return Hero(
      tag: "movie_${movie["id"]}_$index",
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Movie poster
            GestureDetector(
              onTap: () => onTap(),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: HexColor("#232323"), width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: movie["poster_path"] == null
                      ? Image(
                          fit: BoxFit.cover,
                          height: double.infinity,
                          width: double.infinity,
                          image: AssetImage('assets/images/loading.png'),
                        )
                      : FadeInImage.assetNetwork(
                          image:
                              "https://image.tmdb.org/t/p/w780" +
                              movie["poster_path"],
                          placeholder: "assets/images/loading.png",
                          fit: BoxFit.cover,
                          height: double.infinity,
                          width: double.infinity,
                        ),
                ),
              ),
            ),

            // Rating overlay
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 14),
                    SizedBox(width: 2),
                    Text(
                      movie["vote_average"]?.toStringAsFixed(1) ?? "N/A",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Options menu
            Positioned(
              top: 6,
              right: 6,
              child: InkWell(
                onTap: () {
                  _showMyDialog(
                    movie["id"],
                    movie["title"] ?? movie["original_title"],
                    movie["poster_path"],
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.more_horiz, color: Colors.white, size: 18),
                ),
              ),
            ),

            // Title overlay at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.9),
                      Colors.black.withOpacity(0.0),
                    ],
                  ),
                ),
                child: Text(
                  movie["title"] ?? movie["original_title"] ?? "Unknown",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
