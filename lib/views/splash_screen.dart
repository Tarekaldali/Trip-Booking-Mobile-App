import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkAuthSession();

    if (!mounted) return;

    if (authProvider.isAuthenticated) {
      if (authProvider.userProfile?.role == 'admin') {
        Navigator.of(context).pushReplacementNamed('/admin/dashboard');
      } else if (authProvider.userProfile?.fullName == null ||
          authProvider.userProfile!.fullName!.isEmpty) {
        Navigator.of(context).pushReplacementNamed('/complete-profile');
      } else {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              width: 120,
              height: 120,
              errorBuilder:
                  (context, error, stackTrace) => const Icon(
                    Icons.travel_explore,
                    size: 80,
                    color: Color(0xFF4F8FFF),
                  ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: Color(0xFF4F8FFF)),
            const SizedBox(height: 16),
            const Text(
              'Loading...',
              style: TextStyle(
                color: Color(0xFF4F8FFF),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
