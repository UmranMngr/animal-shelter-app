import 'package:flutter/material.dart';
import '../../models/animal_model.dart';
import '../../services/animal_service.dart';
import '../../services/storage_service.dart';

class AddAnimalScreen extends StatefulWidget {
  const AddAnimalScreen({super.key});

  @override
  State<AddAnimalScreen> createState() => _AddAnimalScreenState();
}

class _AddAnimalScreenState extends State<AddAnimalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _speciesCtrl = TextEditingController();
  final _breedCtrl = TextEditingController(); // YENİ: Cins Controller
  final _ageCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  final _animalService = AnimalService();
  final _storageService = StorageService();

  String _gender = 'Erkek';
  String _status = 'available';
  String? _imageUrl;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _speciesCtrl.dispose();
    _breedCtrl.dispose(); // YENİ EKLENDİ
    _ageCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final url = await _storageService.pickAndUploadAnimalImage();
    if (!mounted) return;
    if (url == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Fotoğraf seçilmedi')));
      return;
    }
    setState(() => _imageUrl = url);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await _animalService.addAnimal(
        AnimalModel(
          id: '',
          name: _nameCtrl.text.trim(),
          species: _speciesCtrl.text.trim(),
          breed: _breedCtrl.text.trim(), // YENİ EKLENDİ
          age: int.parse(_ageCtrl.text.trim()),
          gender: _gender,
          description: _descriptionCtrl.text.trim(),
          status: _status,
          imageUrl: _imageUrl,
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Hayvan eklendi')));

      _nameCtrl.clear();
      _speciesCtrl.clear();
      _breedCtrl.clear(); // YENİ EKLENDİ
      _ageCtrl.clear();
      _descriptionCtrl.clear();
      setState(() {
        _imageUrl = null;
        _gender = 'Erkek';
        _status = 'available';
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hata: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hayvan Ekle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                blurRadius: 18,
                offset: Offset(0, 8),
                color: Colors.black12,
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(20),
                      image:
                          _imageUrl != null
                              ? DecorationImage(
                                image: NetworkImage(_imageUrl!),
                                fit: BoxFit.cover,
                              )
                              : null,
                    ),
                    child:
                        _imageUrl == null
                            ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_rounded, size: 42),
                                SizedBox(height: 10),
                                Text('Fotoğraf eklemek için tıkla'),
                              ],
                            )
                            : null,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Ad'),
                  validator:
                      (v) =>
                          v == null || v.trim().isEmpty ? 'Ad gerekli' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _speciesCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tür (Örn: Köpek, Kedi)',
                  ),
                  validator:
                      (v) =>
                          v == null || v.trim().isEmpty ? 'Tür gerekli' : null,
                ),
                const SizedBox(height: 12),
                // YENİ EKLENEN CİNS ALANI
                TextFormField(
                  controller: _breedCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Cins (Opsiyonel)',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _ageCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Yaş'),
                  validator: (v) {
                    final age = int.tryParse((v ?? '').trim());
                    if (age == null || age < 0) return 'Geçerli yaş gir';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _gender,
                  decoration: const InputDecoration(labelText: 'Cinsiyet'),
                  items: const [
                    DropdownMenuItem(value: 'Erkek', child: Text('Erkek')),
                    DropdownMenuItem(value: 'Dişi', child: Text('Dişi')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _gender = value);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(labelText: 'Durum'),
                  items: const [
                    DropdownMenuItem(
                      value: 'available',
                      child: Text('Available'),
                    ),
                    DropdownMenuItem(
                      value: 'treatment',
                      child: Text('Treatment'),
                    ),
                    DropdownMenuItem(value: 'adopted', child: Text('Adopted')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _status = value);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Açıklama'),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _save,
                    child:
                        _loading
                            ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text('Hayvanı Kaydet'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
