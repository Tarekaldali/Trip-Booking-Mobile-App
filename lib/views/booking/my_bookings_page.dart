import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/booking_tile.dart';

class MyBookingsPage extends StatelessWidget {
  const MyBookingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BookingProvider()..fetchUserBookings(),
      child: Consumer<BookingProvider>(
        builder: (context, bookingProvider, _) {
          if (bookingProvider.error != null) {
            return Scaffold(
              backgroundColor: const Color(0xFFF8FAFC),
              body: Center(child: Text(bookingProvider.error!)),
            );
          }
          final bookings = bookingProvider.bookings;
          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            extendBody: true,
            // Modern blue gradient app bar
            body: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF4F8FFF), Color(0xFF6FC8FB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Removed menu icon
                      const SizedBox(width: 0), // keep layout
                      const Text(
                        'My Bookings',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.notifications_none_rounded,
                          size: 28,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                bookings.isEmpty
                    ? const Expanded(
                      child: Center(
                        child: Text(
                          'No bookings yet.',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ),
                    )
                    : Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                        itemCount: bookings.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 28),
                        itemBuilder: (context, index) {
                          final booking = bookings[index];
                          final trip = booking.tripData ?? {};
                          final tripTitle = trip['title'] ?? 'Trip';
                          final tripLocation = trip['location'] ?? '';
                          final tripImage = trip['image'] ?? '';
                          final tripSeats = trip['seats']?.toString() ?? '--';
                          final tripPrice =
                              trip['price'] != null
                                  ? (trip['price'] as num).toDouble()
                                  : null;
                          final tripStart =
                              trip['start_date'] != null
                                  ? DateTime.tryParse(trip['start_date'])
                                  : null;
                          final tripEnd =
                              trip['end_date'] != null
                                  ? DateTime.tryParse(trip['end_date'])
                                  : null;
                          final status = booking.status ?? 'confirmed';
                          return GestureDetector(
                            onTap: () {
                              print(
                                'DEBUG: Booking tapped, navigating to details for booking ${booking.id}',
                              );
                              Navigator.of(context).pushNamed(
                                '/bookingDetails',
                                arguments: booking,
                              );
                            },
                            child: Stack(
                              children: [
                                Container(
                                  height: 180,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(32),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 24,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  left: 0,
                                  top: 0,
                                  bottom: 0,
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(32),
                                      bottomLeft: Radius.circular(32),
                                    ),
                                    child:
                                        tripImage.isNotEmpty
                                            ? Image.network(
                                              tripImage,
                                              width: 120,
                                              height: 180,
                                              fit: BoxFit.cover,
                                            )
                                            : Container(
                                              width: 120,
                                              height: 180,
                                              color: Colors.grey[200],
                                              child: const Icon(
                                                Icons.image,
                                                size: 40,
                                                color: Colors.grey,
                                              ),
                                            ),
                                  ),
                                ),
                                Positioned.fill(
                                  left: 120,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 18,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                tripTitle,
                                                style: const TextStyle(
                                                  fontSize: 19,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF222B45),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    status == 'confirmed'
                                                        ? const Color(
                                                          0xFF4F8FFF,
                                                        ).withOpacity(0.12)
                                                        : Colors.redAccent
                                                            .withOpacity(0.12),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                status == 'confirmed'
                                                    ? 'Confirmed'
                                                    : 'Cancelled',
                                                style: TextStyle(
                                                  color:
                                                      status == 'confirmed'
                                                          ? const Color(
                                                            0xFF4F8FFF,
                                                          )
                                                          : Colors.redAccent,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.location_on,
                                              color: Color(0xFF4F8FFF),
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                tripLocation,
                                                style: const TextStyle(
                                                  color: Color(0xFF4F8FFF),
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.event,
                                              size: 15,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              tripStart != null &&
                                                      tripEnd != null
                                                  ? '${tripStart.toLocal().toString().split(' ')[0]} - ${tripEnd.toLocal().toString().split(' ')[0]}'
                                                  : '',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.people,
                                              size: 15,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '$tripSeats seats',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Text(
                                              tripPrice != null
                                                  ? '\$${tripPrice.toStringAsFixed(2)}'
                                                  : '--',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF4F8FFF),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
              ],
            ),
            drawer: const Drawer(
              // Add your drawer content here
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Consumer<BookingProvider>(
                  builder: (context, bookingProvider, _) {
                    // Check if user is admin
                    final authProvider = Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    );
                    final bool isAdmin =
                        authProvider.userProfile?.role == 'admin';

                    return BottomNavigationBar(
                      currentIndex: 1, // Bookings is selected
                      selectedItemColor: const Color(0xFF4F8FFF),
                      unselectedItemColor: Colors.grey,
                      backgroundColor: Colors.white,
                      showUnselectedLabels: true,
                      elevation: 12,
                      type: BottomNavigationBarType.fixed,
                      items: [
                        const BottomNavigationBarItem(
                          icon: Icon(Icons.home),
                          label: 'Home',
                        ),
                        const BottomNavigationBarItem(
                          icon: Icon(Icons.book_online),
                          label: 'Bookings',
                        ),
                        const BottomNavigationBarItem(
                          icon: Icon(Icons.person),
                          label: 'Profile',
                        ),
                        if (isAdmin)
                          const BottomNavigationBarItem(
                            icon: Icon(Icons.dashboard),
                            label: 'Admin',
                          ),
                      ],
                      onTap: (index) {
                        if (index == 0) {
                          Navigator.pushReplacementNamed(context, '/home');
                        } else if (index == 2) {
                          Navigator.pushReplacementNamed(context, '/profile');
                        } else if (isAdmin && index == 3) {
                          Navigator.pushReplacementNamed(
                            context,
                            '/admin/dashboard',
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: const Color(0xFF4F8FFF),
              elevation: 4,
              onPressed: () {
                bookingProvider.fetchUserBookings();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Refreshing bookings...')),
                );
              },
              child: const Icon(Icons.refresh, size: 28),
              tooltip: 'Refresh Bookings',
            ),
          );
        },
      ),
    );
  }
}
