// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

class RoundRectangleButton extends StatelessWidget {
  final void Function() onPressed;
  String text = "";
  RoundRectangleButton({
    required this.onPressed,
    required this.text,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150, // <-- Button Width
      height: 40, // <-- Button height
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: HexColor("#4154FC"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // <-- Radius
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: GoogleFonts.getFont(
            "Chivo",
            textStyle: const TextStyle(
              color: Colors.white,
              letterSpacing: .5,
              fontWeight: FontWeight.w400,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}
