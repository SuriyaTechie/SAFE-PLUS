import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

class AuthService {
  static const String demoEmail = 'demo@aishouter.com';
  static const String demoPassword = '123456';
  static String? _demoUserId;
  static String _demoName = 'Sarah Jenkins';
  static String _demoPhone = '+1 (555) 012-3456';

  final SupabaseClient _client = SupabaseService.client;

  Future<AuthResponse> signUp({required String email, required String password}) {
    // This talks directly to Supabase Auth.
    return _client.auth.signUp(email: email, password: password);
  }

  Future<void> signIn({required String email, required String password}) async {
    // Offline demo login for testing UI before backend setup.
    if (email.trim().toLowerCase() == demoEmail && password == demoPassword) {
      _demoUserId = 'demo-user-001';
      return;
    }

    // Real login path: Supabase Auth.
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signInDemo() async {
    // One-tap local login for UI testing without backend.
    _demoUserId = 'demo-user-001';
  }

  Future<void> signOut() async {
    _demoUserId = null;
    await _client.auth.signOut();
  }

  String? currentUserId() {
    return _client.auth.currentUser?.id ?? _demoUserId;
  }

  Map<String, String> currentProfile() {
    final user = _client.auth.currentUser;
    if (user == null) {
      return {
        'name': _demoName,
        'phone': _demoPhone,
      };
    }

    final metadata = user.userMetadata ?? {};
    final metaName = metadata['full_name']?.toString();
    final metaPhone = metadata['phone']?.toString();

    return {
      'name': (metaName == null || metaName.trim().isEmpty) ? 'Sarah Jenkins' : metaName,
      'phone': (metaPhone == null || metaPhone.trim().isEmpty) ? '+1 (555) 012-3456' : metaPhone,
    };
  }

  Future<void> updateProfile({
    required String fullName,
    required String phone,
  }) async {
    final cleanedName = fullName.trim();
    final cleanedPhone = phone.trim();

    final user = _client.auth.currentUser;
    if (user == null) {
      _demoName = cleanedName;
      _demoPhone = cleanedPhone;
      return;
    }

    await _client.auth.updateUser(
      UserAttributes(
        data: {
          'full_name': cleanedName,
          'phone': cleanedPhone,
        },
      ),
    );
  }
}
