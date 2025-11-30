import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/trip_model.dart';
import '../../providers/booking_provider.dart';

class TripDetailPage extends StatelessWidget {
  final Trip trip;
  const TripDetailPage({Key? key, required this.trip}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // Debug information about the trip ID
    print(
      'DEBUG: Trip Detail - ID: "${trip.id}" of type ${trip.id.runtimeType}',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(trip.title),
        backgroundColor: const Color(0xFF4F8FFF),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (trip.image != null && trip.image!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  trip.image!,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 20),
            Text(
              trip.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            if (trip.location != null && trip.location!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFF4F8FFF)),
                    const SizedBox(width: 6),
                    Text(
                      trip.location!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF4F8FFF),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.event, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  '${trip.startDate.toLocal().toString().split(' ')[0]} - ${trip.endDate.toLocal().toString().split(' ')[0]}',
                  style: const TextStyle(fontSize: 15, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.people, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  '${trip.seats ?? 0} seats',
                  style: const TextStyle(fontSize: 15, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Description',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              trip.description ?? 'No description',
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${trip.price.toStringAsFixed(2)} USD',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4F8FFF),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F8FFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () async {
                    // Show confirmation dialog first
                    final bool? confirmBooking = await showDialog<bool>(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Confirm Booking'),
                            content: Text(
                              'Would you like to book "${trip.title}"?',
                            ),
                            actions: [
                              TextButton(
                                onPressed:
                                    () => Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed:
                                    () => Navigator.of(context).pop(true),
                                child: const Text('Book Now'),
                              ),
                            ],
                          ),
                    );

                    if (confirmBooking != true) {
                      return; // User cancelled booking
                    }

                    final bookingProvider = Provider.of<BookingProvider>(
                      context,
                      listen: false,
                    );

                    // Show loading indicator
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder:
                          (ctx) =>
                              const Center(child: CircularProgressIndicator()),
                    );

                    try {
                      final success = await bookingProvider.bookTrip(trip);

                      // Hide loading indicator
                      if (context.mounted) Navigator.pop(context);

                      if (success) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Trip booked successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } else {
                        final error =
                            bookingProvider.error ?? 'Failed to book trip';
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $error'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      // Hide loading indicator
                      if (context.mounted) Navigator.pop(context);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.book_online, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Book Now',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
