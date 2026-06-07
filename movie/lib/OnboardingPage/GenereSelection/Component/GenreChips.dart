// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, unused_local_variable

import 'package:flutter/material.dart';
import 'package:movie_app/OnboardingPage/GenereSelection/Component/EnhancedContinueButton.dart';
import 'package:movie_app/OnboardingPage/GenereSelection/Component/EnhancedFilterChipWidget.dart';
import 'package:sizer/sizer.dart';

class FilterChipDisplay extends StatefulWidget {
  static List<String> filters = [];

  @override
  _FilterChipDisplayState createState() => _FilterChipDisplayState();
}

class _FilterChipDisplayState extends State<FilterChipDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Map<String, bool> _animationComplete = {};
  final Map<String, IconData> genreIcons = {
    'Adventure': Icons.landscape_rounded,
    'Drama': Icons.theater_comedy_rounded,
    'Horror': Icons.blur_on_rounded,
    'Mystery': Icons.search_rounded,
    'War': Icons.gavel_rounded,
    'Romance': Icons.favorite_rounded,
    'Science Fiction': Icons.science_rounded,
    'Documentary': Icons.camera_alt_rounded,
    'Thriller': Icons.bolt_rounded,
    'Music': Icons.music_note_rounded,
  };

  final List<String> genres = [
    'Adventure',
    'Drama',
    'Horror',
    'Mystery',
    'War',
    'Romance',
    'Science Fiction',
    'Documentary',
    'Thriller',
    'Music',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Initialize all genres as not animated yet
    for (var genre in genres) {
      _animationComplete[genre] = false;
    }

    // Start sequential animations
    _startSequentialAnimations();
  }

  void _startSequentialAnimations() async {
    for (int i = 0; i < genres.length; i++) {
      await Future.delayed(Duration(milliseconds: 100 * i));
      if (mounted) {
        setState(() {
          _animationComplete[genres[i]] = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Wrap(
          spacing: 12.0,
          runSpacing: 16.0,
          children:
              genres.map((genre) {
                return AnimatedOpacity(
                  opacity: _animationComplete[genre] == true ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  child: AnimatedSlide(
                    offset:
                        _animationComplete[genre] == true
                            ? const Offset(0, 0)
                            : const Offset(0, 0.5),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    child: EnhancedFilterChipWidget(
                      chipName: genre,
                      icon: genreIcons[genre] ?? Icons.movie_rounded,
                    ),
                  ),
                );
              }).toList(),
        ),
        SizedBox(height: 8.h),
        EnhancedContinueButton(),
      ],
    );
  }
}
