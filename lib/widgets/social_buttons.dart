import 'package:flutter/material.dart';
import 'dart:html' as html;

class SocialButtons extends StatelessWidget {
  const SocialButtons({super.key});

  // Open Instagram (Replace with actual link)
  void _openInstagram() {
    html.window.open("https://www.instagram.com/your_username", "_blank");
  }

  // Open TikTok (Replace with actual link)
  void _openTikTok() {
    html.window.open("https://www.tiktok.com/@your_username", "_blank");
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    // ✅ Adjust button & logo size dynamically
    double buttonSize = screenWidth < 600 ? 40 : (screenWidth < 1000 ? 50 : 60);
    double paddingSize = screenWidth < 600 ? 5 : 10;

    return Positioned(
      top: paddingSize + 10, // Adjust positioning
      left: paddingSize + 10,
      child: Row(
        children: [
          _buildSocialButton("assets/ig_logo.png", _openInstagram, buttonSize, paddingSize),
          SizedBox(width: paddingSize),
          _buildSocialButton("assets/tt_logo.png", _openTikTok, buttonSize, paddingSize),
        ],
      ),
    );
  }

  // ✅ Fully Responsive Social Media Button
  Widget _buildSocialButton(String assetPath, VoidCallback onTap, double size, double padding) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.black.withOpacity(0.2),
          ),
          padding: EdgeInsets.all(padding),
          child: SizedBox(
            width: size, // ✅ Forces proper size
            height: size,
            child: Image.asset(
              assetPath,
              fit: BoxFit.contain, // ✅ Ensures it scales properly
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.error, color: Colors.red, size: size * 0.8);
              },
            ),
          ),
        ),
      ),
    );
  }
}
