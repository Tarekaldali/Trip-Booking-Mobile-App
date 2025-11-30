import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  static const String supabaseUrl = 'https://gqyxbivcbfdjtsuqxhgu.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdxeXhiaXZjYmZkanRzdXF4aGd1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgxMTEwODIsImV4cCI6MjA2MzY4NzA4Mn0.uFrmlMyqKC_i8G1gv2-iMophcVqQdraquIOvah0ylDw';

  bool _initialized = false;

  Future<void> initialize() async {
    if (!_initialized) {
      await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
      _initialized = true;
    }
  }

  SupabaseClient get client => Supabase.instance.client;
}
