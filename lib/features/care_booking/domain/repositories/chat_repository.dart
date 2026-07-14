import '../entities/chat_message.dart';

abstract class ChatRepository {
  Future<List<ChatMessage>> getChatHistory(String bookingId);
  Future<void> sendMessage(ChatMessage message);
  Stream<ChatMessage> getRealTimeMessages(String bookingId);
}
