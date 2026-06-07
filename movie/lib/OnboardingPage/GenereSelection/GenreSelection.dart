import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:movie_app/OnboardingPage/GenereSelection/Component/GenreChips.dart';
import 'package:sizer/sizer.dart';

class GenreSelection extends StatefulWidget {
  const GenreSelection({Key? key}) : super(key: key);

  @override
  State<GenreSelection> createState() => _GenreSelectionState();
}

class _GenreSelectionState extends State<GenreSelection> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: 100.h,
        width: 100.w,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1B1B2F), Color(0xFF0F0F1F)],
          ),
        ),
        child: Stack(
          children: [
            // Background overlay image with blur
            Positioned.fill(
              child: Opacity(
                opacity: 0.4,
                child: Image.asset(
                  "assets/images/background.jpg",
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Gradient overlay
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.5),
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Content
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with animated icon
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: HexColor("#7220C9").withOpacity(0.2),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(
                              Icons.movie_filter_rounded,
                              color: HexColor("#7220C9"),
                              size: 28,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            "Personalize",
                            style: GoogleFonts.poppins(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      // Title with gradient
                      ShaderMask(
                        shaderCallback:
                            (bounds) => LinearGradient(
                              colors: [Colors.white, HexColor("#9E58FF")],
                            ).createShader(bounds),
                        child: Text(
                          "Let's get to know you better",
                          style: GoogleFonts.poppins(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      // Subtitle
                      Text(
                        "What genres will you be interested to watch?",
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.8),
                          height: 1.3,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      // Genre chips
                      FilterChipDisplay(),
                    ],
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
