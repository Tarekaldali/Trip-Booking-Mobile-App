import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/booking_model.dart';
import '../../providers/booking_provider.dart';

class BookingDetailsPage extends StatefulWidget {
  final Booking booking;
  const BookingDetailsPage({Key? key, required this.booking}) : super(key: key);

  @override
  State<BookingDetailsPage> createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage> {
  late String bookingStatus;

  @override
  void initState() {
    super.initState();
    bookingStatus = widget.booking.status ?? 'confirmed';
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.booking.tripData ?? {};
    final bookingProvider = Provider.of<BookingProvider>(
      context,
      listen: false,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
        backgroundColor: const Color(0xFF4F8FFF),
        elevation: 2,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display booking status at the top
            if (bookingStatus == 'cancelled')
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.redAccent),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.redAccent),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This booking has been cancelled',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Center(
              child:
                  trip['image'] != null && trip['image'].toString().isNotEmpty
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          trip['image'],
                          width: 180,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      )
                      : Container(
                        width: 180,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.image,
                          size: 48,
                          color: Colors.grey,
                        ),
                      ),
            ),
            const SizedBox(height: 24),
            Text(
              trip['title'] ?? 'Trip',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (trip['location'] != null)
              Row(
                children: [
                  const Icon(Icons.place, size: 18, color: Colors.blueAccent),
                  const SizedBox(width: 4),
                  Text(trip['location'], style: const TextStyle(fontSize: 15)),
                ],
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: Colors.deepPurple,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.booking.bookingDate != null
                      ? widget.booking.bookingDate!.toLocal().toString().split(
                        ' ',
                      )[0]
                      : '',
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 14,
                  color:
                      bookingStatus == 'cancelled'
                          ? Colors.redAccent
                          : Colors.green,
                ),
                const SizedBox(width: 6),
                Text(
                  bookingStatus.isNotEmpty
                      ? bookingStatus[0].toUpperCase() +
                          bookingStatus.substring(1)
                      : 'Confirmed',
                  style: TextStyle(
                    fontSize: 15,
                    color:
                        bookingStatus == 'cancelled'
                            ? Colors.redAccent
                            : Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            if (bookingStatus != 'cancelled')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancel Booking'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    print(
                      'DEBUG: Cancel button pressed for booking \\${widget.booking.id}',
                    );
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder:
                          (ctx) => AlertDialog(
                            title: const Text('Cancel Booking'),
                            content: const Text(
                              'Are you sure you want to cancel this booking?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('No'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Yes'),
                              ),
                            ],
                          ),
                    );
                    if (confirm == true) {
                      print(
                        'DEBUG: Confirmed, calling cancelBooking with ID: \\${widget.booking.id} (\\${widget.booking.id.runtimeType})',
                      );
                      bool success = false;
                      try {
                        // Pass the booking ID directly in its original format
                        print(
                          'DEBUG: Using booking ID directly: \\${widget.booking.id}',
                        );
                        success = await bookingProvider.cancelBooking(
                          widget.booking.id,
                        );
                      } catch (e) {
                        // Optionally handle error
                      }
                      if (success) {
                        print('DEBUG: Booking cancelled successfully');
                        if (mounted) {
                          setState(() {
                            bookingStatus = 'cancelled';
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Booking cancelled successfully'),
                            ),
                          );
                          // Optionally: Navigator.pop(context, true);
                        }
                      } else {
                        print('DEBUG: Failed to cancel booking');
                        final error =
                            bookingProvider.error ??
                            'Failed to cancel booking.';
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $error')),
                          );
                        }
                      }
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
