import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:alta_presion/widgets/corrupted_chatbot.dart';
import 'package:alta_presion/widgets/social_buttons.dart';
import 'package:alta_presion/widgets/glitchy_name.dart';
import 'package:alta_presion/widgets/glitching_title.dart'; 
import 'package:alta_presion/widgets/loading_widget.dart'; 
import 'dart:math';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Alta Presión',
      home: Scaffold(
        body: AltaPresionWebsite(),
      ),
    ),
  );
}

class AltaPresionWebsite extends StatelessWidget {
  const AltaPresionWebsite({super.key});

  @override
  Widget build(BuildContext context) {
    return HomePage();
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
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset("assets/heart_pulse.mp4");

    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      if (mounted) {
        setState(() {});
        _controller.setLooping(true);
        _controller.setVolume(0);
        _controller.play();
      }
    }).catchError((error) {
      print("❌ Error initializing video: $error");
    });

    _audioPlayer = AudioPlayer();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4),
    )..repeat();

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(_animationController);
  }

  void _playAudio() async {
    try {
      if (!_isAudioPlaying) {
        await _audioPlayer.setSource(AssetSource("background_music.mp3"));
        _audioPlayer.setReleaseMode(ReleaseMode.loop);
        await _audioPlayer.resume();
        setState(() {
          _isAudioPlaying = true;
        });

        if (_controller.value.isInitialized && !_controller.value.isPlaying) {
          _controller.play();
        }
      }
    } catch (e) {
      print("❌ Error loading audio: $e");
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
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;
        double screenHeight = constraints.maxHeight;

        // Video Size (Fixed, not scaling)
        double videoWidth = screenWidth * 0.6; // Scale relative to screen
        double videoHeight = screenHeight * 0.4;

        return Scaffold(
          body: Stack(
            children: [
              // 🔳 Black Background
              Positioned.fill(
                child: Container(color: Colors.black),
              ),

              // 🎥 Centered Video (Fixed Size)
              Center(
                child: FutureBuilder(
                  future: _initializeVideoPlayerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return SizedBox(
                        width: videoWidth,
                        height: videoHeight,
                        child: VideoPlayer(_controller),
                      );
                    } else {
                      return Center(
                        child: CircularProgressIndicator(color: Colors.yellow),
                      );
                    }
                  },
                ),
              ),

              // 📜 Scrollable Content
              SingleChildScrollView(
                child: Column(
                  children: [
                    // 🏆 3D Rotating Logo
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        child: GestureDetector(
                          onTap: () {
                            _animationController.duration = Duration(milliseconds: 300);
                            _animationController.repeat();

                            Future.delayed(Duration(milliseconds: 500), () {
                              if (mounted) {
                                _animationController.animateTo(
                                  1.0,
                                  duration: Duration(seconds: 1),
                                  curve: Curves.decelerate,
                                ).then((_) {
                                  if (mounted) {
                                    _animationController.duration = Duration(seconds: 4);
                                    _animationController.repeat();
                                  }
                                });
                              }
                            });
                          },
                          child: AnimatedBuilder(
                            animation: _rotationAnimation,
                            builder: (context, child) {
                              return Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()..rotateY(_rotationAnimation.value),
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
                    ),

                    // 🔥 Glitching Title Text
                    SizedBox(height: screenHeight * 0.05),
                    GlitchingTitle(), // ✅ Glitching Title Widget

                    SizedBox(height: screenHeight * 0.03),

                    // 🎵 Play Music Button
                    ElevatedButton(
                      onPressed: _playAudio,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow,
                        foregroundColor: Colors.black,
                      ),
                      child: Text("PLAY MUSIC", style: GoogleFonts.goldman(
                        fontSize: screenWidth * 0.02,
                        fontWeight: FontWeight.bold,
                      )),
                    ),

                    SizedBox(height: screenHeight * 0.01),
                    SizedBox(height: screenHeight * 0.4), // Space before loading
                    LoadingWidget(), // 🔥 "LOADING..." Animated Dots
                  ],
                ),
              ),

              // 🕶 Other Widgets
              CorruptedChatbot(),
              SocialButtons(),
              GlitchyName(), // ✅ Glitchy Name (Top Right)
            ],
          ),
        );
      },
    );
  }
}
