// ignore_for_file: unnecessary_this, prefer_interpolation_to_compose_strings, avoid_unnecessary_containers, library_private_types_in_public_api, use_super_parameters, prefer_typing_uninitialized_variables, unused_import

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/Screens/DetailsPage/Components/DetailPageBody.dart';
import 'package:vibration/vibration.dart'; // Đã thay thế flutter_vibrate
import 'package:hexcolor/hexcolor.dart';
import 'package:lottie/lottie.dart';

class Castdetails extends StatefulWidget {
  final castname;
  final profilepath;
  final castid;

  const Castdetails({
    Key? key,
    @required this.castname,
    this.castid,
    this.profilepath,
  }) : super(key: key);

  @override
  _CastdetailsState createState() => _CastdetailsState();
}

class _CastdetailsState extends State<Castdetails> {
  List popularlist = [];

  void getpopularresponse() async {
    var response = await Dio().get(
      "https://api.themoviedb.org/3/discover/movie?api_key=dbda4bb34573ea2b68379f1e476c3933&with_cast=" +
          widget.castid.toString() +
          "&sort_by=vote_average.desc",
    );

    var data = response.data;
    try {
      if (mounted) {
        setState(() {
          popularlist = data["results"];
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    this.getpopularresponse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor("#121212"),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Cast Details",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                offset: Offset(1, 1),
                blurRadius: 5,
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            SizedBox(height: 20),
            _buildMoviesHeader(),
            SizedBox(height: 10),
            getmovieslist(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      height: 350,
      child: Stack(
        children: [
          // Background gradient
          Container(
            height: 280,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [HexColor("#7220C9"), HexColor("#121212")],
              ),
            ),
          ),
          // Profile content
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Profile image
                  Container(
                    height: 230,
                    width: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.7),
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child:
                          widget.profilepath == null
                              ? Image(
                                fit: BoxFit.cover,
                                image: AssetImage("assets/images/loading.png"),
                              )
                              : CachedNetworkImage(
                                imageUrl:
                                    "https://image.tmdb.org/t/p/w780" +
                                    widget.profilepath,
                                fit: BoxFit.cover,
                                placeholder:
                                    (context, url) => Container(
                                      color: HexColor("#222222"),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: HexColor("#7220C9"),
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                errorWidget:
                                    (context, url, error) => Image(
                                      fit: BoxFit.cover,
                                      image: AssetImage(
                                        "assets/images/loading.png",
                                      ),
                                    ),
                              ),
                    ),
                  ),
                  // Name and info
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(left: 25, bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            widget.castname,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.7),
                                  offset: Offset(1, 1),
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 12),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: HexColor("#7220C9").withOpacity(0.7),
                            ),
                            child: Text(
                              "Actor",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoviesHeader() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: HexColor("#7220C9"),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 8),
          Text(
            "Films starring " + widget.castname.split(' ')[0],
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget getlottie() {
    return Container(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              "assets/images/loading_movie.json",
              height: 150,
              width: 150,
            ),
            SizedBox(height: 10),
            Text(
              "Loading films...",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget getmovieslist() {
    if (popularlist.isEmpty) return getlottie();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: (115.0 / 190.0),
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
        ),
        shrinkWrap: true,
        itemCount: popularlist.length,
        controller: ScrollController(keepScrollOffset: false),
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () async {
              if (await Vibration.hasVibrator()) {
                Vibration.vibrate(duration: 50);
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => DetailsPageBody(
                        moviename: popularlist[index]["original_title"],
                      ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Movie poster
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child:
                        popularlist[index]["poster_path"] == null
                            ? Image(
                              fit: BoxFit.cover,
                              height: double.infinity,
                              width: double.infinity,
                              image: AssetImage("assets/images/loading.png"),
                            )
                            : CachedNetworkImage(
                              imageUrl:
                                  "https://image.tmdb.org/t/p/w780" +
                                  popularlist[index]['poster_path'],
                              fit: BoxFit.cover,
                              height: double.infinity,
                              width: double.infinity,
                              placeholder:
                                  (context, url) => Container(
                                    color: HexColor("#222222"),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: HexColor("#7220C9"),
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                              errorWidget:
                                  (context, url, error) => Image(
                                    fit: BoxFit.cover,
                                    image: AssetImage(
                                      "assets/images/loading.png",
                                    ),
                                  ),
                            ),
                  ),
                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 60,
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
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Rating indicator
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 12),
                          SizedBox(width: 2),
                          Text(
                            popularlist[index]["vote_average"].toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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
