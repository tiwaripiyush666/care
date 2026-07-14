import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/booking_repository.dart';

// --- Events ---
abstract class BookingEvent {}

class CreateBookingEvent extends BookingEvent {
  final Map<String, dynamic> bookingData;
  CreateBookingEvent(this.bookingData);
}

class LoadBookingsEvent extends BookingEvent {}

class SyncOfflineBookingsEvent extends BookingEvent {}

// --- States ---
abstract class BookingState {}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingCreated extends BookingState {}

class BookingsLoaded extends BookingState {
  final List<Map<String, dynamic>> bookings;
  BookingsLoaded(this.bookings);
}

class BookingError extends BookingState {
  final String message;
  BookingError(this.message);
}

// --- Bloc ---
class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepository bookingRepository;

  BookingBloc({required this.bookingRepository}) : super(BookingInitial()) {
    on<CreateBookingEvent>(_onCreateBooking);
    on<LoadBookingsEvent>(_onLoadBookings);
    on<SyncOfflineBookingsEvent>(_onSyncOfflineBookings);
  }

  Future<void> _onCreateBooking(CreateBookingEvent event, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    try {
      await bookingRepository.createBooking(event.bookingData);
      emit(BookingCreated());
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> _onLoadBookings(LoadBookingsEvent event, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    try {
      final bookings = await bookingRepository.fetchBookings();
      emit(BookingsLoaded(bookings));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> _onSyncOfflineBookings(SyncOfflineBookingsEvent event, Emitter<BookingState> emit) async {
    try {
      await bookingRepository.syncOfflineBookings();
    } catch (e) {
      debugPrint('SyncOfflineBookingsEvent error: $e');
    }
  }
}
