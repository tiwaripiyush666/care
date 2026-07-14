abstract class BookingRepository {
  Future<void> createBooking(Map<String, dynamic> bookingData);
  Future<List<Map<String, dynamic>>> fetchBookings();
}
