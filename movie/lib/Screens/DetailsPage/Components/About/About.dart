// ignore_for_file: prefer_interpolation_to_compose_strings, prefer_typing_uninitialized_variables, non_constant_identifier_names, use_super_parameters, prefer_const_constructors_in_immutables, library_private_types_in_public_api, prefer_is_empty, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:movie_app/Screens/DetailsPage/Components/CastDetails/CastDetails.dart';
import 'package:sizer/sizer.dart';
import 'package:vibration/vibration.dart';

class About extends StatefulWidget {
  final overview;
  final id;
  final moviename;
  final userid;
  final username;
  final production_companies;

  About({
    Key? key,
    @required this.overview,
    this.id,
    this.moviename,
    this.userid,
    this.production_companies,
    this.username,
  }) : super(key: key);

  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  List genres = [];
  List production_companies = [];
  List moviedetails = [];
  List director = [];
  List crew = [];
  final Color primaryColor = HexColor("#7220C9");
  final Color backgroundColor = HexColor("#121212");
  final Color cardColor = HexColor("#1E1E1E");
  final Color textColor = Colors.white;
  final Color secondaryTextColor = Colors.grey.shade300;

  @override
  void initState() {
    super.initState();
    getpopularresponse();
    getmoviedetails();
    getdirector();
    getcrewdetails();
  }

  void getpopularresponse() async {
    try {
      var response = await Dio().get(
        "https://api.themoviedb.org/3/movie/${widget.id}?api_key=dbda4bb34573ea2b68379f1e476c3933&language=en-US",
      );
      setState(() {
        genres = response.data["genres"];
      });
    } catch (e) {
      print(e);
    }
  }

  void getmoviedetails() async {
    try {
      var response = await Dio().get(
        "http://10.103.101.235:5000/getmovie/${widget.moviename}",
      );
      setState(() {
        moviedetails = response.data;
      });
    } catch (e) {
      print(e);
    }
  }

  void getcrewdetails() async {
    try {
      var response = await Dio().get(
        "https://api.themoviedb.org/3/movie/${widget.id}/credits?api_key=dbda4bb34573ea2b68379f1e476c3933",
      );
      setState(() {
        crew = response.data["cast"];
      });
    } catch (e) {
      print(e);
    }
  }

  void getdirector() async {
    try {
      var response = await Dio().get(
        "http://10.103.101.235:5000/getdirector/${widget.moviename}",
      );
      setState(() {
        director = response.data;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      width: double.infinity,
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sectionTitle("Overview"),
            sectionText(widget.overview),
            sectionDivider(),

            sectionTitle("Genre"),
            getgenres(),
            sectionDivider(),

            sectionTitle("Details"),
            getdetailslist(),
            sectionDivider(),

            sectionTitle("Crew"),
            getcrew(),
            sectionDivider(),

            sectionTitle("Production Companies"),
            getproduction_companies_chips(),
            SizedBox(height: 3.h),
          ],
        ),
      ),
    );
  }

  // ===================== UI Helper Widgets =======================

  Widget sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 2.h, bottom: 1.5.h),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget sectionText(String text) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: secondaryTextColor,
          fontSize: 13.sp,
          height: 1.6,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget sectionDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.5.h),
      child: Divider(color: Colors.white10, thickness: 1),
    );
  }

  Widget getgenres() {
    if (genres.isEmpty) return _buildLoader();

    return Container(
      height: 6.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: genres.length,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(right: 2.w),
            child: Chip(
              elevation: 3,
              avatar: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  genres[index]['name'][0],
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              label: Text(
                genres[index]['name'],
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.5.h),
              backgroundColor: primaryColor.withOpacity(0.8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget getdetailslist() {
    if (moviedetails.isEmpty || director.isEmpty) {
      return _buildLoader();
    }

    var movie = moviedetails[0];

    Widget infoRow(String label, String value, IconData icon) {
      return Container(
        margin: EdgeInsets.only(bottom: 1.5.h),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: primaryColor, size: 20),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    value,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        infoRow("Director", director[0] ?? "N/A", Icons.movie),
        infoRow("Run Time", "${movie['runtime']} minutes", Icons.access_time),
        infoRow(
          "Release Date",
          movie['release_date'] ?? "N/A",
          Icons.calendar_today,
        ),
        infoRow(
          "Popularity",
          movie['popularity'].toString(),
          Icons.trending_up,
        ),
      ],
    );
  }

  Widget getcrew() {
    if (crew.isEmpty) return _buildLoader();

    return Container(
      height: 200,
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: crew.length,
        itemBuilder: (context, index) {
          var member = crew[index];
          return GestureDetector(
            onTap: () async {
              if (await Vibration.hasVibrator()) {
                Vibration.vibrate(duration: 100);
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Castdetails(
                    castname: member['name'],
                    castid: member['id'],
                    profilepath: member['profile_path'],
                  ),
                ),
              );
            },
            child: Container(
              width: 110,
              margin: EdgeInsets.only(right: 3.w),
              child: Column(
                children: [
                  Container(
                    height: 140,
                    width: 110,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        member["profile_path"] != null
                            ? "https://image.tmdb.org/t/p/original${member['profile_path']}"
                            : "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR28i5jWF37DvM01csPLTUTxEvCUAiL1ho6qw&usqp=CAU",
                        height: 140,
                        width: 110,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 140,
                            width: 110,
                            color: cardColor,
                            child: Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  primaryColor,
                                ),
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    member["original_name"] ?? "",
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    member["character"] != null && member["character"] != ""
                        ? "as ${member["character"]}"
                        : "",
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 10.sp,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget getproduction_companies_chips() {
    if (widget.production_companies == null ||
        widget.production_companies.isEmpty) {
      return _buildLoader();
    }

    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: List.generate(widget.production_companies.length, (index) {
        var company = widget.production_companies[index];
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: primaryColor.withOpacity(0.3), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: primaryColor.withOpacity(0.2),
                child: Text(
                  company["name"]?.substring(0, 1) ?? "",
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                company["name"] ?? "",
                style: TextStyle(color: textColor, fontSize: 12.sp),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildLoader() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 3.h),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
        ),
      ),
    );
  }
}
