// ignore_for_file: missing_required_param

import 'package:flutter/material.dart';
import 'package:movie_app/OnboardingPage/LanguageSelection/component/EnhancedLanguageChipWidget.dart';
import 'package:movie_app/OnboardingPage/LanguageSelection/component/EnhancedLanguageContinueButton.dart';

class LanguageChips extends StatefulWidget {
  static final List<String> languages = [];
  const LanguageChips({super.key});

  @override
  State<LanguageChips> createState() => _LanguageChipsState();
}

class _LanguageChipsState extends State<LanguageChips>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Map<String, bool> _animationComplete = {};
  final Map<String, IconData> languageIcons = {
    'English': Icons.language,
    'Mandarin Chinese': Icons.language,
    'Spanish': Icons.language,
    'Hindi': Icons.language,
    'Arabic': Icons.language,
    'French': Icons.language,
    'Bengali': Icons.language,
    'Russian': Icons.language,
    'Portuguese': Icons.language,
    'Japanese': Icons.language,
    'German': Icons.language,
    'Korean': Icons.language,
    'Vietnamese': Icons.language,
  };

  final List<String> languages = [
    'English',
    'Mandarin Chinese',
    'Spanish',
    'Hindi',
    'Arabic',
    'French',
    'Bengali',
    'Russian',
    'Portuguese',
    'Japanese',
    'German',
    'Korean',
    'Vietnamese',
  ];

  final Map<String, String> languageFlags = {
    'English': '🇺🇸',
    'Mandarin Chinese': '🇨🇳',
    'Spanish': '🇪🇸',
    'Hindi': '🇮🇳',
    'Arabic': '🇸🇦',
    'French': '🇫🇷',
    'Bengali': '🇧🇩',
    'Russian': '🇷🇺',
    'Portuguese': '🇧🇷',
    'Japanese': '🇯🇵',
    'German': '🇩🇪',
    'Korean': '🇰🇷',
    'Vietnamese': '🇻🇳',
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Initialize all languages as not animated yet
    for (var language in languages) {
      _animationComplete[language] = false;
    }

    // Start sequential animations
    _startSequentialAnimations();
  }

  void _startSequentialAnimations() async {
    for (int i = 0; i < languages.length; i++) {
      await Future.delayed(Duration(milliseconds: 100 * i));
      if (mounted) {
        setState(() {
          _animationComplete[languages[i]] = true;
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
              languages.map((language) {
                return AnimatedOpacity(
                  opacity: _animationComplete[language] == true ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  child: AnimatedSlide(
                    offset:
                        _animationComplete[language] == true
                            ? const Offset(0, 0)
                            : const Offset(0, 0.5),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    child: EnhancedLanguageChipWidget(
                      chipName: language,
                      flag: languageFlags[language] ?? '',
                    ),
                  ),
                );
              }).toList(),
        ),
        SizedBox(height: 8),
        EnhancedLanguageContinueButton(),
      ],
    );
  }
}
