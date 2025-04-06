import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../services/auth_service.dart'; // Add this import

class AICoachChatScreen extends StatefulWidget {
  const AICoachChatScreen({Key? key}) : super(key: key);

  @override
  _AICoachChatScreenState createState() => _AICoachChatScreenState();
}

class _AICoachChatScreenState extends State<AICoachChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _inputScrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  bool _animationDone = true;

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
    String message = _controller.text.trim();
    setState(() {
      _messages.add({'role': 'user', 'content': message});
      _isLoading = true;
    });

    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/user/chat'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({"query": message}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _animationDone = false;
          _messages.add({'role': 'assistant', 'content': data['response']});
        });
      } else {
        final errorData = json.decode(response.body);
        setState(() {
          _animationDone = false;
          _messages.add({
            'role': 'assistant',
            'content': errorData['error'] ?? "Error: ${response.statusCode}"
          });
        });
      }
    } catch (e) {
      setState(() {
        _animationDone = false;
        _messages.add({
          'role': 'assistant',
          'content': "Failed to connect to the server. Please try again."
        });
      });
    }

    setState(() {
      _isLoading = false;
      _controller.clear();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _inputScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Coach Chat",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                bool isAssistant = msg['role'] == 'assistant';
                final bool isLastAssistant =
                    isAssistant && index == _messages.length - 1;
                return Align(
                  alignment: isAssistant
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isAssistant ? Colors.grey[300] : Colors.blueAccent,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isAssistant
                            ? const Radius.circular(0)
                            : const Radius.circular(16),
                        bottomRight: isAssistant
                            ? const Radius.circular(16)
                            : const Radius.circular(0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: isLastAssistant && !_animationDone
                        ? AnimatedTextKit(
                            animatedTexts: [
                              TyperAnimatedText(
                                msg['content']!,
                                textStyle: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                ),
                                speed: const Duration(milliseconds: 10),
                              )
                            ],
                            isRepeatingAnimation: false,
                            onFinished: () {
                              setState(() {
                                _animationDone = true;
                              });
                            },
                          )
                        : MarkdownBody(
                            data: msg['content']!,
                            styleSheet:
                                MarkdownStyleSheet.fromTheme(Theme.of(context))
                                    .copyWith(
                              p: TextStyle(
                                color:
                                    isAssistant ? Colors.black87 : Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: RawScrollbar(
                    controller: _inputScrollController,
                    thumbColor: Colors.black87,
                    thickness: 14,
                    radius: const Radius.circular(8),
                    thumbVisibility: true,
                    trackVisibility: true,
                    trackColor: Colors.black38,
                    crossAxisMargin: 2,
                    mainAxisMargin: 2,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxHeight: 150,
                        ),
                        child: TextField(
                          controller: _controller,
                          scrollController: _inputScrollController,
                          minLines: 1,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black87),
                          decoration: InputDecoration(
                            hintText: "Enter your query...",
                            hintStyle: const TextStyle(color: Colors.blueGrey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[300],
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _sendMessage,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
