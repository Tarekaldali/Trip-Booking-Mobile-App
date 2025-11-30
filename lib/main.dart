import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'views/auth/login_page.dart';
import 'views/auth/register_page.dart';
import 'views/home/home_page.dart';
import 'services/supabase_service.dart';
import 'views/auth/complete_profile_page.dart';
import 'views/admin/admin_dashboard.dart';
import 'views/booking/booking_details_page.dart';
import 'models/booking_model.dart';
import '../providers/booking_provider.dart';
import 'views/booking/my_bookings_page.dart';
import 'views/home/profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService().initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AuthProvider _authProvider;
  bool _isInitialized = false;
  String _initialRoute = '/login';

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider();
    _checkAuthAndSetRoute();
  }

  Future<void> _checkAuthAndSetRoute() async {
    final hasSession = await _authProvider.checkAuthSession();

    if (hasSession) {
      if (_authProvider.userProfile?.role == 'admin') {
        _initialRoute = '/admin/dashboard';
      } else if (_authProvider.userProfile?.fullName == null ||
          _authProvider.userProfile!.fullName!.isEmpty) {
        _initialRoute = '/complete-profile';
      } else {
        _initialRoute = '/home';
      }
    }

    setState(() {
      _isInitialized = true;
    });
  }

  // Navigate to the appropriate screen based on the initial route
  Widget _buildInitialScreen() {
    switch (_initialRoute) {
      case '/home':
        return const HomePage();
      case '/admin/dashboard':
        return const AdminDashboard();
      case '/complete-profile':
        return const CompleteProfilePage();
      case '/profile':
        return const ProfilePage();
      case '/bookings':
        return const MyBookingsPage();
      case '/register':
        return const RegisterPage();
      default:
        return const LoginPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => _authProvider,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Trip Booking App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home:
            _isInitialized
                ? _buildInitialScreen()
                : const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(color: Color(0xFF4F8FFF)),
                  ),
                ),
        routes: {
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/complete-profile': (context) => const CompleteProfilePage(),
          '/home': (context) => const HomePage(),
          '/admin/dashboard': (context) => const AdminDashboard(),
          '/bookings': (context) => const MyBookingsPage(),
          '/profile': (context) => const ProfilePage(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/bookingDetails') {
            // Safely handle booking argument
            final booking = settings.arguments as Booking?;
            if (booking == null) {
              return MaterialPageRoute(
                builder:
                    (context) => Scaffold(
                      appBar: AppBar(title: const Text('Error')),
                      body: const Center(
                        child: Text('Booking information not found'),
                      ),
                    ),
              );
            }

            return MaterialPageRoute(
              builder:
                  (context) => ChangeNotifierProvider(
                    create: (_) => BookingProvider(),
                    child: BookingDetailsPage(booking: booking),
                  ),
            );
          }
          return null;
        },
      ),
    );
  }
}
