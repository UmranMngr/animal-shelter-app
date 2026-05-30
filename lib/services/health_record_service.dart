import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/health_record_model.dart';

class HealthRecordService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<HealthRecordModel>> getRecords(String animalId) async {
    final data = await _supabase
        .from('health_records')
        .select()
        .eq('animal_id', animalId)
        .order('created_at', ascending: false);

    return (data as List).map((e) => HealthRecordModel.fromMap(e)).toList();
  }

  Future<void> addRecord(String animalId, String description) async {
    await _supabase.from('health_records').insert({
      'animal_id': animalId,
      'description': description,
      'treatment_date':
          DateTime.now().toIso8601String().split(
            'T',
          )[0], // Sadece tarihi alır (YYYY-MM-DD)
    });
  }
}
