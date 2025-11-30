import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../models/trip_model.dart';
import '../services/supabase_service.dart';

class BookingProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  List<Booking> _bookings = [];
  bool _isLoading = false;
  String? _error;

  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch all bookings for the current user
  Future<void> fetchUserBookings() async {
    _setLoading(true);
    try {
      final user = _supabaseService.client.auth.currentUser;
      if (user == null) {
        _error = 'User not authenticated';
        _setLoading(false);
        return;
      }

      print('DEBUG: Fetching bookings for user: ${user.id}');

      // Get the user's bookings with joined trip data
      final response = await _supabaseService.client
          .from('bookings')
          .select('*, trip:trips(*)') // Note: renamed to 'trip' for clarity
          .eq('user_id', user.id)
          .order('booking_date', ascending: false);

      print('DEBUG: Found ${response.length} bookings for user');

      if (response.isNotEmpty) {
        // Process each booking to extract trip data properly
        _bookings = [];

        for (var bookingData in response) {
          try {
            // Extract trip data - in Supabase it should be returned as a nested object
            final tripData = bookingData['trip'];
            print(
              'DEBUG: Processing booking ID: ${bookingData['id']} with trip data: $tripData',
            );
            print(
              'DEBUG: Creating Booking object with data: ${bookingData['id']}, status: ${bookingData['status']}',
            );
            final booking = Booking(
              id: bookingData['id']?.toString() ?? '',
              userId: bookingData['user_id']?.toString() ?? '',
              tripId:
                  bookingData['trip_id'], // Keep original format for trip ID
              bookingDate:
                  bookingData['booking_date'] != null
                      ? DateTime.parse(bookingData['booking_date'])
                      : null,
              status: bookingData['status'] ?? 'confirmed',
              tripData:
                  tripData, // This could be null - check BookingTile handles this
            );

            _bookings.add(booking);
          } catch (e) {
            print('DEBUG: Error processing booking: $e');
            // Continue to next booking if there's an error with this one
          }
        }

        _error = null;
        if (_bookings.isEmpty) {
          _error = 'Failed to process bookings data';
        }
      } else {
        _bookings = [];
        _error = null; // No bookings is a valid state, not an error
      }
    } catch (e) {
      _error = 'Error fetching bookings: ${e.toString()}';
      _bookings = [];
      print('DEBUG: Error in fetchUserBookings: $e');
    }

    _setLoading(false);
  }

  // Book a trip for the current user
  Future<bool> bookTrip(Trip trip) async {
    _setLoading(true);
    try {
      final user = _supabaseService.client.auth.currentUser;
      if (user == null) {
        _error = 'User not authenticated';
        print('DEBUG: User not authenticated when booking trip');
        _setLoading(false);
        return false;
      }
      print(
        'DEBUG: Booking trip ${trip.id} for user ${user.id}',
      ); // Handle the trip ID which could be an integer or a UUID string
      print(
        'DEBUG: Original trip ID before processing: "${trip.id}" (${trip.id.runtimeType})',
      );

      // Instead of forcing it to be an integer, we'll use it as is but handle different formats
      dynamic tripId = trip.id;

      // If it looks like a number, try to parse it to an integer
      if (trip.id.trim().contains(RegExp(r'^[0-9]+$'))) {
        try {
          tripId = int.parse(trip.id);
          print('DEBUG: Trip ID parsed to integer: $tripId');
        } catch (e) {
          print(
            'DEBUG: Trip ID appears to be numeric but parsing failed: \\${e.toString()}',
          );
          // Continue with the string representation
        }
      } else if (trip.id.trim().isEmpty) {
        _error = 'Trip ID is empty or invalid';
        print('DEBUG: Empty trip ID encountered');
        _setLoading(false);
        return false;
      } else {
        print('DEBUG: Trip ID is not numeric, using as is: $tripId');
      }

      // Check for available seats before booking
      if (trip.seats == null || trip.seats! <= 0) {
        _error = 'No seats available for this trip.';
        print('DEBUG: No seats available for this trip.');
        _setLoading(false);
        return false;
      }

      print(
        'DEBUG: Final trip ID to be used: $tripId (${tripId.runtimeType})',
      ); // Check if the user already booked this trip
      try {
        final existing =
            await _supabaseService.client
                .from('bookings')
                .select('id, status')
                .eq('user_id', user.id)
                .eq('trip_id', tripId)
                .not('status', 'eq', 'cancelled')
                .maybeSingle();

        if (existing != null) {
          _error = 'You have already booked this trip';
          print('DEBUG: User already booked this trip');
          _setLoading(false);
          return false;
        }
      } catch (e) {
        print('DEBUG: Error checking existing booking: $e');
        // Continue with booking attempt even if check fails
      }

      final bookingData = {
        'user_id': user.id,
        'trip_id': tripId,
        'booking_date': DateTime.now().toIso8601String(),
        'status': 'confirmed',
      };
      print('DEBUG: Inserting booking data: $bookingData');
      print(
        'DEBUG: Trip ID type being sent to database: ${tripId.runtimeType}',
      );
      try {
        // Try inserting with returning all fields
        final response =
            await _supabaseService.client
                .from('bookings')
                .insert(bookingData)
                .select();

        print('DEBUG: Booking insertion complete with response: $response');
        if (response.isNotEmpty) {
          print(
            'DEBUG: Booking successful, created booking ID: \\${response[0]['id']}',
          );
          // Decrease seats count after successful booking
          if (trip.seats != null && trip.seats! > 0) {
            await _supabaseService.client
                .from('trips')
                .update({'seats': trip.seats! - 1})
                .eq('id', tripId);
            print('DEBUG: Decreased seats for trip ID: \\${trip.id}');
          }
        } else {
          print('DEBUG: Booking created but no response returned');
        }
      } catch (e) {
        print('DEBUG: Error inserting booking record: $e');

        if (e.toString().contains('invalid input syntax for type integer')) {
          _error =
              'Trip ID format is incompatible with the database. Please contact support.';
          print(
            'DEBUG: Trip ID format error - database expects integer but received: $tripId',
          );
          _setLoading(false);
          return false;
        }

        throw e; // Re-throw other errors to be caught by the outer catch block
      } // Update seats count (optional, depending on your business logic)
      print('DEBUG: Updating trip seats for trip ID: ${trip.id}');
      if (trip.seats != null && trip.seats! > 0) {
        await _supabaseService.client
            .from('trips')
            .update({'seats': trip.seats! - 1})
            .eq('id', tripId); // Using the potentially parsed tripId
      }

      await fetchUserBookings(); // Refresh booking list
      _error = null;
      return true;
    } catch (e) {
      if (e.toString().contains('foreign key constraint')) {
        _error = 'This trip cannot be booked. Please contact support.';
      } else {
        _error = 'Failed to book trip: ${e.toString()}';
      }
      print('DEBUG: Error booking trip: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Cancel a booking
  Future<bool> cancelBooking(String bookingId) async {
    _setLoading(true);
    print(
      'DEBUG: Attempting to cancel booking with ID: $bookingId (${bookingId.runtimeType})',
    );
    try {
      final user = _supabaseService.client.auth.currentUser;
      if (user == null) {
        _error = 'User not authenticated';
        print('DEBUG: User not authenticated when cancelling booking');
        _setLoading(false);
        return false;
      }

      // Ensure we have a non-null and non-empty value to work with
      if (bookingId.isEmpty) {
        _error = 'Invalid booking ID';
        print('DEBUG: Empty booking ID provided');
        _setLoading(false);
        return false;
      }

      // Clean the booking ID - remove null characters that cause Postgres errors
      final cleanId = bookingId.replaceAll('\u0000', '');
      if (cleanId != bookingId) {
        print('DEBUG: Removed null characters from booking ID');
      }

      print('DEBUG: Using booking ID: $cleanId');
      // First, find the booking to verify ownership
      print('DEBUG: Checking booking ownership for user ${user.id}');
      final booking =
          await _supabaseService.client
              .from('bookings')
              .select()
              .eq('id', cleanId)
              .eq('user_id', user.id)
              .maybeSingle();

      if (booking == null) {
        _error = 'Booking not found or not authorized';
        print('DEBUG: Booking not found or not authorized');
        _setLoading(false);
        return false;
      }

      print('DEBUG: Found booking, updating status to cancelled');
      // Update booking status to cancelled
      final response =
          await _supabaseService.client
              .from('bookings')
              .update({'status': 'cancelled'})
              .eq('id', cleanId)
              .select();
      print('DEBUG: Cancel response: $response');

      await fetchUserBookings(); // Refresh booking list
      _error = null;
      return true;
    } catch (e) {
      _error = 'Failed to cancel booking: ${e.toString()}';
      print('DEBUG: Error cancelling booking: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete a booking completely
  Future<bool> deleteBooking(dynamic bookingId) async {
    _setLoading(true);
    print(
      'DEBUG: Attempting to delete booking with ID: $bookingId (${bookingId.runtimeType})',
    );
    try {
      final user = _supabaseService.client.auth.currentUser;
      if (user == null) {
        _error = 'User not authenticated';
        _setLoading(false);
        return false;
      }

      // Ensure we have a non-null value to work with
      if (bookingId == null) {
        _error = 'Invalid booking ID';
        print('DEBUG: Null booking ID provided');
        _setLoading(false);
        return false;
      }

      // First, find the booking to verify ownership
      final booking =
          await _supabaseService.client
              .from('bookings')
              .select()
              .eq('id', bookingId)
              .eq('user_id', user.id)
              .maybeSingle();

      if (booking == null) {
        _error = 'Booking not found or not authorized';
        _setLoading(false);
        return false;
      }

      print('DEBUG: Deleting booking with ID: $bookingId');

      // Delete the booking record completely
      await _supabaseService.client
          .from('bookings')
          .delete()
          .eq('id', bookingId);

      await fetchUserBookings(); // Refresh booking list
      _error = null;
      return true;
    } catch (e) {
      _error = 'Failed to delete booking: ${e.toString()}';
      print('DEBUG: Error deleting booking: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
