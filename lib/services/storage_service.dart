import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickAndUploadAnimalImage() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (file == null) return null;

    final bytes = await file.readAsBytes();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
    final path = 'animal-photos/$fileName';

    await _supabase.storage
        .from('animal-photos')
        .uploadBinary(
          path,
          Uint8List.fromList(bytes),
          fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
        );

    return _supabase.storage.from('animal-photos').getPublicUrl(path);
  }

  Future<String?> pickAndUploadAvatar() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (file == null) return null;

    final bytes = await file.readAsBytes();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
    final path = 'avatars/$fileName';

    await _supabase.storage
        .from('avatars')
        .uploadBinary(
          path,
          Uint8List.fromList(bytes),
          fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
        );

    return _supabase.storage.from('avatars').getPublicUrl(path);
  }
}
