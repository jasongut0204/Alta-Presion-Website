import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:alta_presion/widgets/corrupted_chatbot.dart';
import 'package:alta_presion/widgets/social_buttons.dart'; // ✅ Import Social Buttons
import 'dart:html' as html;
import 'dart:math';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Alta Presión',
      home: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black, 
          child: AltaPresionWebsite(),
        ),
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

  void _boostRotation() {
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // 🎥 Background Video
          FutureBuilder(
            future: _initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Positioned.fill(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: screenWidth > screenHeight ? screenWidth : screenHeight * 1.5,
                      height: screenHeight > screenWidth ? screenHeight : screenWidth * 1.5,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(color: Colors.yellow),
                );
              }
            },
          ),

          // 🔳 Dark Overlay
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.3)),
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
                      onTap: _boostRotation,
                      child: AnimatedBuilder(
                        animation: _rotationAnimation,
                        builder: (context, child) {
                          return Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()..rotateY(_rotationAnimation.value),
                            child: Image.asset(
                              "assets/apLogo.png",
                              height: screenWidth < 600
                                  ? screenWidth * 0.5 
                                  : screenWidth * 0.2, 
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

                // 🔥 Animated Main Title
                SizedBox(height: screenHeight / 5),
                TweenAnimationBuilder<double>(
                  duration: Duration(seconds: 5),
                  curve: Curves.easeOut,
                  tween: Tween<double>(begin: 0.01, end: 1.0),
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Text(
                        "LA PRESIÓN SE SIENTE EN MAYAGÜEZ...",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.goldman(
                          fontSize: screenWidth * 0.04,
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
                    );
                  },
                ),
                SizedBox(height: screenHeight * 0.03),

                // 🎵 Play Music Button
                ElevatedButton(
                  onPressed: _playAudio,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    foregroundColor: Colors.black,
                  ),
                  child: Text("PLAY MUSIC", style: GoogleFonts.goldman(
                    fontSize: screenWidth * 0.01,
                    fontWeight: FontWeight.bold,
                  )),
                ),

                SizedBox(height: screenHeight * 0.5),
              ],
            ),
          ),

          CorruptedChatbot(),
          SocialButtons(), // ✅ Social Media Buttons added!
        ],
      ),
    );
  }
}
