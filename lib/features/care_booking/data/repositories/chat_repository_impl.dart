import 'dart:async';
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final StreamController<ChatMessage> _messageStreamController = StreamController<ChatMessage>.broadcast();
  
  Box? _chatBox;

  Future<Box> _getBox() async {
    if (_chatBox != null && _chatBox!.isOpen) return _chatBox!;
    _chatBox = await Hive.openBox('caresphere_chats');
    return _chatBox!;
  }

  @override
  Future<List<ChatMessage>> getChatHistory(String bookingId) async {
    final box = await _getBox();
    final List<dynamic>? cachedList = box.get(bookingId) as List<dynamic>?;
    if (cachedList != null) {
      return cachedList
          .map((item) => ChatMessage.fromJson(Map<String, dynamic>.from(jsonDecode(item as String))))
          .toList();
    }
    
    // Fallback: Welcome message from the caregiver
    final welcomeMessage = ChatMessage(
      id: 'welcome_$bookingId',
      bookingId: bookingId,
      senderId: 'provider_123',
      text: 'Hello! I have started my journey towards your location. Feel free to message me here.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      isMe: false,
    );
    
    await saveMessage(bookingId, welcomeMessage);
    return [welcomeMessage];
  }

  @override
  Future<void> sendMessage(ChatMessage message) async {
    await saveMessage(message.bookingId, message);
    _messageStreamController.add(message);
    _simulateProviderReply(message);
  }

  @override
  Stream<ChatMessage> getRealTimeMessages(String bookingId) {
    return _messageStreamController.stream.where((msg) => msg.bookingId == bookingId);
  }

  Future<void> saveMessage(String bookingId, ChatMessage message) async {
    final box = await _getBox();
    final List<dynamic> currentRaw = box.get(bookingId) as List<dynamic>? ?? [];
    currentRaw.add(jsonEncode(message.toJson()));
    await box.put(bookingId, currentRaw);
  }

  void _simulateProviderReply(ChatMessage userMsg) {
    final replies = [
      "Noted. I'll make sure to follow that.",
      "Perfect. I am just passing by the main square. See you in a bit!",
      "Received! I will ring the bell once I arrive.",
      "Understood. Thanks for sharing.",
    ];
    
    final replyText = replies[userMsg.text.hashCode % replies.length];

    Timer(const Duration(seconds: 2), () async {
      final replyMsg = ChatMessage(
        id: 'reply_${DateTime.now().millisecondsSinceEpoch}',
        bookingId: userMsg.bookingId,
        senderId: 'provider_123',
        text: replyText,
        timestamp: DateTime.now(),
        isMe: false,
      );
      
      await saveMessage(userMsg.bookingId, replyMsg);
      _messageStreamController.add(replyMsg);
    });
  }
}
