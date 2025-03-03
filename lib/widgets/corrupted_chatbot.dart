import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CorruptedChatbot extends StatefulWidget {
  const CorruptedChatbot({super.key});

  @override
  _CorruptedChatbotState createState() => _CorruptedChatbotState();
}

class _CorruptedChatbotState extends State<CorruptedChatbot> {
  bool isChatOpen = false;
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  List<Map<String, String>> chatMessages = [];
  final ScrollController _scrollController = ScrollController();
  bool isBotTyping = false;
  List<String> usedSpanishResponses = [];
  List<String> usedEnglishResponses = [];

  final List<String> spanishResponses = [
    "No deberías estar aquí...",
    "La señal se está desmoronando...",
    "Alguien te sigue...",
    "Alta Presión se acerca...",
    "Esto no es real...",
    "Código activado: 019-X..."
  ];

  final List<String> englishResponses = [
    "You shouldn't be here...",
    "The signal is breaking...",
    "Someone is watching...",
    "Alta Presión is near...",
    "This is not real...",
    "Code activated: 019-X..."
  ];

  void handleUserMessage(String message) {
    if (message.trim().isEmpty) return;

    setState(() {
      chatMessages.add({"user": message});
      _messageController.clear();
    });

    _scrollToBottom();

    setState(() {
      isBotTyping = true;
    });

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        isBotTyping = false;
        chatMessages.add({"bot": ""});
      });

      _scrollToBottom();
      _simulateTyping(chatMessages.length - 1, getAIResponse(message));
    });

    Future.delayed(Duration(milliseconds: 100), () {
      _inputFocusNode.requestFocus();
    });
  }

  void _simulateTyping(int messageIndex, String fullText) async {
    for (int i = 0; i <= fullText.length; i++) {
      await Future.delayed(Duration(milliseconds: 50));
      setState(() {
        chatMessages[messageIndex]["bot"] = fullText.substring(0, i);
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String getAIResponse(String input) {
    input = input.toLowerCase();
    bool isSpanish = detectSpanish(input);
    List<String> availableResponses =
        isSpanish ? spanishResponses : englishResponses;
    List<String> usedResponses =
        isSpanish ? usedSpanishResponses : usedEnglishResponses;

    if (usedResponses.length == availableResponses.length) {
      usedResponses.clear();
    }

    String response;
    do {
      response = availableResponses[Random().nextInt(availableResponses.length)];
    } while (usedResponses.contains(response));

    usedResponses.add(response);
    return response;
  }

  bool detectSpanish(String input) {
    final List<String> spanishKeywords = [
      "quién", "cuando", "presión", "señal", "dónde",
      "música", "bajo", "realidad", "tú", "esto",
      "alta", "mirando", "te", "seguir", "como", "eres",
      "que", "haces", "donde", "estas", "porque", "cuanto",
      "cuantos", "cual", "cualquier"
    ];
    final List<String> englishKeywords = [
      "who", "when", "pressure", "signal", "where",
      "music", "low", "reality", "you", "this",
      "high", "watching", "following", "how", "are",
      "what", "do", "why", "how", "many", "which", "any"
    ];

    int spanishCount =
        spanishKeywords.where((word) => input.contains(word)).length;
    int englishCount =
        englishKeywords.where((word) => input.contains(word)).length;

    return spanishCount > englishCount;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double chatWidth = screenWidth < 600 ? screenWidth * 0.85 : 300;
    double chatHeight = screenHeight < 700 ? screenHeight * 0.5 : 400;

    double chatBottomPadding = screenHeight < 700 ? screenHeight * 0.25 : 90;
    double chatFloatingPadding = screenHeight < 700 ? screenHeight * 0.12 : 30;

    double buttonSize = screenWidth < 600 ? 50 : 60; // ✅ Floating button scales

    return Stack(
      children: [
        Positioned(
          bottom: chatFloatingPadding,
          right: screenWidth < 400 ? 10 : 20,
          child: FloatingActionButton(
            onPressed: () {
              setState(() {
                isChatOpen = !isChatOpen;
                if (isChatOpen) {
                  Future.delayed(Duration(milliseconds: 200), () {
                    _inputFocusNode.requestFocus();
                  });
                }
              });
            },
            backgroundColor: Colors.black,
            child: Icon(
              isChatOpen ? Icons.close : Icons.chat_bubble_outline,
              color: Colors.yellow,
              size: buttonSize * 0.5,
            ),
            shape: CircleBorder(),
            elevation: 5,
            heroTag: "chatbot_fab",
            mini: screenWidth < 400,
          ),
        ),

        if (isChatOpen)
          Positioned(
            bottom: chatBottomPadding,
            right: 20,
            child: Container(
              width: chatWidth,
              height: chatHeight,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.9),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.yellow, width: 2),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "AI TERMINAL v3.22",
                      style: GoogleFonts.orbitron(
                        fontSize: screenWidth < 600 ? 12 : 14,
                        color: Colors.yellow,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Divider(color: Colors.yellow),

                  Expanded(
                    child: ListView(
                      controller: _scrollController,
                      children: chatMessages.map((msg) {
                        return Align(
                          alignment: msg.containsKey("user")
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                            child: Text(
                              msg.values.first,
                              style: GoogleFonts.orbitron(
                                fontSize: screenWidth < 600 ? 14 : 16,
                                color: msg.containsKey("user") ? Colors.yellow : Colors.white,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // ✅ Fixed input area with proper height
                  Container(
                    height: 50,
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            focusNode: _inputFocusNode,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Ask something...",
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                            ),
                            onSubmitted: handleUserMessage,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.send, color: Colors.yellow),
                          onPressed: () => handleUserMessage(_messageController.text),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
