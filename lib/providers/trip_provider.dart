import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/trip_model.dart';
import '../services/supabase_service.dart';

class TripProvider extends ChangeNotifier {
  final List<Trip> _trips = [];
  bool _isLoading = false;
  String? _error;

  List<Trip> get trips => _trips;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTrips() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await SupabaseService().client.from('trips').select();
      _trips.clear();
      _trips.addAll((response as List).map((e) => Trip.fromMap(e)));
    } catch (e) {
      _error = 'Failed to load trips';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTrip(Trip trip) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      print('DEBUG: Trip insert payload:');
      print({
        'title': trip.title,
        'description': trip.description,
        'location': trip.location,
        'start_date': trip.startDate.toIso8601String().split('T')[0],
        'end_date': trip.endDate.toIso8601String().split('T')[0],
        'price': trip.price,
        'seats': trip.seats,
        'image': trip.image,
        'created_at': trip.createdAt?.toIso8601String(),
      });
      final response =
          await SupabaseService().client
              .from('trips')
              .insert({
                'title': trip.title,
                'description': trip.description,
                'location': trip.location,
                'start_date': trip.startDate.toIso8601String().split('T')[0],
                'end_date': trip.endDate.toIso8601String().split('T')[0],
                'price': trip.price,
                'seats': trip.seats,
                'image': trip.image,
                'created_at': trip.createdAt?.toIso8601String(),
              })
              .select()
              .single();
      print('DEBUG: Trip insert response:');
      print(response);
      _trips.add(Trip.fromMap(response));
    } catch (e, st) {
      print('DEBUG: Trip insert error:');
      print(e);
      print(st);
      _error = 'Failed to add trip';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateTrip(Trip trip) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await SupabaseService().client
          .from('trips')
          .update({
            'title': trip.title,
            'description': trip.description,
            'location': trip.location,
            'start_date': trip.startDate.toIso8601String(),
            'end_date': trip.endDate.toIso8601String(),
            'price': trip.price,
            'seats': trip.seats,
            'image': trip.image,
          })
          .eq('id', trip.id);
      await fetchTrips();
    } catch (e) {
      _error = 'Failed to update trip';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteTrip(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      print('DEBUG: Attempting to delete trip with id:');
      print(id);
      final response = await SupabaseService().client
          .from('trips')
          .delete()
          .eq('id', id);
      print('DEBUG: Trip delete response:');
      print(response);
      _trips.removeWhere((t) => t.id == id);
    } catch (e, st) {
      print('DEBUG: Trip delete error:');
      print(e);
      print(st);
      _error = 'Failed to delete trip';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<String?> uploadTripImage(XFile imageFile) async {
    try {
      final storage = SupabaseService().client.storage;
      final fileName =
          'trip_${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}';
      final fileBytes = await imageFile.readAsBytes();

      final String? path = await storage
          .from('trip-images')
          .uploadBinary(fileName, fileBytes);

      if (path != null && path.isNotEmpty) {
        // Get the public URL
        final url = storage.from('trip-images').getPublicUrl(fileName);
        return url;
      } else {
        print(
          'DEBUG: Image upload error: uploadBinary returned null or empty path',
        );
        return null;
      }
    } catch (e, st) {
      print('DEBUG: Exception during image upload:');
      print(e);
      print(st);
      return null;
    }
  }
}
