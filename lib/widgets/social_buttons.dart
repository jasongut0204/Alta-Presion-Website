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
    return Positioned(
      top: 20, // ⬆️ Align to top
      left: 20, // ⬅️ Align to left
      child: Row( // 🔄 Use Row instead of Column to place logos side-by-side
        children: [
          _buildSocialButton("assets/ig_logo.png", _openInstagram), // Instagram
          SizedBox(width: 10), // Space between logos
          _buildSocialButton("assets/tt_logo.png", _openTikTok), // TikTok
        ],
      ),
    );
  }

  // Social Media Button UI
  Widget _buildSocialButton(String assetPath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.black.withOpacity(0.2), // Semi-transparent background
          ),
          padding: EdgeInsets.all(8),
          child: Image.asset(
            assetPath,
            width: 60, // Keep the size
            height: 60,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.error, color: Colors.red, size: 40);
            },
          ),
        ),
      ),
    );
  }
}
