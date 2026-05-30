import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/animal_model.dart';

class AnimalService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<AnimalModel>> getAnimals({bool availableOnly = true}) async {
    var query = _supabase
        .from('animals')
        .select('*, profiles:shelter_id(name)');

    if (availableOnly) {
      query = query.or('status.eq.available,status.eq.treatment');
    }

    final data = await query.order('created_at', ascending: false);
    return (data as List)
        .map((e) => AnimalModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addAnimal(AnimalModel animal) async {
    await _supabase.from('animals').insert(animal.toInsertMap());
  }

  Future<void> updateAnimal(AnimalModel animal) async {
    await _supabase
        .from('animals')
        .update({
          'name': animal.name,
          'species': animal.species,
          'breed': animal.breed,
          'age': animal.age,
          'gender': animal.gender,
          'description': animal.description,
          'image_url': animal.imageUrl,
          'status': animal.status,
          'is_spayed': animal.isSpayed, // YENİ EKLENDİ
        })
        .eq('id', animal.id);
  }

  Future<void> updateAnimalStatus(String animalId, String status) async {
    await _supabase
        .from('animals')
        .update({'status': status})
        .eq('id', animalId);
  }

  // --- YENİ EKLENEN: KISIRLAŞTIRMA DURUMUNU GÜNCELLEME ---
  Future<void> updateSpayedStatus(String animalId, bool isSpayed) async {
    await _supabase
        .from('animals')
        .update({'is_spayed': isSpayed})
        .eq('id', animalId);
  }

  Future<void> deleteAnimal(String id) async {
    await _supabase.from('animals').delete().eq('id', id);
  }
}
