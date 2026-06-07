// ignore_for_file: prefer_interpolation_to_compose_strings, prefer_if_null_operators, unnecessary_null_comparison, unused_element, prefer_typing_uninitialized_variables, use_super_parameters, library_private_types_in_public_api
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:movie_app/Screens/DetailsPage/Components/DetailPageBody.dart';
import 'package:movie_app/Util/ApiService.dart';
import 'package:movie_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

List<String> movielist = [];

class FetchHorizontalMovieList extends StatefulWidget {
  final url;
  final id;
  final username;
  final recentname;
  const FetchHorizontalMovieList({
    Key? key,
    @required this.url,
    this.id,
    this.username,
    this.recentname,
  }) : super(key: key);

  @override
  _FetchHorizontalMovieListState createState() =>
      _FetchHorizontalMovieListState();
}

class _FetchHorizontalMovieListState extends State<FetchHorizontalMovieList> {
  List val = [];
  List watchlist = [];
  String? authToken;
  bool add = false;

  Future fetchMovieData() async {
    if (widget.id == null) return;
    final String url = "http://10.103.101.235:5000/watch/" + widget.id;
    try {
      var response = await Dio().get(url);
      return response.data['post'];
    } catch (e) {
      print(e);
    }
  }

  Future getresponse() async {
    var response = await Dio().get(widget.url);
    var data = response.data;
    try {
      if (widget.recentname != "") {
        if (mounted) {
          setState(() {
            val = data;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            val = data["results"];
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadAuthToken();
    _fetchMovies();
    this.getresponse();
    this.fetchMovieData().then(
      (value) => {
        if (mounted)
          {
            if (value == null || value.length == 0)
              {
                setState(() {
                  watchlist = value;
                }),
              }
            else
              {
                setState(() {
                  watchlist = value[0]['watchlist'];
                }),
              },
          },
      },
    );
  }

  Future<void> _loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      authToken = prefs.getString('auth_token');
    });
  }

  Future<void> _fetchMovies() async {
    try {
      final response = await http.get(Uri.parse(widget.url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            val = widget.recentname.isNotEmpty ? data : data["results"] ?? [];
          });
        }
      } else {
        print('Failed to fetch movies: ${response.body}');
      }
    } catch (e) {
      print('Error fetching movies: $e');
    }
  }

  // Hàm mới để thêm phim vào watchlist sử dụng ApiService
  Future<bool> _addToWatchlist(
    String movieId,
    String movieName,
    String posterPath,
  ) async {
    try {
      bool success = await ApiService.addToWatchlist(
        movieId,
        movieName,
        posterPath,
      );

      return success;
    } catch (e) {
      print('Error adding movie to watchlist: $e');
      return false;
    }
  }

  Future<void> _showMyDialog(
    String movieId,
    String movieName,
    String posterPath,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          content: SizedBox(
            height: 140,
            width: 140,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () async {
                      // Sử dụng ApiService để thêm phim vào watchlist
                      bool success = await _addToWatchlist(
                        movieId,
                        movieName,
                        posterPath,
                      );
                      if (success) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Container(
                              height: 25,
                              alignment: Alignment.center,
                              child: Text(
                                "ADDED TO WATCHLIST",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            action: SnackBarAction(
                              label: 'Cancel',
                              onPressed: () {},
                            ),
                          ),
                        );
                      } else {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Container(
                              height: 25,
                              alignment: Alignment.center,
                              child: Text(
                                "Failed to add to watchlist",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.playlist_add,
                            color: Colors.red,
                            size: 33,
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 5, left: 10),
                            padding: EdgeInsets.only(left: 5),
                            child: const Text(
                              "ADD TO WATCHLIST",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      // Sử dụng ApiService để lưu phim
                      bool success = await _addToWatchlist(
                        movieId,
                        movieName,
                        posterPath,
                      );
                      if (success) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Container(
                              height: 25,
                              alignment: Alignment.center,
                              child: Text(
                                "SAVED",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            action: SnackBarAction(
                              label: 'Cancel',
                              onPressed: () {},
                            ),
                          ),
                        );
                      } else {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Container(
                              height: 25,
                              alignment: Alignment.center,
                              child: Text(
                                "Failed to save movie",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.bookmark,
                            color: Colors.red,
                            size: 32,
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 5, left: 10),
                            padding: EdgeInsets.only(left: 5),
                            child: const Text(
                              "SAVE THIS MOVIE",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 5),
                    child: Divider(color: Colors.grey, thickness: 0.8),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      child: Text(
                        "CLOSE",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
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

  // Cập nhật cách storedata để ghi nhận phim đã xem gần đây, không phải để thêm vào watchlist
  void storedata(String name, String url, String id) async {
    // Lưu thông tin phim đã xem gần đây vào SharedPreferences
    // Vẫn giữ phương thức này để theo dõi lịch sử xem phim
    timages.add(url.toString());
    images = preferences.getStringList('posters') ?? [];
    if (!images.contains(url)) {
      images.add(url.toString());
      await preferences.setStringList("posters", images);
    }

    ttitles.add(name.toString());
    title = preferences.getStringList('movienames') ?? [];
    if (!title.contains(name)) {
      title.add(name.toString());
      await preferences.setStringList("movienames", title);
    }
  }

  List<String> movies = [];
  List<String> timages = [];
  List<String> ttitles = [];

  @override
  Widget build(BuildContext context) {
    if (val.isEmpty) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 10.0),
        height: 168.0,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 20,
          itemBuilder: (BuildContext context, int index) {
            return Shimmer.fromColors(
              period: const Duration(milliseconds: 2000),
              baseColor: HexColor("#8970A4"),
              direction: ShimmerDirection.ltr,
              highlightColor: HexColor("#463567"),
              child: Container(
                width: 118,
                margin: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: (Colors.purple[200])!,
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
            );
          },
        ),
      );
    } else {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 10.0),
        height: 168.0,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: val.length != null ? val.length : 0,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onLongPress: () {
                if (authToken != null) {
                  _showMyDialog(
                    val[index]["id"].toString(),
                    val[index]["original_title"].toString(),
                    "https://image.tmdb.org/t/p/w780" +
                        (val[index]["poster_path"] ?? ""),
                  );
                }
              },
              onTap: () {
                storedata(
                  val[index]["original_title"].toString(),
                  "https://image.tmdb.org/t/p/w780" +
                      (val[index]["poster_path"] ?? ""),
                  val[index]["id"].toString(),
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => DetailsPageBody(
                          moviename: val[index]["original_title"],
                        ),
                  ),
                );
              },
              child: Container(
                width: 118,
                margin: EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      height: 200,
                      width: 120,
                      child:
                          val[index]["poster_path"] == null
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: const Image(
                                  image: AssetImage(
                                    "assets/images/loading.png",
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              )
                              : ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: FadeInImage.assetNetwork(
                                  image:
                                      "https://image.tmdb.org/t/p/w780" +
                                      val[index]["poster_path"],
                                  placeholder: "assets/images/loading.png",
                                  fit: BoxFit.cover,
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
}
