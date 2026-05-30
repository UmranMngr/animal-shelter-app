import 'package:flutter/material.dart';
import '../../models/animal_model.dart';
import '../../services/animal_service.dart';
import '../../services/storage_service.dart';

class EditAnimalScreen extends StatefulWidget {
  final AnimalModel animal;
  const EditAnimalScreen({super.key, required this.animal});

  @override
  State<EditAnimalScreen> createState() => _EditAnimalScreenState();
}

class _EditAnimalScreenState extends State<EditAnimalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _animalService = AnimalService();
  final _storageService = StorageService();

  late TextEditingController _nameCtrl;
  late TextEditingController _ageCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _breedCtrl;

  String? _selectedSpecies;
  String? _selectedGender;
  String? _imageUrl;
  bool _loading = false;

  // Tür seçeneklerimizi bir değişkene alalım ki dinamik olarak yönetebilelim.
  List<String> _speciesList = ['Kedi', 'Köpek', 'Kuş', 'Diğer'];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.animal.name);
    _ageCtrl = TextEditingController(text: widget.animal.age.toString());
    _descCtrl = TextEditingController(text: widget.animal.description);
    _breedCtrl = TextEditingController(text: widget.animal.breed ?? '');

    // HATA ÇÖZÜMÜ BURADA:
    // Eğer veritabanından gelen tür (Örn: Tavşan), bizim listemizde yoksa onu listeye ekle.
    if (widget.animal.species.isNotEmpty &&
        !_speciesList.contains(widget.animal.species)) {
      _speciesList.add(widget.animal.species);
    }

    _selectedSpecies = widget.animal.species;
    _selectedGender = widget.animal.gender;
    _imageUrl = widget.animal.imageUrl;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _descCtrl.dispose();
    _breedCtrl.dispose();
    super.dispose();
  }

  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final updatedAnimal = AnimalModel(
        id: widget.animal.id,
        name: _nameCtrl.text.trim(),
        species: _selectedSpecies!,
        breed: _breedCtrl.text.trim(),
        age: int.parse(_ageCtrl.text),
        gender: _selectedGender!,
        description: _descCtrl.text.trim(),
        imageUrl: _imageUrl,
        status: widget.animal.status,
      );

      await _animalService.updateAnimal(updatedAnimal);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Güncellendi!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted)
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
      appBar: AppBar(title: const Text('Bilgileri Güncelle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  final url = await _storageService.pickAndUploadAnimalImage();
                  if (url != null) setState(() => _imageUrl = url);
                },
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child:
                      _imageUrl != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(_imageUrl!, fit: BoxFit.cover),
                          )
                          : const Icon(Icons.add_a_photo, size: 40),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'İsim'),
              ),
              const SizedBox(height: 12),

              // GÜNCELLENEN KISIM: Statik liste yerine _speciesList değişkenini kullanıyoruz
              DropdownButtonFormField<String>(
                value: _selectedSpecies,
                items:
                    _speciesList
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                onChanged: (v) => setState(() => _selectedSpecies = v),
                decoration: const InputDecoration(labelText: 'Tür'),
              ),

              const SizedBox(height: 12),
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
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                items:
                    ['Erkek', 'Dişi']
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                onChanged: (v) => setState(() => _selectedGender = v),
                decoration: const InputDecoration(labelText: 'Cinsiyet'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Açıklama'),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _loading ? null : _update,
                  child:
                      _loading
                          ? const CircularProgressIndicator()
                          : const Text('Değişiklikleri Kaydet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
