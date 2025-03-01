import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math'; // Required for 3D rotation

void main() {
  runApp(AltaPresionWebsite());
}

class AltaPresionWebsite extends StatelessWidget {
  const AltaPresionWebsite({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Alta Presión',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  late AudioPlayer _audioPlayer;
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  bool _isAudioPlaying = false;

  @override
  void initState() {
    super.initState();

    // ✅ Load Video from Assets
    _controller = VideoPlayerController.asset("heart_pulse.mp4")
      ..initialize().then((_) {
        setState(() {});
        _controller.setLooping(true);
        _controller.play();
      });

    _audioPlayer = AudioPlayer();

    // 🔄 3D Rotation Animation
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4), // Adjust speed of rotation
    )..repeat(); // Loops indefinitely

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * pi, // 360 degrees rotation
    ).animate(_animationController);
  }

  void _playAudio() async {
    try {
      if (!_isAudioPlaying) {
        await _audioPlayer.setSource(AssetSource("background_music.ogg"));
        _audioPlayer.setReleaseMode(ReleaseMode.loop);
        await _audioPlayer.resume();
        setState(() {
          _isAudioPlaying = true;
        });
      }
    } catch (e) {
      print("Error loading audio: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // 🔴 Bright Red Background
          Positioned.fill(
            child: Container(color: Colors.red),
          ),

          // 🎥 Background Video (Using Local Asset)
          Positioned.fill(
            child: _controller.value.isInitialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  )
                : Container(color: Colors.black),
          ),

          // 🔳 Overlay for better text visibility
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),

          // 📜 Scrollable Content
          SingleChildScrollView(
            child: Column(
              children: [
                // 🏆 3D Rotating Logo at the Top Center
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    child: AnimatedBuilder(
                      animation: _rotationAnimation,
                      builder: (context, child) {
                        return Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..rotateY(_rotationAnimation.value), // Rotate along Y-axis
                          child: Image.asset(
                            "assets/apLogo.png",
                            height: screenWidth * 0.2,
                            errorBuilder: (context, error, stackTrace) {
                              return Text(
                                "Failed to load logo",
                                style: TextStyle(color: Colors.red, fontSize: 16),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // 🔥 Main Title
                SizedBox(height: screenHeight / 4),
                Center(
                  child: Column(
                    children: [
                      SelectableText(
                        "LA PRESIÓN SE SIENTE EN MAYAGUEZ...",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.goldman(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          shadows: [
                            Shadow(offset: Offset(-2, -2), color: Colors.yellow, blurRadius: 3),
                            Shadow(offset: Offset(2, -2), color: Colors.yellow, blurRadius: 3),
                            Shadow(offset: Offset(-2, 2), color: Colors.yellow, blurRadius: 3),
                            Shadow(offset: Offset(2, 2), color: Colors.yellow, blurRadius: 3),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.05),

                      // 🎵 Play Music Button
                      ElevatedButton(
                        onPressed: _playAudio,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow,
                          foregroundColor: Colors.black,
                          textStyle: TextStyle(
                            fontSize: screenWidth * 0.02,
                            fontWeight: FontWeight.bold,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.02,
                            vertical: screenHeight * 0.01,
                          ),
                        ),
                        child: Text(
                          "PLAY MUSIC",
                          style: GoogleFonts.goldman(),
                        ),
                      ),
                    ],
                  ),
                ),

                // Extra Space for Scrolling
                SizedBox(height: screenHeight * 0.5),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
