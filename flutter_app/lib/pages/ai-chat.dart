import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../globals.dart' as globals;

class ChatWithTherapistPage extends StatefulWidget {
  @override
  _ChatWithTherapistPageState createState() => _ChatWithTherapistPageState();
}

class _ChatWithTherapistPageState extends State<ChatWithTherapistPage> {
  final List<Map<String, String>> _chatHistory = [
    {'question': 'Therapist', 'answer': 'How are you feeling today?'}
  ];
  final TextEditingController _userInputController = TextEditingController();
  bool _isTyping = false;

  Future<void> _sendMessage() async {
    final userMessage = _userInputController.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      _chatHistory.add({'question': 'You', 'answer': userMessage});
      _isTyping = true;
    });

    _userInputController.clear();
    FocusScope.of(context).unfocus();

    final response = await http.post(
      Uri.parse('${globals.api_base_url}/chat-ai'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'chats': _chatHistory.map((chat) => {
          'question': chat['question'],
          'answer': chat['answer'],
        }).toList()
      }),
    );

    await Future.delayed(Duration(seconds: 2));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final nextQuestion = data['next_question'] ?? "I'm here to listen if you'd like to share more.";

      setState(() {
        _chatHistory.add({'question': 'Therapist', 'answer': nextQuestion});
        _isTyping = false;
      });
    } else {
      setState(() {
        _chatHistory.add({
          'question': 'Therapist',
          'answer': 'Error: Could not connect to the AI therapist.'
        });
        _isTyping = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with AI Therapist'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                      itemCount: _chatHistory.length + (_isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _chatHistory.length && _isTyping) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: AssetImage('assets/images/ai.png'),
                                  radius: 20.0,
                                ),
                                SizedBox(width: 8.0),
                                Text('Typing...', style: theme.textTheme.bodyMedium),
                                SizedBox(width: 4.0),
                                _buildTypingAnimation(),
                              ],
                            ),
                          );
                        }

                        final chat = _chatHistory[index];
                        final isUser = chat['question'] == 'You';

                        return Align(
                          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 6.0),
                            child: Row(
                              mainAxisAlignment:
                              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                              children: [
                                if (!isUser) ...[
                                  CircleAvatar(
                                    backgroundImage: AssetImage('assets/images/ai.png'),
                                    radius: 20.0,
                                  ),
                                  SizedBox(width: 8.0),
                                ],
                                Flexible(
                                  child: Container(
                                    padding: EdgeInsets.all(12.0),
                                    decoration: BoxDecoration(
                                      color: isUser
                                          ? theme.colorScheme.secondary.withOpacity(0.2)
                                          : theme.colorScheme.primary.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Text(
                                      chat['answer'] ?? '',
                                      style: theme.textTheme.bodyLarge,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: keyboardHeight, // Position the input just above the keyboard
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _userInputController,
                            decoration: InputDecoration(
                              hintText: "Type your response...",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              contentPadding:
                              EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.send, color: theme.colorScheme.primary),
                          onPressed: _sendMessage,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTypingAnimation() {
    return Row(
      children: List.generate(
        3,
            (index) => Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.0),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: 6.0,
            width: 6.0,
            decoration: BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _userInputController.dispose();
    super.dispose();
  }
}
