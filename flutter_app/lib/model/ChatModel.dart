class ChatModel {
  final List<Conversation> conversation;
  final String timestamp;

  ChatModel({required this.conversation, required this.timestamp});

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    var list = json['conversation'] as List;
    List<Conversation> conversations =
    list.map((item) => Conversation.fromJson(item)).toList();
    return ChatModel(
      conversation: conversations,
      timestamp: json['timestamp'],
    );
  }
}

class Conversation {
  final String question;
  final String answer;

  Conversation({required this.question, required this.answer});

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      question: json['question'],
      answer: json['answer'],
    );
  }
}
