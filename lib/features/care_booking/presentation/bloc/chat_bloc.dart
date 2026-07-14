import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';

// --- Events ---
abstract class ChatEvent {}

class LoadChatHistory extends ChatEvent {
  final String bookingId;
  LoadChatHistory(this.bookingId);
}

class SendChatMessage extends ChatEvent {
  final ChatMessage message;
  SendChatMessage(this.message);
}

class ReceiveRealTimeMessage extends ChatEvent {
  final ChatMessage message;
  ReceiveRealTimeMessage(this.message);
}

// --- States ---
abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatHistoryLoaded extends ChatState {
  final List<ChatMessage> messages;
  ChatHistoryLoaded(this.messages);
}

class ChatError extends ChatState {
  final String message;
  ChatError(this.message);
}

// --- Bloc ---
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository chatRepository;
  StreamSubscription<ChatMessage>? _messageSubscription;

  ChatBloc({required this.chatRepository}) : super(ChatInitial()) {
    on<LoadChatHistory>(_onLoadChatHistory);
    on<SendChatMessage>(_onSendChatMessage);
    on<ReceiveRealTimeMessage>(_onReceiveRealTimeMessage);
  }

  Future<void> _onLoadChatHistory(LoadChatHistory event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final history = await chatRepository.getChatHistory(event.bookingId);
      emit(ChatHistoryLoaded(history));

      // Subscribe to real-time events
      await _messageSubscription?.cancel();
      _messageSubscription = chatRepository.getRealTimeMessages(event.bookingId).listen((msg) {
        add(ReceiveRealTimeMessage(msg));
      });
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onSendChatMessage(SendChatMessage event, Emitter<ChatState> emit) async {
    try {
      await chatRepository.sendMessage(event.message);
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void _onReceiveRealTimeMessage(ReceiveRealTimeMessage event, Emitter<ChatState> emit) {
    if (state is ChatHistoryLoaded) {
      final currentList = List<ChatMessage>.from((state as ChatHistoryLoaded).messages);
      if (!currentList.any((m) => m.id == event.message.id)) {
        currentList.add(event.message);
        emit(ChatHistoryLoaded(currentList));
      }
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }
}
