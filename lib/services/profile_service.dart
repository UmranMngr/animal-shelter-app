import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // --- KULLANICI PROFİLİNİ GETİR ---
  Future<Map<String, dynamic>> getMyProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('Oturum bulunamadı.');
    }

    final data =
        await _supabase.from('profiles').select().eq('id', user.id).single();

    return data;
  }

  // --- TEMEL PROFİL GÜNCELLEME (İsim ve Avatar) ---
  Future<void> updateMyProfile(String name, String? avatarUrl) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('Oturum bulunamadı.');
    }

    final updateData = {'name': name};
    if (avatarUrl != null) {
      updateData['avatar_url'] = avatarUrl;
    }

    await _supabase.from('profiles').update(updateData).eq('id', user.id);
  }

  // --- PROFİL RESMİNİ SİLME ---
  Future<void> removeAvatar() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('Oturum bulunamadı.');
    }

    await _supabase
        .from('profiles')
        .update({'avatar_url': null})
        .eq('id', user.id);
  }

  // --- ONBOARDING (KARŞILAMA) BİLGİLERİNİ KAYDETME ---
  Future<void> saveOnboardingData(Map<String, dynamic> data) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('Oturum bulunamadı.');
    }

    await _supabase
        .from('profiles')
        .update({
          'name': data['name'],
          'birth_date': data['birthDate'],
          'occupation': data['occupation'],
          'has_prior_experience': data['hasPriorExperience'],
          'has_current_pet': data['hasCurrentPet'],
          'current_pet_details': data['currentPetDetails'],
          'living_space': data['livingSpace'],
          'has_children': data['hasChildren'],
          'alone_time': data['aloneTime'],
          'is_onboarded': true, // Anketi tamamladı olarak işaretliyoruz
        })
        .eq('id', user.id);
  }

  // --- TÜM PROFİL BİLGİLERİNİ GÜNCELLEME (Profil Ekranı İçin) ---
  Future<void> updateFullProfile(Map<String, dynamic> data) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('Oturum bulunamadı.');
    }

    await _supabase.from('profiles').update(data).eq('id', user.id);
  }
}
