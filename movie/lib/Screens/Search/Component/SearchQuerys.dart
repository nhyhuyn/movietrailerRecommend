// ignore_for_file: prefer_interpolation_to_compose_strings, deprecated_member_use, curly_braces_in_flow_control_structures, sort_child_properties_last, unnecessary_null_comparison, unused_import

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:movie_app/Screens/DetailsPage/Components/DetailPageBody.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:vibration/vibration.dart';

import '../../../main.dart';
import '../../CustomListFromUserHistory/Model/History.dart';

class SearchQuery extends StatefulWidget {
  final userid;
  SearchQuery({Key? key, @required this.userid}) : super(key: key);

  @override
  _SearchQueryState createState() => _SearchQueryState();
}

class _SearchQueryState extends State<SearchQuery> {
  List search_result = [];
  String query = "";
  bool isLoading = false;
  Timer? _debounceTimer;

  Future<dynamic> getresponse() async {
    try {
      if (query == "") {
        return null;
      } else {
        setState(() {
          isLoading = true;
        });
        var response = await Dio().get(
          "http://api.themoviedb.org/3/search/movie?api_key=dbda4bb34573ea2b68379f1e476c3933&language=en-US&page=1&include_adult=false&query=" +
              query,
        );
        setState(() {
          isLoading = false;
        });
        return response.data;
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
      _showErrorSnackBar("Network error. Please try again.");
      return null;
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _debounceSearch(String text) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        var value = await getresponse();
        if (mounted && value != null) {
          setState(() {
            search_result = value["results"];
          });
        }
      } catch (e) {
        print(e);
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _willPopCallback,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.black,
          title: Container(
            height: 45,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: HexColor("#272727"),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              autofocus: true,
              cursorColor: HexColor("#7220C9"),
              onChanged: (text) {
                setState(() {
                  query = text;
                });
                _debounceSearch(text);
              },
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: HexColor("#7220C9")),
                suffixIcon:
                    query.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            setState(() {
                              query = "";
                              search_result = [];
                            });
                          },
                        )
                        : null,
                filled: true,
                fillColor: HexColor("#272727"),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                hintStyle: TextStyle(color: Colors.grey.shade400),
                hintText: 'Search for movies, actors or genres',
              ),
            ),
          ),
          leading: InkWell(
            onTap: () async {
              if (await Vibration.hasVibrator()) {
                Vibration.vibrate(duration: 50);
              }
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 25),
          ),
        ),
        body: buildSearchResults(),
      ),
    );
  }

  Future<bool> _willPopCallback() async {
    if (search_result.isNotEmpty && search_result[0]["poster_path"] != null) {
      storedata(
        search_result[0]["original_title"].toString(),
        "https://image.tmdb.org/t/p/w780" +
            search_result[0]["poster_path"].toString(),
        search_result[0]["original_title"].toString(),
      );
    }
    searchdata = preferences.getStringList('searchdatas') ?? [];
    return true;
  }

  List<String> movies = [];
  void storedata(String name, String url, String id) async {
    User user = User(name, url, id);
    String userdata = jsonEncode(user);

    movies.add(userdata);
    searchdata = preferences.getStringList('searchdatas') ?? [];
    if (!searchdata.contains(userdata)) {
      searchdata.add(userdata);
      preferences.setStringList("searchdatas", searchdata.toSet().toList());
    }
  }

  Widget buildSearchResults() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7220C9)),
        ),
      );
    }

    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.movie_outlined, size: 70, color: HexColor("#7220C9")),
            const SizedBox(height: 20),
            const Text(
              "Find your favorite movies",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Start typing to discover amazing films",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (search_result.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 60, color: Colors.grey.shade700),
            const SizedBox(height: 20),
            Text(
              "No results found for \"$query\"",
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              "Try different keywords or check spelling",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      itemCount: search_result.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () async {
            if (await Vibration.hasVibrator()) {
              Vibration.vibrate(duration: 50);
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => DetailsPageBody(
                      moviename: search_result[index]["original_title"],
                    ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: HexColor("#1A1A1A"),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Movie Poster
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        height: 150,
                        width: 100,
                        child:
                            search_result[index]["poster_path"] == null
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    'assets/images/loading.png',
                                    fit: BoxFit.cover,
                                  ),
                                )
                                : Hero(
                                  tag: 'movie_${search_result[index]["id"]}',
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: FadeInImage.assetNetwork(
                                      image:
                                          "https://image.tmdb.org/t/p/w780" +
                                          search_result[index]["poster_path"],
                                      placeholder: "assets/images/loading.png",
                                      fit: BoxFit.cover,
                                      imageErrorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Image.asset(
                                          'assets/images/loading.png',
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                      ),
                      const SizedBox(width: 15),
                      // Movie Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 60.w,
                              child:
                                  search_result[index]['original_title']
                                          .toString()
                                          .isEmpty
                                      ? const Text(
                                        "Unknown Title",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                      : TextScroll(
                                        search_result[index]['original_title'],
                                        velocity: const Velocity(
                                          pixelsPerSecond: Offset(50, 0),
                                        ),
                                        pauseBetween: const Duration(
                                          milliseconds: 1000,
                                        ),
                                        mode: TextScrollMode.bouncing,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        selectable: false,
                                      ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  "${search_result[index]['vote_average']}",
                                  style: const TextStyle(
                                    color: Colors.amber,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Icon(
                                  Icons.calendar_today,
                                  color: Colors.grey.shade400,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  search_result[index]['release_date'] !=
                                              null &&
                                          search_result[index]['release_date']
                                              .toString()
                                              .isNotEmpty
                                      ? search_result[index]['release_date']
                                          .toString()
                                          .substring(0, 4)
                                      : "N/A",
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: 60.w,
                              child: Text(
                                search_result[index]['overview'] ??
                                    "No description available.",
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey.shade300,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
