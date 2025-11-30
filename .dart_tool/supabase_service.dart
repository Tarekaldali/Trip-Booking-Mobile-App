import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final SupabaseClient _client = Supabase.instance.client;

  Future<AuthResponse> signUp(String email, String password) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;

  Future<void> sendPasswordResetEmail(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Future<List<Map<String, dynamic>>> fetchTransactions() async {
    final user = currentUser;
    if (user == null) return [];
    final response = await _client
        .from('transactions')
        .select('*, categories(name, icon)')
        .eq('user_id', user.id)
        .order('date', ascending: false);
    return List<Map<String, dynamic>>.from(response).map((t) {
      final cat = t['categories'];
      return {
        ...t,
        'category_name': cat != null ? cat['name'] : null,
        'category_icon': cat != null ? cat['icon'] : null,
      };
    }).toList();
  }

  Future<void> addTransaction(Map<String, dynamic> data) async {
    final user = currentUser;
    if (user == null) return;
    final transactionData = {
      'user_id': user.id,
      ...data,
    };
    await _client.from('transactions').insert(transactionData);
  }

  Future<void> updateTransaction(String id, Map<String, dynamic> data) async {
    await _client.from('transactions').update(data).eq('id', id);
  }

  Future<void> deleteTransaction(String id) async {
    await _client.from('transactions').delete().eq('id', id);
  }

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final user = currentUser;
    if (user == null) return [];
    final response = await _client.from('categories').select().eq('user_id', user.id).order('name');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> addCategory(Map<String, dynamic> data) async {
    final user = currentUser;
    if (user == null) return;
    final categoryData = {
      'user_id': user.id,
      ...data,
    };
    await _client.from('categories').insert(categoryData);
  }

  Future<void> updateCategory(String id, Map<String, dynamic> data) async {
    await _client.from('categories').update(data).eq('id', id);
  }

  Future<void> deleteCategory(String id) async {
    await _client.from('categories').delete().eq('id', id);
  }

  Future<List<Map<String, dynamic>>> fetchBudgets() async {
    final user = currentUser;
    if (user == null) return [];
    final response = await _client.from('budgets').select().eq('user_id', user.id).order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> addBudget(Map<String, dynamic> data) async {
    final user = currentUser;
    if (user == null) return;
    final budgetData = {
      'user_id': user.id,
      ...data,
    };
    await _client.from('budgets').insert(budgetData);
  }

  Future<void> updateBudget(String id, Map<String, dynamic> data) async {
    await _client.from('budgets').update(data).eq('id', id);
  }

  Future<void> deleteBudget(String id) async {
    await _client.from('budgets').delete().eq('id', id);
  }

  Future<Map<String, dynamic>?> fetchUserProfile() async {
    final user = currentUser;
    if (user == null) return null;
    try {
      final response = await _client.from('user_profiles').select().eq('id', user.id).single();
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    final user = currentUser;
    if (user == null) return;
    final profileData = {
      'id': user.id,
      ...data,
    };
    await _client.from('user_profiles').upsert(profileData);
  }
}
