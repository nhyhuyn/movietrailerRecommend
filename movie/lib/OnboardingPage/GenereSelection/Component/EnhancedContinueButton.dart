import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:movie_app/CustomSnackBar/SnackBar.dart';
import 'package:movie_app/OnboardingPage/GenereSelection/Component/GenreChips.dart';
import 'package:movie_app/OnboardingPage/LanguageSelection/LanguageSelection.dart';
import 'package:movie_app/Util/ApiService.dart';
import 'package:movie_app/main.dart';
import 'package:vibration/vibration.dart';

class EnhancedContinueButton extends StatefulWidget {
  const EnhancedContinueButton({super.key});

  @override
  State<EnhancedContinueButton> createState() => _EnhancedContinueButtonState();
}

class _EnhancedContinueButtonState extends State<EnhancedContinueButton>
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

        if (FilterChipDisplay.filters.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              elevation: 5,
              content: CustomSnackbr(
                title: "Selection Required",
                message: 'Please select at least one genre',
              ),
            ),
          );
        } else {
          preferences.setStringList(
            "_keygenres",
            FilterChipDisplay.filters.toList(),
          );

          persistedGenres = FilterChipDisplay.filters.toList();
          bool success = await ApiService.syncPreferencesToServer();

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LanguageSelection()),
            ModalRoute.withName('/GenreSelection'),
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
                  FilterChipDisplay.filters.isNotEmpty
                      ? [HexColor("#7220C9"), HexColor("#D442FF")]
                      : [Colors.grey.shade700, Colors.grey.shade600],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow:
                FilterChipDisplay.filters.isNotEmpty
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
                  fontSize: 16,
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
