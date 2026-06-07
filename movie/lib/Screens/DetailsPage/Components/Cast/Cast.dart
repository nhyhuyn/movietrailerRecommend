// ignore_for_file: prefer_typing_uninitialized_variables, use_super_parameters, library_private_types_in_public_api, prefer_interpolation_to_compose_strings, avoid_print, unnecessary_this, annotate_overrides

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:movie_app/Screens/DetailsPage/Components/CastDetails/CastDetails.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import 'package:vibration/vibration.dart';

class Cast extends StatefulWidget {
  final id;
  final userid;
  final username;
  const Cast({Key? key, @required this.id, this.userid, this.username})
    : super(key: key);

  @override
  _CastState createState() => _CastState();
}

class _CastState extends State<Cast> {
  List cast = [];

  void getpopularresponse() async {
    var response = await Dio().get(
      "https://api.themoviedb.org/3/movie/" +
          widget.id.toString() +
          "/credits?api_key=dbda4bb34573ea2b68379f1e476c3933&language=en-US",
    );
    var data = response.data;
    try {
      if (mounted) {
        setState(() {
          cast = data["cast"];
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    this.getpopularresponse();
  }

  Widget build(BuildContext context) {
    return Container(
      height: 60.0,
      margin: EdgeInsets.only(top: 15, left: 15, right: 15),
      width: double.infinity,
      child: cast.isEmpty ? _buildShimmerLoading() : _buildCastList(),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 5,
      itemBuilder: (BuildContext context, int index) {
        return Shimmer.fromColors(
          period: Duration(milliseconds: 1500),
          baseColor: (Colors.grey[800])!,
          direction: ShimmerDirection.ltr,
          highlightColor: (Colors.grey[600])!,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 8),
            width: 220,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCastList() {
    return ListView.builder(
      itemCount: cast.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          onTap: () async {
            if (await Vibration.hasVibrator()) {
              Vibration.vibrate(duration: 50);
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => Castdetails(
                      castname: cast[index]["name"],
                      profilepath: cast[index]["profile_path"],
                      castid: cast[index]['id'],
                    ),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 1.w),
            child: _buildCastTile(cast, index),
          ),
        );
      },
    );
  }

  Widget _buildCastTile(cast, index) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [HexColor("#8A2BE2"), HexColor("#4B0082")],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 12),
          trailing: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          leading: Hero(
            tag: 'cast_${cast[index]["id"]}',
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: HexColor("#8A2BE2").withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 32,
                backgroundColor: Colors.transparent,
                backgroundImage: NetworkImage(
                  cast[index]["profile_path"] == null
                      ? "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR28i5jWF37DvM01csPLTUTxEvCUAiL1ho6qw&usqp=CAU"
                      : "https://image.tmdb.org/t/p/w780" +
                          cast[index]["profile_path"],
                ),
              ),
            ),
          ),
          title: Text(
            cast[index]["name"],
            style: TextStyle(
              fontFamily: 'fonts/Lato-Bold.ttf',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              decoration: TextDecoration.none,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.5),
                  offset: Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          subtitle: Text(
            cast[index]["character"] != null
                ? "Role: ${cast[index]["character"]}"
                : "Cast Member",
            style: TextStyle(
              fontFamily: 'fonts/Lato-Regular.ttf',
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }
}
