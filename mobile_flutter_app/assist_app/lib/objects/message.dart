class ChatMessage {
  final String text;
  final bool isSentByMe;

  ChatMessage({required this.text, required this.isSentByMe});

  Map<String, dynamic> toJson() => {
        'message': text,
        'isSentByMe': isSentByMe,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['message'],
      isSentByMe: json['isSentByMe'],
    );
  }
}
