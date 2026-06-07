// ignore_for_file: prefer_interpolation_to_compose_strings
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:sizer/sizer.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:vibration/vibration.dart';

import '../../Util/hidekeyboard.dart';
import '../../main.dart';
import 'Components/CustomAlert.dart';
import 'Model/data.dart';
import '../../../../CustomSnackbar/Snackbar.dart';
import '../../../../Util/GreenSnackbar.dart';
import '../../../../Util/ApiService.dart';

class SwipableCards extends StatefulWidget {
  const SwipableCards({Key? key}) : super(key: key);

  @override
  State<SwipableCards> createState() => _SwipableCardsState();
}

class _SwipableCardsState extends State<SwipableCards> {
  List val = [];

  Future getrandom() async {
    var response = await Dio().get("http://10.103.101.235:5000/getswipe");
    var data = response.data;
    try {
      if (mounted) {
        setState(() {
          val = data;
        });
        load();
        create_cards();
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getrandom();
  }

  List<SwipeItem> _swipeItems = <SwipeItem>[];
  MatchEngine? _matchEngine;
  List<String> names = [];
  List<String> releaseyear = [];
  List<String> images = [];
  List<String> ratings = [];
  List<String> ids = []; // Thêm danh sách để lưu ID phim

  void load() {
    for (var i = 0; i < val.length; i++) {
      names.add(val[i]["original_title"].toString());
      releaseyear.add(val[i]["release_date"].toString());
      images.add(val[i]["poster_path"].toString());
      ratings.add(val[i]["vote_average"].toString());
      ids.add(val[i]["id"].toString()); // Lấy ID từ dữ liệu
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

  void create_cards() {
    for (int i = 0; i < names.length; i++) {
      _swipeItems.add(
        SwipeItem(
          content: Content(
            title: names[i],
            rating: ratings[i],
            year: releaseyear[i],
            url: images[i],
          ),
          likeAction: () async {
            hideKeyboard(context);
            // Lưu vào danh sách recommended
            String posterPath =
                "https://image.tmdb.org/t/p/original" + images[i].toString();
            storedata(names[i].toString(), posterPath, ids[i].toString());

            // Lưu vào danh sách watched (MySQL)
            bool success = true;
            bool watchedResult =
                await ApiService.syncWatchedMovie(
                  ids[i].toString(),
                  names[i].toString(),
                  posterPath,
                ).catchError((e) {
                  print('Error adding to watched: $e');
                  return false;
                });
            if (!watchedResult) {
              success = false;
            }

            // Hiển thị thông báo
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.transparent,
                  elevation: 5,
                  content: GreenSnackbar(
                    title: "Movie added to your watchlist",
                    message: 'Enjoy your movie!',
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to add movie to watchlist'),
                  backgroundColor: HexColor("#FF4C4C"),
                ),
              );
            }

            // Gọi hàm thông báo hành động
            actions(context, names[i], 'Liked');
          },
          nopeAction: () {
            hideKeyboard(context);
            actions(context, names[i], 'Rejected');
          },
        ),
      );
    }
    _matchEngine = MatchEngine(swipeItems: _swipeItems);
  }

  Widget buttonWidget(IconData icon, Color color) {
    return Container(
      height: 6.h,
      width: 12.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [color.withOpacity(0.2), color.withOpacity(0.4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: HexColor("#121212"),
      body: SafeArea(
        child: Column(
          children: [
            AppBar(
              backgroundColor: HexColor("#272727"),
              title: Text(
                "Suggest a Movie",
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
            ),
            Expanded(
              child: val.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.w,
                        vertical: 2.h,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: SwipeCards(
                              matchEngine: _matchEngine!,
                              itemBuilder: (context, index) {
                                return Container(
                                  width: 90.w,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 0.5,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      colors: [
                                        HexColor("#272727"),
                                        HexColor("#121212"),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20),
                                        ),
                                        child: AspectRatio(
                                          aspectRatio: 16 / 9,
                                          child: FadeInImage.assetNetwork(
                                            image:
                                                "https://image.tmdb.org/t/p/original" +
                                                images[index].toString(),
                                            placeholder:
                                                "assets/images/loading.png",
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(2.w),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            TextScroll(
                                              names[index] == "NULL"
                                                  ? "N/A"
                                                  : names[index].toString(),
                                              velocity: Velocity(
                                                pixelsPerSecond: Offset(20, 0),
                                              ),
                                              pauseBetween: Duration(
                                                milliseconds: 1000,
                                              ),
                                              mode: TextScrollMode.bouncing,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontSize: 18.sp,
                                              ),
                                            ),
                                            SizedBox(height: 0.5.h),
                                            Text(
                                              releaseyear[index] == "NULL"
                                                  ? "Release Date: N/A"
                                                  : "Release Date: ${releaseyear[index]}",
                                              style: TextStyle(
                                                color: HexColor("#DEDEDE"),
                                                fontSize: 15.sp,
                                              ),
                                            ),
                                            SizedBox(height: 0.5.h),
                                            Text(
                                              ratings[index] == "NULL"
                                                  ? "⭐ N/A"
                                                  : "⭐ ${ratings[index]}",
                                              style: TextStyle(
                                                color: HexColor("#DEDEDE"),
                                                fontSize: 13.sp,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Spacer(),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Padding(
                                          padding: EdgeInsets.all(2.w),
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.pushNamed(
                                                context,
                                                '/details',
                                                arguments: {
                                                  'moviename': names[index],
                                                },
                                              );
                                            },
                                            child: Icon(
                                              Icons.play_circle_outline,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              onStackFinished: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('No more movies to swipe!'),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    _matchEngine!.currentItem!.nope();
                                    if (await Vibration.hasVibrator()) {
                                      Vibration.vibrate(duration: 50);
                                    }
                                  },
                                  child: buttonWidget(
                                    Icons.close,
                                    HexColor("#D442FF"),
                                  ),
                                ),
                                InkWell(
                                  onTap: () async {
                                    _matchEngine!.currentItem!.like();
                                    if (await Vibration.hasVibrator()) {
                                      Vibration.vibrate(duration: 50);
                                    }
                                  },
                                  child: buttonWidget(
                                    Icons.favorite_outline,
                                    HexColor("#D442FF"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 2.h),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
