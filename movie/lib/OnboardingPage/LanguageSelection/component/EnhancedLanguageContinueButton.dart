// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:movie_app/CustomSnackBar/SnackBar.dart';
import 'package:movie_app/Navigation/Navigation.dart';
import 'package:movie_app/OnboardingPage/LanguageSelection/component/LanguageChips.dart';
import 'package:movie_app/Util/ApiService.dart';
import 'package:movie_app/main.dart';
import 'package:sizer/sizer.dart';
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnhancedLanguageContinueButton extends StatefulWidget {
  const EnhancedLanguageContinueButton({Key? key}) : super(key: key);

  @override
  State<EnhancedLanguageContinueButton> createState() =>
      _EnhancedLanguageContinueButtonState();
}

class _EnhancedLanguageContinueButtonState
    extends State<EnhancedLanguageContinueButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: () async {
        if (await Vibration.hasVibrator()) {
          Vibration.vibrate(duration: 50);
        }

        if (LanguageChips.languages.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              elevation: 5,
              content: CustomSnackbr(
                title: "Selection Required",
                message: 'Please select at least one language',
              ),
            ),
          );
        } else {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          preferences.setStringList(
            "_language",
            LanguageChips.languages.toList(),
          );
          persistedLanguages = LanguageChips.languages.toList();
          bool success = await ApiService.syncPreferencesToServer();

          await prefs.setBool('seen', true);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage()),
            ModalRoute.withName('/LanguageSelection'),
          );
        }
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: Container(
          width: 150,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  LanguageChips.languages.isNotEmpty
                      ? [HexColor("#7220C9"), HexColor("#D442FF")]
                      : [Colors.grey.shade700, Colors.grey.shade600],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow:
                LanguageChips.languages.isNotEmpty
                    ? [
                      BoxShadow(
                        color: HexColor("#7220C9").withOpacity(0.5),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ]
                    : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Continue",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
