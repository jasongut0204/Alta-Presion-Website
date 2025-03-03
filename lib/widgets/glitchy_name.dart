import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GlitchyName extends StatefulWidget {
  const GlitchyName({Key? key}) : super(key: key);

  @override
  _GlitchyNameState createState() => _GlitchyNameState();
}

class _GlitchyNameState extends State<GlitchyName> {
  final String originalText = "ALTA PRESIÓN";
  final String glitchCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890@#\$%&*!";
  String currentText = "";
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startGlitchEffect();
  }

  void _startGlitchEffect() {
    _timer = Timer.periodic(Duration(milliseconds: 100), (_) {
      setState(() {
        currentText = _generateGlitchText();
      });
    });
  }

  String _generateGlitchText() {
    Random random = Random();
    StringBuffer buffer = StringBuffer();

    for (int i = 0; i < originalText.length; i++) {
      if (originalText[i] == " ") {
        buffer.write(" ");
      } else {
        bool revealLetter = random.nextDouble() > 0.6; // 20% chance to show the real letter
        buffer.write(revealLetter ? originalText[i] : glitchCharacters[random.nextInt(glitchCharacters.length)]);
      }
    }
    return buffer.toString();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.01; // Scale dynamically

    return Positioned(
      top: screenWidth * 0.02, // Dynamic spacing
      right: screenWidth * 0.03, // Dynamic spacing
      child: Text(
        currentText,
        style: GoogleFonts.orbitron(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.red,
          shadows: [
            Shadow(blurRadius: 10, color: Colors.redAccent),
            Shadow(blurRadius: 20, color: Colors.black),
          ],
        ),
      ),
    );
  }
}
