import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final String userName = authProvider.userProfile?.fullName ?? 'User';
    final String phone = '+961 71 365 925';
    final String whatsapp = '+961 71 365 925';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          children: [
            // Profile header
            Center(
              child: Column(
                children: [
                  authProvider.userProfile?.imageUrl != null &&
                          authProvider.userProfile!.imageUrl!.isNotEmpty
                      ? CircleAvatar(
                        radius: 44,
                        backgroundColor: const Color(0xFF4F8FFF),
                        backgroundImage: NetworkImage(
                          authProvider.userProfile!.imageUrl!,
                        ),
                      )
                      : CircleAvatar(
                        radius: 44,
                        backgroundColor: const Color(0xFF4F8FFF),
                        child: Text(
                          (userName.isNotEmpty ? userName[0] : 'U')
                              .toUpperCase(),
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  const SizedBox(height: 16),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Settings
            ListTile(
              leading: const Icon(Icons.settings, color: Color(0xFF4F8FFF)),
              title: const Text('Settings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfilePage(),
                  ),
                );
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: Colors.white,
            ),
            const SizedBox(height: 12),
            
            const SizedBox(height: 12),
           
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text(
                          'Are you sure you want to log out?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              final authProvider = Provider.of<AuthProvider>(
                                context,
                                listen: false,
                              );
                              authProvider.signOut();
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/login',
                                (route) => false,
                              );
                            },
                            child: const Text(
                              'Logout',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        ],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                );
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: Colors.white,
            ),
            const SizedBox(height: 32),
            // Our website
            ListTile(
              leading: const Icon(Icons.language, color: Color(0xFF4F8FFF)),
              title: const Text('Our Website'),
              trailing: Icon(Icons.open_in_new, color: Colors.grey[600]),
              onTap: () async {
                // Open website using url_launcher
                final Uri url = Uri.parse('https://www.tarektravel.com');
                try {
                  bool canLaunch = await canLaunchUrl(url);
                  if (canLaunch) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Could not launch website'),
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: Colors.white,
            ),
            const SizedBox(height: 24),
            // About us
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'About Us',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF4F8FFF),
                ),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.phone, color: Color(0xFF4F8FFF)),
                        const SizedBox(width: 10),
                        Text(phone, style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.whatshot_rounded,
                          color: Color(0xFF25D366),
                        ),
                        const SizedBox(width: 10),
                        Text(whatsapp, style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.email, color: Color(0xFF4F8FFF)),
                        const SizedBox(width: 10),
                        Text(
                          'tarekaldali1@gmail.com',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            currentIndex: 2, // Profile tab
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
              if (authProvider.userProfile?.role == 'admin')
                const BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard),
                  label: 'Admin',
                ),
            ],
            onTap: (index) {
              if (index == 0) {
                Navigator.pushReplacementNamed(context, '/home');
              } else if (index == 1) {
                Navigator.pushReplacementNamed(context, '/bookings');
              } else if (authProvider.userProfile?.role == 'admin' &&
                  index == 3) {
                Navigator.pushReplacementNamed(context, '/admin/dashboard');
              } // index 2 is profile, do nothing
            },
          ),
        ),
      ),
    );
  }
}
