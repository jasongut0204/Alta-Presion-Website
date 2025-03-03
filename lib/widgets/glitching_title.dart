import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GlitchingTitle extends StatefulWidget {
  const GlitchingTitle({Key? key}) : super(key: key);

  @override
  _GlitchingTitleState createState() => _GlitchingTitleState();
}

class _GlitchingTitleState extends State<GlitchingTitle> {
  final String originalText = "LA PRESIÓN SE SIENTE EN MAYAGÜEZ...";
  final String glitchCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890@#\$%&*?!";
  String currentText = "";
  late Timer _timer;
  Random random = Random();

  @override
  void initState() {
    super.initState();
    currentText = originalText;
    _startGlitchEffect();
  }

  void _startGlitchEffect() {
    _timer = Timer.periodic(Duration(seconds: 2), (_) { // 🔥 Slower glitch every 2 seconds
      setState(() {
        currentText = _generateGlitchText();
      });

      Future.delayed(Duration(milliseconds: 700), () { // 🔥 Restore after 700ms
        setState(() {
          currentText = originalText;
        });
      });
    });
  }

  String _generateGlitchText() {
    List<int> glitchIndexes = [];
    
    // 🔥 Choose up to 5 random positions to glitch
    while (glitchIndexes.length < 5) {
      int index = random.nextInt(originalText.length);
      if (!glitchIndexes.contains(index) && originalText[index] != " ") {
        glitchIndexes.add(index);
      }
    }

    return originalText.split("").asMap().entries.map((entry) {
      int index = entry.key;
      String char = entry.value;
      return glitchIndexes.contains(index)
          ? glitchCharacters[random.nextInt(glitchCharacters.length)]
          : char;
    }).join("");
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      currentText,
      textAlign: TextAlign.center,
      style: GoogleFonts.goldman(
        fontSize: MediaQuery.of(context).size.width * 0.04,
        fontWeight: FontWeight.normal,
        color: Colors.black,
        shadows: [
          Shadow(offset: Offset(-2, -2), color: Colors.yellow, blurRadius: 3),
          Shadow(offset: Offset(2, -2), color: Colors.yellow, blurRadius: 3),
          Shadow(offset: Offset(-2, 2), color: Colors.yellow, blurRadius: 3),
          Shadow(offset: Offset(2, 2), color: Colors.yellow, blurRadius: 3),
        ],
      ),
    );
  }
}
