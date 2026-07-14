class ChatMessage {
  final String id;
  final String bookingId;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isMe;

  ChatMessage({
    required this.id,
    required this.bookingId,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.isMe,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'isMe': isMe,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String,
      senderId: json['senderId'] as String,
      text: json['text'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isMe: json['isMe'] as bool,
    );
  }
}
