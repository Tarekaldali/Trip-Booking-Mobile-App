// Booking model for 'bookings' table
class Booking {
  final String id; // Use String to handle UUID safely
  final String userId;
  final dynamic tripId; // Keep as dynamic to handle different trip ID formats
  final DateTime? bookingDate;
  final String? status;
  final Map<String, dynamic>? tripData;

  Booking({
    required this.id,
    required this.userId,
    required this.tripId,
    this.bookingDate,
    this.status = 'confirmed',
    this.tripData,
  });
  factory Booking.fromMap(Map<String, dynamic> map) {
    // Always convert ID to string to handle UUID properly
    final id = map['id']?.toString() ?? '';

    // Keep tripId in its original format (could be UUID string or int)
    final tripId = map['trip_id'];

    return Booking(
      id: id,
      userId: map['user_id']?.toString() ?? '',
      tripId: tripId,
      bookingDate:
          map['booking_date'] != null
              ? DateTime.parse(map['booking_date'])
              : null,
      status: map['status']?.toString(),
      tripData: map['trips'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'trip_id': tripId,
      'booking_date': bookingDate?.toIso8601String(),
      'status': status,
    };
  }
}
