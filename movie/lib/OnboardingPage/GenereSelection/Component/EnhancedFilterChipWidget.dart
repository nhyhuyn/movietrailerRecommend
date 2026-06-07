import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:movie_app/OnboardingPage/GenereSelection/Component/GenreChips.dart';
import 'package:vibration/vibration.dart';

class EnhancedFilterChipWidget extends StatefulWidget {
  final String chipName;
  final IconData icon;
  const EnhancedFilterChipWidget({
    Key? key,
    required this.chipName,
    required this.icon,
  }) : super(key: key);

  @override
  State<EnhancedFilterChipWidget> createState() =>
      _EnhancedFilterChipWidgetState();
}

class _EnhancedFilterChipWidgetState extends State<EnhancedFilterChipWidget>
    with SingleTickerProviderStateMixin {
  bool _isSelected = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
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
          Vibration.vibrate(duration: 20, amplitude: 40);
        }
        setState(() {
          _isSelected = !_isSelected;
          if (_isSelected) {
            FilterChipDisplay.filters.add(widget.chipName);
          } else {
            FilterChipDisplay.filters.removeWhere(
              (String name) => name == widget.chipName,
            );
          }
        });
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color:
                _isSelected
                    ? HexColor("#7220C9")
                    : Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            boxShadow:
                _isSelected
                    ? [
                      BoxShadow(
                        color: HexColor("#7220C9").withOpacity(0.5),
                        blurRadius: 15,
                        spreadRadius: -2,
                      ),
                    ]
                    : [],
            border: Border.all(
              color:
                  _isSelected
                      ? HexColor("#9E58FF")
                      : Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: _isSelected ? Colors.white : HexColor("#9E58FF"),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                widget.chipName,
                style: GoogleFonts.poppins(
                  color:
                      _isSelected
                          ? Colors.white
                          : Colors.white.withOpacity(0.9),
                  fontWeight: _isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
