import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import 'package:provider/provider.dart';
import '../providers/booking_provider.dart';

// import 'booking_details_page.dart';
class BookingTile extends StatelessWidget {
  final Booking booking;
  const BookingTile({Key? key, required this.booking}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final trip = booking.tripData ?? {};
    final tripTitle = trip['title'] ?? 'Trip';
    final tripLocation = trip['location'] ?? '';
    final tripImage = trip['image'] ?? '';
    final bookingDate =
        booking.bookingDate != null
            ? '${booking.bookingDate!.toLocal().toString().split(' ')[0]}'
            : '';
    final status = booking.status ?? 'confirmed';
    Color statusColor;
    switch (status) {
      case 'cancelled':
        statusColor = Colors.redAccent;
        break;
      case 'confirmed':
      default:
        statusColor = Colors.green;
    }
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      color: status == 'cancelled' ? Colors.grey[100] : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          print(
            'DEBUG: BookingTile tapped, navigating to details for booking ${booking.id}',
          );
          // Navigate to booking details
          final result = await Navigator.of(
            context,
          ).pushNamed('/bookingDetails', arguments: booking);

          print('DEBUG: Returned from details with result: $result');

          // If the booking was modified (canceled or deleted), refresh the list
          if (result == true && context.mounted) {
            final bookingProvider = Provider.of<BookingProvider>(
              context,
              listen: false,
            );

            // Show a loading indicator while refreshing
            showDialog(
              context: context,
              barrierDismissible: false,
              builder:
                  (ctx) => const Center(child: CircularProgressIndicator()),
            );

            print(
              'DEBUG: Refreshing bookings list after returning from details',
            );
            // Fetch updated bookings
            await bookingProvider.fetchUserBookings();

            // Dismiss loading indicator
            if (context.mounted) {
              Navigator.of(context).pop();
              print('DEBUG: Refresh complete');
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            children: [
              tripImage.isNotEmpty
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      tripImage,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                              size: 32,
                            ),
                          ),
                    ),
                  )
                  : Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.image,
                      color: Colors.grey,
                      size: 32,
                    ),
                  ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tripTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color:
                            status == 'cancelled' ? Colors.grey : Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (tripLocation.isNotEmpty)
                      Row(
                        children: [
                          const Icon(
                            Icons.place,
                            size: 15,
                            color: Colors.blueAccent,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              tripLocation,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    if (bookingDate.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.deepPurple,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              bookingDate,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(Icons.circle, size: 12, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        status[0].toUpperCase() + status.substring(1),
                        style: TextStyle(
                          fontSize: 13,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (status == 'cancelled')
                    const Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Cancelled',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
