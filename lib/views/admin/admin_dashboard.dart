import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/trip_model.dart';
import '../../providers/trip_provider.dart';
import 'create_trip_page.dart';
import 'edit_trip_page.dart';
import '../booking/my_bookings_page.dart';
import '../home/profile_page.dart';
import '../home/home_page.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  void _openCreateTrip(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: Provider.of<TripProvider>(context, listen: false),
          child: const CreateTripPage(),
        ),
      ),
    );
  }

  void _openEditTrip(BuildContext context, Trip trip) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: Provider.of<TripProvider>(context, listen: false),
          child: EditTripPage(trip: trip),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TripProvider()..fetchTrips(),
      child: Consumer<TripProvider>(
        builder: (context, tripProvider, _) {
          return _AdminDashboardBody(
            tripProvider: tripProvider,
            openEditTrip: _openEditTrip,
            openCreateTrip: _openCreateTrip,
          );
        },
      ),
    );
  }
}

class _AdminDashboardBody extends StatefulWidget {
  final TripProvider tripProvider;
  final void Function(BuildContext, Trip) openEditTrip;
  final void Function(BuildContext) openCreateTrip;
  const _AdminDashboardBody({
    required this.tripProvider,
    required this.openEditTrip,
    required this.openCreateTrip,
  });

  @override
  State<_AdminDashboardBody> createState() => _AdminDashboardBodyState();
}

class _AdminDashboardBodyState extends State<_AdminDashboardBody> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final trips = widget.tripProvider.trips;
    final filteredTrips = searchQuery.isEmpty
        ? trips
        : trips.where((trip) =>
            trip.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
            (trip.location?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
            (trip.description?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false)
          ).toList();
    return Scaffold(
      backgroundColor: Colors.white,
      // Modern sidebar
      drawer: Drawer(
        width: 260,
        child: Container(
          color: const Color(0xFFf7fafd),
          child: Column(
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x114F8FFF),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: const Color(0xFF4F8FFF),
                      child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Admin',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF222B45),
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.dashboard, color: Color(0xFF4F8FFF)),
                title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
                selected: true,
                selectedTileColor: const Color(0x114F8FFF),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.book_online, color: Color(0xFF4F8FFF)),
                title: const Text('Bookings'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MyBookingsPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.person, color: Color(0xFF4F8FFF)),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                  );
                },
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  title: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
                  onTap: () {
                    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.dashboard_customize, color: Color(0xFF4F8FFF), size: 32),
            const SizedBox(width: 12),
            const Text(
              'Admin Dashboard',
              style: TextStyle(
                color: Color(0xFF222B45),
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const Spacer(),
            CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: const Icon(Icons.person, color: Color(0xFF4F8FFF)),
            ),
          ],
        ),
        toolbarHeight: 70,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            children: [
              // Search bar
              Container(
                margin: const EdgeInsets.only(bottom: 18),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search trips...',
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: widget.tripProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : widget.tripProvider.error != null
                        ? Center(child: Text(widget.tripProvider.error!))
                        : filteredTrips.isEmpty
                            ? const Center(child: Text('No trips found.'))
                            : ListView.separated(
                                itemCount: filteredTrips.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 18),
                                itemBuilder: (context, index) {
                                  final trip = filteredTrips[index];
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(18),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.06),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(18),
                                            bottomLeft: Radius.circular(18),
                                          ),
                                          child: trip.image != null && trip.image!.isNotEmpty
                                              ? Image.network(
                                                  trip.image!,
                                                  width: 110,
                                                  height: 110,
                                                  fit: BoxFit.cover,
                                                )
                                              : Container(
                                                  width: 110,
                                                  height: 110,
                                                  color: Colors.grey[200],
                                                  child: const Icon(Icons.image, size: 48, color: Colors.grey),
                                                ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  trip.title,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF222B45),
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.place, size: 15, color: Color(0xFF4F8FFF)),
                                                    const SizedBox(width: 4),
                                                    Expanded(
                                                      child: Text(
                                                        trip.location ?? '',
                                                        style: const TextStyle(
                                                          fontSize: 13,
                                                          color: Color(0xFF4F8FFF),
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  trip.description ?? '',
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.event, size: 15, color: Colors.grey),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '${trip.startDate.toLocal().toString().split(' ')[0]} - ${trip.endDate.toLocal().toString().split(' ')[0]}',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black54,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    const Icon(Icons.people, size: 15, color: Colors.grey),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '${trip.seats ?? 0} seats',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black54,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  '\$${trip.price.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF4F8FFF),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit, color: Color(0xFF4F8FFF)),
                                              onPressed: () => widget.openEditTrip(context, trip),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: Colors.red),
                                              onPressed: () async {
                                                await widget.tripProvider.deleteTrip(trip.id);
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => widget.openCreateTrip(context),
        backgroundColor: const Color(0xFF4F8FFF),
        icon: const Icon(Icons.add),
        label: const Text('Add Trip'),
        elevation: 2,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            currentIndex: 3, // Set to Admin index when on AdminDashboard
            selectedItemColor: const Color(0xFF4F8FFF),
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.white,
            showUnselectedLabels: true,
            elevation: 12,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.book_online), label: 'Bookings'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
              BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Admin'),
            ],
            onTap: (index) {
              if (index == 0) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const HomePage()),
                );
              } else if (index == 1) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MyBookingsPage()),
                );
              } else if (index == 2) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
              } // index 3 is Admin, already here
            },
          ),
        ),
      ),
    );
  }
}
