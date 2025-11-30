import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _error;

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _authService.currentUser != null;
  bool get isLoggedIn => _userProfile != null;
  String? get userEmail {
    final user = _authService.currentUser;
    return user?.email;
  }

  // Check if user has an active session
  Future<bool> checkAuthSession() async {
    _setLoading(true);
    try {
      // Get the current session directly from auth service
      final session = _authService.currentSession;
      if (session != null) {
        await fetchUserProfile();
        _setLoading(false);
        return true;
      }
    } catch (e) {
      print('Error checking auth session: $e');
    }
    _setLoading(false);
    return false;
  }

  Future<void> signUp(String email, String password) async {
    _setLoading(true);
    _error = null;
    try {
      final response = await _authService.signUp(
        email: email,
        password: password,
      );
      print(
        'DEBUG: signUp response.user = \${response.user}, response.session = \${response.session}, response = \${response}',
      );
      if (response.user != null && response.session != null) {
        // Insert user into profiles table
        await _authService.client.from('profiles').insert({
          'id': response.user!.id,
          'full_name': null,
          'role': 'user',
          'created_at': DateTime.now().toIso8601String(),
          'email': email,
          'password': password, // Not recommended to store plain password!
        });
        await fetchUserProfile();
      } else if (response.user != null && response.session == null) {
        // User created but needs email confirmation
        await fetchUserProfile();
      } else {
        _error = "Registration failed. Please try again.";
      }
    } on AuthException catch (e) {
      print('DEBUG: AuthException: \${e.message}');
      if (e.message.toLowerCase().contains('user already registered')) {
        _error =
            "This email is already registered. Please log in or confirm your email.";
      } else {
        _error = e.message;
      }
    } catch (e) {
      _error = e.toString();
      print('DEBUG: Unknown error: \${e.toString()}');
    }
    _setLoading(false);
  }

  Future<void> completeProfile(String fullName) async {
    _setLoading(true);
    _error = null;
    try {
      final user = _authService.currentUser;
      if (user == null) {
        _error = "No user found.";
        _setLoading(false);
        return;
      }
      await _authService.client.from('profiles').upsert({
        'id': user.id,
        'full_name': fullName,
      });
      await fetchUserProfile();
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    _error = null;
    try {
      final response = await _authService.signIn(
        email: email,
        password: password,
      );
      if (response.user != null) {
        // Insert user into profiles table if not already present
        final userId = response.user!.id;
        final profile =
            await _authService.client
                .from('profiles')
                .select('id')
                .eq('id', userId)
                .maybeSingle();
        if (profile == null) {
          await _authService.client.from('profiles').insert({
            'id': userId,
            'full_name': null,
            'role': 'user',
            'created_at': DateTime.now().toIso8601String(),
            'email': email,
            // Do NOT store password in production
          });
        }
        await fetchUserProfile();
        print('DEBUG: User signed in, profile: \${_userProfile?.toMap()}');
      } else {
        _error = 'Sign in failed: No user returned.';
        print('DEBUG: Sign in failed, no user.');
      }
    } on AuthException catch (e) {
      _error = e.message;
      print('DEBUG: AuthException: \${e.message}');
    } catch (e) {
      _error = e.toString();
      print('DEBUG: Unknown error: \${e.toString()}');
    }
    _setLoading(false);
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _userProfile = null;
    notifyListeners();
  }

  Future<void> fetchUserProfile() async {
    final user = _authService.currentUser;
    if (user == null) {
      _userProfile = null;
      notifyListeners();
      return;
    }
    final response =
        await _authService.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();
    if (response != null) {
      _userProfile = UserProfile.fromMap(response);
    } else {
      _userProfile = null;
    }
    notifyListeners();
  }

  // Checks if an email is already registered in the database using a Supabase RPC
  Future<bool> checkEmailExists(String email) async {
    try {
      final result = await _authService.client.rpc(
        'check_email_exists',
        params: {'email_input': email},
      );
      print('DEBUG: checkEmailExists($email) result = $result');
      return result == true;
    } catch (e) {
      print('DEBUG: checkEmailExists error: $e');
      return false;
    }
  }

  Future<String?> uploadProfileImage(Uint8List bytes, String fileName) async {
    try {
      final storage = _authService.client.storage;
      final bucket = storage.from('avatars');
      await bucket.uploadBinary(
        fileName,
        bytes,
        fileOptions: const FileOptions(upsert: true),
      );
      final url = bucket.getPublicUrl(fileName);
      return url;
    } catch (e) {
      print('DEBUG: uploadProfileImage error: $e');
      return null;
    }
  }

  Future<void> updateProfileImageUrl(String imageUrl) async {
    final user = _authService.currentUser;
    if (user == null) return;
    await _authService.client.from('profiles').upsert({
      'id': user.id,
      'image_url': imageUrl,
    });
    await fetchUserProfile();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
