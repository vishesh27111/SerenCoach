import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/ChatModel.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../globals.dart' as globals;

class ChatsPage extends StatefulWidget {
  @override
  _ChatsPageState createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  late Future<List<ChatModel>> _chats;

  @override
  void initState() {
    super.initState();
    _chats = fetchChats();
  }

  Future<List<ChatModel>> fetchChats() async {
    final response = await http.get(Uri.parse('${globals.api_base_url}/get_chats'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => ChatModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load chats');
    }
  }

  String formatDate(String timestamp) {
    final DateTime dt = DateFormat("yyyy-MM-dd,HH:mm:ss").parse(timestamp);
    return DateFormat("dd/MM/yy").format(dt);
  }

  String formatTime(String timestamp) {
    final DateTime dt = DateFormat("yyyy-MM-dd,HH:mm:ss").parse(timestamp);
    return DateFormat("HH:mm").format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Previous Chats'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
            },
          ),
        ),
      body: FutureBuilder<List<ChatModel>>(
        future: _chats,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No previous chats found.'));
          } else {
            final chats = snapshot.data!;
            return ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Header Centered
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Center(
                        child: Text(
                          formatDate(chat.timestamp),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                    ),
                    // Time Header for the Group
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          formatTime(chat.timestamp),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                    ),
                    // Conversation Messages
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.all(12),
                      margin: EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: chat.conversation.map((c) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SerenCoach: ${c.question}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'You: ${c.answer}',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}
