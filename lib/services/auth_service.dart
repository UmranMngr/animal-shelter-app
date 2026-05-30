import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
  }) {
    return _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'name': name, 'role': role},
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() => _supabase.auth.signOut();

  User? get currentUser => _supabase.auth.currentUser;
}
