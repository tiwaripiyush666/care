import 'package:flutter_test/flutter_test.dart';
import 'package:caresphere/features/care_booking/domain/entities/chat_message.dart';
import 'package:caresphere/features/care_booking/presentation/bloc/chat_bloc.dart';
import 'package:caresphere/features/care_booking/data/repositories/chat_repository_impl.dart';

void main() {
  group('Chat BLoC & Caching Repository Tests', () {
    late ChatRepositoryImpl chatRepository;
    late ChatBloc chatBloc;

    setUp(() {
      chatRepository = ChatRepositoryImpl();
      chatBloc = ChatBloc(chatRepository: chatRepository);
    });

    tearDown(() {
      chatBloc.close();
    });

    test('Initial State is ChatInitial', () {
      expect(chatBloc.state, isA<ChatInitial>());
    });

    test('Loading Chat History emits Welcome Message and subscribes successfully', () async {
      final bookingId = 'test_booking_id_999';
      
      // Load history
      chatBloc.add(LoadChatHistory(bookingId));

      await expectLater(
        chatBloc.stream,
        emitsInOrder([
          isA<ChatLoading>(),
          isA<ChatHistoryLoaded>(),
        ]),
      );

      final state = chatBloc.state as ChatHistoryLoaded;
      expect(state.messages.length, equals(1));
      expect(state.messages.first.text, contains('Welcome'));
    });

    test('Sending Message appends to list and schedules mock provider response', () async {
      final bookingId = 'test_booking_id_888';

      // Load initial history first
      chatBloc.add(LoadChatHistory(bookingId));
      await chatBloc.stream.firstWhere((state) => state is ChatHistoryLoaded);

      final userMsg = ChatMessage(
        id: 'msg_user_1',
        bookingId: bookingId,
        senderId: 'client_me',
        text: 'Hello, please get some water.',
        timestamp: DateTime.now(),
        isMe: true,
      );

      // Send message
      chatBloc.add(SendChatMessage(userMsg));

      // Wait for BLoC stream update
      await chatBloc.stream.firstWhere((state) {
        if (state is ChatHistoryLoaded) {
          return state.messages.any((m) => m.id == 'msg_user_1');
        }
        return false;
      });

      var state = chatBloc.state as ChatHistoryLoaded;
      expect(state.messages.any((m) => m.text == 'Hello, please get some water.'), isTrue);

      // Verify that mock provider reply is triggered in 2 seconds and received by bloc stream
      await expectLater(
        chatBloc.stream,
        emitsThrough(isA<ChatHistoryLoaded>()),
      );

      state = chatBloc.state as ChatHistoryLoaded;
      // Should have 3 messages now: Welcome, Client Message, Provider Reply
      expect(state.messages.length, equals(3));
    });
  });
}
