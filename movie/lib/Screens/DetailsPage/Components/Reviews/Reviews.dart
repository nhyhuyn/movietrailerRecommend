// ignore_for_file: use_super_parameters, prefer_typing_uninitialized_variables, library_private_types_in_public_api, prefer_interpolation_to_compose_strings, prefer_is_empty, annotate_overrides

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:google_fonts/google_fonts.dart';

class Reviews extends StatefulWidget {
  final id;
  final moviename;
  const Reviews({Key? key, @required this.id, this.moviename})
    : super(key: key);

  @override
  _ReviewsState createState() => _ReviewsState();
}

class _ReviewsState extends State<Reviews> with SingleTickerProviderStateMixin {
  List reviews = [];
  late AnimationController _animationController;
  bool isLoading = true;

  void fetchreviews() async {
    try {
      var response = await Dio().get(
        "http://10.103.101.235:5000/getreview/" + widget.moviename,
      );
      var data = response.data;

      if (mounted) {
        setState(() {
          reviews = data;
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    );
    _animationController.forward();
    fetchreviews();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(HexColor("#7220C9")),
              strokeWidth: 3,
            ),
            SizedBox(height: 16),
            Text(
              "Loading reviews...",
              style: GoogleFonts.poppins(
                color: HexColor("#7220C9"),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (reviews.isEmpty) {
      return Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          decoration: BoxDecoration(
            color: HexColor("#1E1E2A"),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: HexColor("#7220C9").withOpacity(0.3),
                blurRadius: 25,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.rate_review_outlined,
                size: 60,
                color: HexColor("#7220C9"),
              ),
              SizedBox(height: 16),
              Text(
                "There's no public review available yet",
                style: GoogleFonts.poppins(
                  color: HexColor("#7220C9"),
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.only(top: 20),
      child: ListView.builder(
        itemCount: reviews.length,
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 15),
        itemBuilder: (BuildContext context, int index) {
          final bool isGoodReview = reviews[index]['rating'] == "Good";
          final Color reviewColor = isGoodReview
              ? HexColor("#2FC162")
              : HexColor("#B02A2D");

          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final delay = index * 0.2;
              final slideAnimation =
                  Tween<Offset>(
                    begin: Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Interval(
                        delay.clamp(0.0, 0.8),
                        (delay + 0.2).clamp(0.0, 1.0),
                        curve: Curves.easeOutQuart,
                      ),
                    ),
                  );

              final opacityAnimation = Tween<double>(begin: 0.0, end: 1.0)
                  .animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Interval(
                        delay.clamp(0.0, 0.8),
                        (delay + 0.2).clamp(0.0, 1.0),
                        curve: Curves.easeOut,
                      ),
                    ),
                  );

              return FadeTransition(
                opacity: opacityAnimation,
                child: SlideTransition(position: slideAnimation, child: child),
              );
            },
            child: Card(
              elevation: 14,
              shadowColor: reviewColor.withOpacity(0.6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              margin: EdgeInsets.only(top: 24, bottom: 6),
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      reviewColor,
                      reviewColor.withOpacity(0.85),
                      reviewColor.withOpacity(0.75),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: reviewColor.withOpacity(0.4),
                      spreadRadius: 1,
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        reviews[index]["review"],
                        maxLines: 12,
                        style: GoogleFonts.lato(
                          decoration: TextDecoration.none,
                          fontSize: 17,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(18),
                          bottomRight: Radius.circular(18),
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            isGoodReview ? Icons.thumb_up : Icons.thumb_down,
                            color: Colors.white,
                            size: 22,
                          ),
                          SizedBox(width: 10),
                          Text(
                            (isGoodReview ? "Good review" : "Bad Review"),
                            style: GoogleFonts.poppins(
                              fontSize: 25,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            (isGoodReview ? " 👍 " : " 👎 "),
                            style: TextStyle(
                              fontSize: 25,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
