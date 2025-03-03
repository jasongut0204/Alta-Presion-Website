import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoadingWidget extends StatefulWidget {
  const LoadingWidget({Key? key}) : super(key: key);

  @override
  _LoadingWidgetState createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget> with SingleTickerProviderStateMixin {
  final String text = "LOADING..."; // 🔥 The word being animated
  late AnimationController _controller;
  late List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 5500), // ⏩ Faster animation
    )..repeat(); // Continuous animation

    _fadeAnimations = List.generate(text.length, (index) {
      double start = index / text.length;
      double end = (index + 1) / text.length;

      if (end > 1.0) end = 1.0; // Ensure the interval never exceeds 1.0

      return TweenSequence([
        // 🔥 Fade in faster
        TweenSequenceItem(tween: Tween<double>(begin: 0.3, end: 1.0), weight: 20),
        // 🔥 Fade out faster
        TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.3), weight: 20),
      ]).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeInOut),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double fontSize = (MediaQuery.of(context).size.width * 0.05).clamp(18, 50); // 🔥 Dynamic text size

    return Center(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(text.length, (index) {
            return AnimatedBuilder(
              animation: _fadeAnimations[index],
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimations[index].value, // 🔥 Smooth sequential fade effect
                  child: Text(
                    text[index],
                    style: GoogleFonts.orbitron(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}
