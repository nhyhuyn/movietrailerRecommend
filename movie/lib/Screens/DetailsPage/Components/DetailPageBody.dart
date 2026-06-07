// ignore_for_file: prefer_interpolation_to_compose_strings, deprecated_member_use, avoid_unnecessary_containers, sized_box_for_whitespace, unnecessary_null_comparison, unused_import

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:movie_app/Screens/DetailsPage/Components/About/About.dart';
import 'package:movie_app/Screens/DetailsPage/Components/Cast/Cast.dart';
import 'package:movie_app/Screens/DetailsPage/Components/Recommendations/Recommendations.dart';
import 'package:movie_app/Screens/DetailsPage/Components/Reviews/Reviews.dart';
import 'package:movie_app/Screens/DetailsPage/Components/SeatBooking/Booking.dart';
import 'package:movie_app/Screens/DetailsPage/ErrorPage/Error.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../main.dart';

class DetailsPageBody extends StatefulWidget {
  final String? moviename;

  const DetailsPageBody({Key? key, this.moviename}) : super(key: key);

  @override
  _DetailsPageBodyState createState() => _DetailsPageBodyState();
}

class _DetailsPageBodyState extends State<DetailsPageBody> {
  List moviedetails = [];

  void _showTrailer() {
    if (moviedetails[1]["results"].isNotEmpty &&
        moviedetails[1]["results"][0]["key"] != null) {
      String videoId = moviedetails[1]["results"][0]["key"];
      _showVideoDialog(videoId);
    } else {
      _showSnackBar("Trailer not found");
    }
  }

  void _showVideoDialog(String videoId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        YoutubePlayerController controller = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
        );

        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(10),
          child: Container(
            width: double.infinity,
            height: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: YoutubePlayer(
                    controller: controller,
                    showVideoProgressIndicator: true,
                    progressIndicatorColor: HexColor("#7220C9"),
                    progressColors: ProgressBarColors(
                      playedColor: HexColor("#7220C9"),
                      handleColor: HexColor("#7220C9"),
                    ),
                    onReady: () {
                      controller.addListener(() {});
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> getpopularresponse() async {
    if (widget.moviename == null || widget.moviename!.isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ErrorPage()),
      );
    }
    try {
      var response = await Dio().get(
        "http://10.103.101.235:5000/getmovie/${widget.moviename}",
      );
      var data = response.data;
      if (mounted) {
        setState(() {
          moviedetails = data;
        });
      }
    } catch (e) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ErrorPage()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getpopularresponse();
  }

  Future<bool> _willPopCallback() async {
    Navigator.pop(context);
    remembermovies = preferences.getStringList('savedmoviehistory') ?? [];
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _willPopCallback,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: DefaultTabController(
          length: 5,
          child: moviedetails.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : NestedScrollView(
                  headerSliverBuilder: (context, _) {
                    return [
                      SliverAppBar(
                        backgroundColor: Colors.black,
                        expandedHeight: 380,
                        pinned: true,
                        bottom: TabBar(
                          isScrollable: true,
                          indicatorWeight: 3,
                          indicator: UnderlineTabIndicator(
                            borderSide: BorderSide(
                              color: HexColor("#7220C9"),
                              width: 3.0,
                            ),
                          ),
                          unselectedLabelColor: Colors.white,
                          labelColor: HexColor("#7220C9"),
                          tabs: const [
                            Tab(
                              child: Text(
                                "About",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            Tab(
                              child: Text(
                                "Cast",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            Tab(
                              child: Text(
                                "Recommends",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            Tab(
                              child: Text(
                                "Reviews",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            Tab(
                              child: Text(
                                "Booking Seat",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                        flexibleSpace: FlexibleSpaceBar(
                          background: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              moviedetails[0]['backdrop_path'] == null
                                  ? SizedBox(
                                      width: double.infinity,
                                      height: 230,
                                      child: const Image(
                                        fit: BoxFit.cover,
                                        image: AssetImage(
                                          "assets/images/loading.png",
                                        ),
                                      ),
                                    )
                                  : ShaderMask(
                                      shaderCallback: (rect) {
                                        return const LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.black,
                                            Colors.transparent,
                                          ],
                                        ).createShader(
                                          Rect.fromLTRB(
                                            0,
                                            30,
                                            rect.width,
                                            rect.height,
                                          ),
                                        );
                                      },
                                      blendMode: BlendMode.dstIn,
                                      child: FadeInImage.assetNetwork(
                                        image:
                                            "https://image.tmdb.org/t/p/original${moviedetails[0]['backdrop_path']}",
                                        height: 230,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        placeholder:
                                            'assets/images/loading.png',
                                      ),
                                    ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.moviename!,
                                        maxLines: 2,
                                        style: TextStyle(
                                          fontSize: 23,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.none,
                                          color: HexColor("#7220C9"),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          moviedetails[0]['vote_average']
                                              .toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Center(
                                child: ElevatedButton.icon(
                                  onPressed: _showTrailer,
                                  icon: const Icon(
                                    Icons.play_circle_fill,
                                    size: 22,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    "Watch",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueGrey,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        actions: const [
                          Icon(Icons.more_vert),
                          SizedBox(width: 12),
                        ],
                      ),
                    ];
                  },
                  body: TabBarView(
                    children: [
                      About(
                        production_companies:
                            moviedetails[0]["production_companies"],
                        overview: moviedetails[0]['overview'],
                        moviename: moviedetails[0]['original_title'],
                        id: moviedetails[0]['id'],
                      ),
                      Cast(id: moviedetails[0]['id']),
                      Recommendations(
                        id: moviedetails[0]['id'],
                        movie_name: widget.moviename!,
                      ),
                      Reviews(
                        id: moviedetails[0]['id'],
                        moviename: widget.moviename!,
                      ),
                      BookingScreen(
                        id: moviedetails[0]['id'],
                        moviename: widget.moviename!,
                        posterPath: moviedetails[0]['poster_path'],
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
