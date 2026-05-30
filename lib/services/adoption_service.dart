import 'package:supabase_flutter/supabase_flutter.dart';

class AdoptionService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 1. BAŞVURU YAPMA (Bağışçı için)
  Future<void> applyForAnimal(String animalId, String message) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Oturum bulunamadı.');

    // 1. ÖNCE KONTROL ET: Zaten bekleyen veya onaylanan başvuru var mı?
    final existing =
        await _supabase
            .from('adoptions')
            .select()
            .eq('user_id', user.id)
            .eq('animal_id', animalId)
            .or('status.eq.pending,status.eq.approved')
            .maybeSingle();

    if (existing != null) {
      throw Exception('Bu hayvan için zaten aktif bir başvurunuz bulunuyor.');
    }

    // 2. EĞER YOKSA EKLE
    await _supabase.from('adoptions').insert({
      'user_id': user.id,
      'animal_id': animalId,
      'status': 'pending',
      'message': message,
    });
  }

  // 2. BARINAK SAHİBİNE GELEN BAŞVURULARI GETİRME
  Future<List<Map<String, dynamic>>> getShelterRequests() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    // animals!inner kullanarak sadece bu barınağa ait hayvanların başvurularını çekiyoruz
    final data = await _supabase
        .from('adoptions')
        .select(
          'id, user_id, animal_id, status, message, animals!inner(name, image_url, shelter_id), profiles:user_id(name, email)',
        )
        .eq('animals.shelter_id', user.id)
        .order('id', ascending: false);

    return (data as List).cast<Map<String, dynamic>>();
  }

  // 3. TÜM BAŞVURULARI GETİRME (Genel)
  Future<List<Map<String, dynamic>>> getAllRequests() async {
    final data = await _supabase
        .from('adoptions')
        .select(
          'id, user_id, animal_id, status, animals(name, image_url), profiles(name, email)',
        )
        .order('id', ascending: false);

    return (data as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getMyRequests() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('Oturum bulunamadı.');
    }

    final data = await _supabase
        .from('adoptions')
        // created_at alanını ekledik
        .select(
          'id, user_id, animal_id, status, created_at, animals(name, image_url)',
        )
        .eq('user_id', user.id)
        // Sıralamayı id yerine created_at (yeni tarihten eskiye) yaptık
        .order('created_at', ascending: false);

    return (data as List).cast<Map<String, dynamic>>();
  }

  // 5. BAŞVURUYU ONAYLAMA
  Future<void> approve(String adoptionId, String animalId) async {
    await _supabase
        .from('adoptions')
        .update({'status': 'approved'})
        .eq('id', adoptionId);

    // Hayvanın durumunu 'sahiplenildi' olarak güncelle
    await _supabase
        .from('animals')
        .update({'status': 'adopted'})
        .eq('id', animalId);
  }

  // 6. BAŞVURUYU REDDETME
  // adoption_service.dart içindeki ilgili kısmı şu şekilde değiştirin:

  // 6. BAŞVURUYU REDDETME (Artık direkt siliyor)
  // adoption_service.dart içindeki reject metodunu bul ve bununla değiştir:
  Future<void> reject(String adoptionId) async {
    await _supabase
        .from('adoptions')
        .delete() // <--- BURASI .update idi, .delete yaptık
        .eq('id', adoptionId);
  }

  // 7. BAŞVURUYU GERİ ÇEKME (EKSİK OLAN VE YENİ EKLENEN METOT)
  Future<void> withdrawApplication(String animalId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Oturum bulunamadı.');

    await _supabase
        .from('adoptions')
        .delete()
        .eq('user_id', user.id)
        .eq('animal_id', animalId)
        .eq('status', 'pending'); // Sadece beklemedeki başvurular silinebilir
  }
}
