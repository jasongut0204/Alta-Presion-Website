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
  TextEditingController _messageController = TextEditingController();
  FocusNode _inputFocusNode = FocusNode();
  List<Map<String, String>> chatMessages = [];
  final ScrollController _scrollController = ScrollController();
  bool isBotTyping = false;

  void handleUserMessage(String message) {
    if (message.trim().isEmpty) return;

    setState(() {
      chatMessages.add({"user": message});
      _messageController.clear();
    });

    _scrollToBottom();

    // ✅ Show bot "typing" effect
    setState(() {
      isBotTyping = true;
    });

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        isBotTyping = false;
        chatMessages.add({"bot": ""}); // Empty message for typewriter effect
      });

      _scrollToBottom();
      _simulateTyping(chatMessages.length - 1, getAIResponse(message));
    });

    Future.delayed(Duration(milliseconds: 100), () {
      _inputFocusNode.requestFocus();
    });
  }

  /// **Simulates AI typing effect letter by letter**
  void _simulateTyping(int messageIndex, String fullText) async {
    for (int i = 0; i <= fullText.length; i++) {
      await Future.delayed(Duration(milliseconds: 100)); // Typing speed
      setState(() {
        chatMessages[messageIndex]["bot"] = fullText.substring(0, i);
      });
      _scrollToBottom();
    }
  }

  /// **Scrolls chat to the bottom**
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

  /// **Detects language & returns an AI response**
  String getAIResponse(String input) {
    input = input.toLowerCase();
    bool isSpanish = detectSpanish(input);
    final random = Random();

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
      "Alta Presion is near...",
      "This is not real...",
      "Code activated: 019-X..."
    ];

    return isSpanish
        ? spanishResponses[random.nextInt(spanishResponses.length)]
        : englishResponses[random.nextInt(englishResponses.length)];
  }

  bool detectSpanish(String input) {
    final List<String> spanishWords = ["quién", "cuando", "presión", "señal", "dónde", "música", "bajo", "realidad"];
    for (String word in spanishWords) {
      if (input.contains(word)) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: 30,
          right: 30,
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
            ),
          ),
        ),

        if (isChatOpen)
          Positioned(
            bottom: 90,
            right: 20,
            child: Container(
              width: 300,
              height: 400,
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
                        fontSize: 14,
                        color: Colors.yellow,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Divider(color: Colors.yellow),

                  // **Chat Messages**
                  Expanded(
                    child: ListView(
                      controller: _scrollController,
                      children: [
                        for (var msg in chatMessages)
                          ListTile(
                            title: Text(msg.values.first!,
                                style: GoogleFonts.orbitron(
                                  fontSize: 12,
                                  color: msg.containsKey("user") ? Colors.yellow : Colors.white,
                                )),
                          ),
                        if (isBotTyping)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "...",
                                style: GoogleFonts.orbitron(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // **Input Field & Send Button**
                  Container(
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
