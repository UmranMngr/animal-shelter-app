import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/donation_model.dart';

class DonationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, double>> getPrices() async {
    final data =
        await _supabase
            .from('donation_prices')
            .select()
            .eq('id', 1)
            .maybeSingle();
    if (data == null) {
      return {
        'food': 200,
        'vaccine': 500,
        'spay': 1500,
        'treatment': 1000,
        'care': 300,
      };
    }
    return {
      'food': double.tryParse(data['food_price'].toString()) ?? 200,
      'vaccine': double.tryParse(data['vaccine_price'].toString()) ?? 500,
      'spay': double.tryParse(data['spay_price'].toString()) ?? 1500,
      'treatment': double.tryParse(data['treatment_price'].toString()) ?? 1000,
      'care': double.tryParse(data['care_price'].toString()) ?? 300,
    };
  }

  Future<void> updatePrices(
    double food,
    double vaccine,
    double spay,
    double treatment,
    double care,
  ) async {
    await _supabase.from('donation_prices').upsert({
      'id': 1,
      'food_price': food,
      'vaccine_price': vaccine,
      'spay_price': spay,
      'treatment_price': treatment,
      'care_price': care,
    });
  }

  // --- YENİ EKLENEN KONTROL MANTIĞI ---
  Future<bool> checkSpayDonationExists(String animalName) async {
    if (animalName.isEmpty) return false;
    final data = await _supabase
        .from('donations')
        .select('id')
        .eq('animal_name', animalName)
        .eq('donation_type', 'spay')
        .limit(1);

    return (data as List).isNotEmpty;
  }
  // ------------------------------------

  Future<void> createDonation({
    required String donationType,
    required double amount,
    required int count,
    String? animalName,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Oturum bulunamadı.');

    await _supabase.from('donations').insert({
      'user_id': user.id,
      'donation_type': donationType,
      'amount': amount,
      'count': count,
      'animal_name': animalName,
    });
  }

  Future<List<DonationModel>> getMyDonations() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Oturum bulunamadı.');

    final data = await _supabase
        .from('donations')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);
    return (data as List)
        .map((e) => DonationModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, double>> getTotalsByType() async {
    final data = await _supabase
        .from('donations')
        .select('donation_type, amount');
    final totals = <String, double>{
      'food': 0,
      'vaccine': 0,
      'spay': 0,
      'treatment': 0,
      'care': 0,
    };

    for (final row in data as List) {
      final map = row as Map<String, dynamic>;
      final type = map['donation_type']?.toString() ?? '';
      final amount = double.tryParse(map['amount'].toString()) ?? 0;
      if (totals.containsKey(type)) totals[type] = totals[type]! + amount;
    }
    return totals;
  }

  Future<List<Map<String, dynamic>>> getRecentDonations30Days() async {
    final thirtyDaysAgo =
        DateTime.now().subtract(const Duration(days: 30)).toIso8601String();
    final data = await _supabase
        .from('donations')
        .select(
          'created_at, donation_type, count, animal_name, profiles:user_id(name)',
        )
        .gte('created_at', thirtyDaysAgo)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> getTop7Donors() async {
    final data = await _supabase
        .from('donations')
        .select('donation_type, count, profiles:user_id(id, name)');
    final userStats = <String, Map<String, dynamic>>{};

    for (var row in data) {
      final type = row['donation_type'] as String;
      if (row['profiles'] == null) continue;

      final profile = row['profiles'] as Map<String, dynamic>;
      final userId = profile['id'] as String;
      final name = profile['name'] as String? ?? 'İsimsiz';
      final count = int.tryParse(row['count']?.toString() ?? '1') ?? 1;

      if (!userStats.containsKey(userId)) {
        userStats[userId] = {
          'name': name,
          'food': 0,
          'vaccine': 0,
          'spay': 0,
          'treatment': 0,
          'care': 0,
          'totalCount': 0,
        };
      }

      userStats[userId]![type] = (userStats[userId]![type] as int) + count;
      userStats[userId]!['totalCount'] =
          (userStats[userId]!['totalCount'] as int) + count;
    }

    final sortedUsers =
        userStats.values.toList()..sort(
          (a, b) => (b['totalCount'] as int).compareTo(a['totalCount'] as int),
        );
    return sortedUsers.take(7).toList();
  }
}
