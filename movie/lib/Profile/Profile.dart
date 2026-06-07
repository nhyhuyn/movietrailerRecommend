// ignore_for_file: sort_child_properties_last

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:movie_app/AskName/AskName.dart';
import 'package:movie_app/OnboardingPage/LanguageSelection/component/LanguageChips.dart';
import 'package:movie_app/OnboardingPage/GenereSelection/Component/GenreChips.dart';
import 'package:movie_app/Screens/DetailsPage/Components/DetailPageBody.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import 'package:text_scroll/text_scroll.dart';
import '../main.dart';
import 'CircleHolder.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

Widget sectionTitle(String title) {
  return Padding(
    padding: EdgeInsets.only(left: 2.w, bottom: 1.h),
    child: Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: HexColor("#7220C9"),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

Widget dynamicChips() {
  return persistedGenres.isNotEmpty
      ? Padding(
        padding: EdgeInsets.only(top: 1.h, right: 2.w, left: 2.w),
        child: Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: List<Widget>.generate(persistedGenres.length, (int index) {
            return Chip(
              label: Text(
                persistedGenres[index],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              avatar: CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Icon(Icons.movie, color: Colors.white, size: 16),
              ),
              labelPadding: EdgeInsets.symmetric(horizontal: 4.0),
              backgroundColor: HexColor("#7220C9"),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 3,
              shadowColor: Colors.black.withOpacity(0.3),
            );
          }),
        ),
      )
      : FilterChipDisplay.filters.isNotEmpty
      ? Padding(
        padding: EdgeInsets.only(top: 1.h, right: 2.w, left: 2.w),
        child: Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: List<Widget>.generate(FilterChipDisplay.filters.length, (
            int index,
          ) {
            return Chip(
              label: Text(
                FilterChipDisplay.filters[index],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              avatar: CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Icon(Icons.movie, color: Colors.white, size: 16),
              ),
              labelPadding: EdgeInsets.symmetric(horizontal: 4.0),
              backgroundColor: HexColor("#7220C9"),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 3,
              shadowColor: Colors.black.withOpacity(0.3),
            );
          }),
        ),
      )
      : Container();
}

Widget dynamicChips2() {
  return persistedLanguages.isNotEmpty
      ? Padding(
        padding: EdgeInsets.only(top: 1.h, right: 2.w, left: 2.w),
        child: Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: List<Widget>.generate(persistedLanguages.length, (
            int index,
          ) {
            return Chip(
              label: Text(
                persistedLanguages[index],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              avatar: CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Icon(Icons.language, color: Colors.white, size: 16),
              ),
              labelPadding: EdgeInsets.symmetric(horizontal: 4.0),
              backgroundColor: HexColor("#7220C9").withOpacity(0.8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 3,
              shadowColor: Colors.black.withOpacity(0.3),
            );
          }),
        ),
      )
      : LanguageChips.languages.isNotEmpty
      ? Padding(
        padding: EdgeInsets.only(top: 1.h, right: 2.w, left: 2.w),
        child: Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: List<Widget>.generate(LanguageChips.languages.length, (
            int index,
          ) {
            return Chip(
              label: Text(
                LanguageChips.languages[index],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              avatar: CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Icon(Icons.language, color: Colors.white, size: 16),
              ),
              labelPadding: EdgeInsets.symmetric(horizontal: 4.0),
              backgroundColor: HexColor("#7220C9").withOpacity(0.8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 3,
              shadowColor: Colors.black.withOpacity(0.3),
            );
          }),
        ),
      )
      : Container();
}

class _ProfileState extends State<Profile> {
  late Timer timer;

  void initState() {
    super.initState();
    init();

    timer = Timer.periodic(Duration(seconds: 8), (timer) {
      init();
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  static Future init() async {
    preferences = await SharedPreferences.getInstance();
    username = preferences.getString('keyusername') ?? "";
    persistedGenres = preferences.getStringList('_keygenres') ?? [];
    persistedLanguages = preferences.getStringList('_language') ?? [];
    preferences = await SharedPreferences.getInstance();
    remembermovies = preferences.getStringList('savedmoviehistory') ?? [];
    recommemdedmovieimages =
        preferences.getStringList('recommemdedmovieimages') ?? [];
    recommemdedmovienames =
        preferences.getStringList('recommemdedmovietitles') ?? [];
    recommemdedmovieimages = recommemdedmovieimages.reversed.toList();
    recommemdedmovienames = recommemdedmovienames.reversed.toList();
    remembermovies = remembermovies.reversed.toList();
    searchdata = preferences.getStringList('searchdatas') ?? [];
    searchdata = searchdata.reversed.toList();
    images = preferences.getStringList('posters') ?? [];
    title = preferences.getStringList('movienames') ?? [];
    images = images.reversed.toList();
    title = title.reversed.toList();
  }

  // Handle logout functionality
  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: HexColor("#272727"),
          title: Text("Log Out", style: TextStyle(color: Colors.white)),
          content: Text(
            "Are you sure you want to log out?",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel", style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () async {
                // Clear user data
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.remove('keyusername');
                // Navigate to welcome screen
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/signin',
                  (Route<dynamic> route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: HexColor("#7220C9"),
              ),
              child: Text("Log Out", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor("#121212"),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: HexColor("#272727"),
              expandedHeight: 20.h,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  "Profile",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        HexColor("#7220C9").withOpacity(0.7),
                        HexColor("#272727"),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.info_outline),
                  color: Colors.white,
                  onPressed: () {
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
                IconButton(
                  icon: Icon(Icons.logout),
                  color: Colors.white,
                  onPressed: () => _handleLogout(context),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 2.h),
                child: Column(
                  children: [
                    // Avatar and username
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleHolder(
                          height: 100,
                          width: 100,
                          color: HexColor("#7220C9").withOpacity(0.2),
                          child: Padding(
                            padding: EdgeInsets.all(4.0),
                            child: CircleHolder(
                              height: 92,
                              width: 92,
                              color: HexColor("#F1F1F1"),
                              child: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: CircleAvatar(
                                  radius: 40.0,
                                  backgroundImage: AssetImage(
                                    'assets/images/avatar.png',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      username.isNotEmpty
                          ? username.toString()
                          : stname.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // Statistics
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 3.h,
                      ),
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: HexColor("#272727"),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn(
                            "Movies Watched",
                            images.length.toString(),
                          ),
                          Container(
                            height: 40,
                            width: 1,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          _buildStatColumn(
                            "Recommended Movies",
                            recommemdedmovienames.length.toString(),
                          ),
                        ],
                      ),
                    ),

                    // Favorite Genres
                    Container(
                      width: 100.w,
                      margin: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 1.h,
                      ),
                      child: sectionTitle("Favorite Genres"),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: HexColor("#272727").withOpacity(0.7),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: dynamicChips(),
                    ),

                    // Preferred Languages
                    Container(
                      width: 100.w,
                      margin: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 1.h,
                      ),
                      child: sectionTitle("Preferred Languages"),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: HexColor("#272727").withOpacity(0.7),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: dynamicChips2(),
                    ),

                    // Watch History
                    Container(
                      width: 100.w,
                      margin: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 1.h,
                      ),
                      child: sectionTitle("Watch History"),
                    ),
                    images.isNotEmpty
                        ? Container(
                          margin: EdgeInsets.symmetric(horizontal: 2.w),
                          child: buildhistory(),
                        )
                        : Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 1.h,
                          ),
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: HexColor("#272727").withOpacity(0.7),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.movie_creation_outlined,
                                color: Colors.white54,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "No watch history yet",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                    SizedBox(height: 4.h),

                    // Logout Button
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: ElevatedButton.icon(
                        onPressed: () => _handleLogout(context),
                        icon: Icon(Icons.logout),
                        label: Text("Log Out", style: TextStyle(fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HexColor("#7220C9"),
                          foregroundColor: Colors.white,
                          elevation: 5,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 3.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String title, String count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 1.h),
        Text(title, style: TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget buildhistory() {
    if (images.isEmpty) {
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
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            );
          },
        ),
      );
    } else {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 10.0),
        height: 180.0,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: images.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            DetailsPageBody(moviename: title[index].toString()),
                  ),
                );
              },
              child: Container(
                width: 120,
                margin: EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 160,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: FadeInImage.assetNetwork(
                          image: images[index].toString(),
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

  bool t = true;
  Widget checkremember() {
    return images.isNotEmpty
        ? Text(
          images.length.toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        )
        : SizedBox(
          width: 80.w,
          child: Row(
            children: [
              Expanded(
                child: TextScroll(
                  "Grab a popcorn and watch some movies",
                  velocity: Velocity(pixelsPerSecond: Offset(20, 0)),
                  pauseBetween: Duration(milliseconds: 1000),
                  mode: TextScrollMode.bouncing,
                  style: TextStyle(color: HexColor("#DEDEDE"), fontSize: 20),
                  textAlign: TextAlign.right,
                  selectable: false,
                ),
              ),
            ],
          ),
        );
  }

  Widget checkrecommend() {
    return recommemdedmovienames.isNotEmpty
        ? Text(
          recommemdedmovienames.length.toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        )
        : SizedBox(
          width: 80.w,
          child: Row(
            children: [
              Expanded(
                child: TextScroll(
                  "No data yet",
                  velocity: Velocity(pixelsPerSecond: Offset(20, 0)),
                  pauseBetween: Duration(milliseconds: 1000),
                  mode: TextScrollMode.bouncing,
                  style: TextStyle(color: HexColor("#DEDEDE"), fontSize: 20),
                  textAlign: TextAlign.right,
                  selectable: false,
                ),
              ),
            ],
          ),
        );
  }
}
