import 'package:flutter/material.dart';
import '../../models/animal_model.dart';
import '../../models/health_record_model.dart';
import '../../services/adoption_service.dart';
import '../../services/health_record_service.dart';
import '../../services/profile_service.dart';
import '../../services/animal_service.dart';

class AnimalDetailScreen extends StatefulWidget {
  final AnimalModel animal;
  const AnimalDetailScreen({super.key, required this.animal});

  @override
  State<AnimalDetailScreen> createState() => _AnimalDetailScreenState();
}

class _AnimalDetailScreenState extends State<AnimalDetailScreen> {
  final _adoptionService = AdoptionService();
  final _healthService = HealthRecordService();
  final _profileService = ProfileService();
  final _animalService = AnimalService();

  late AnimalModel _currentAnimal = widget.animal;
  bool _isShelter = false;
  bool _isApplied = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    try {
      final profile = await _profileService.getMyProfile();
      if (mounted) setState(() => _isShelter = (profile['role'] == 'shelter'));

      if (profile['role'] != 'shelter') {
        final requests = await _adoptionService.getMyRequests();
        final hasApplied = requests.any(
          (r) =>
              r['animal_id'] == _currentAnimal.id && r['status'] == 'pending',
        );
        if (mounted) {
          setState(() {
            _isApplied = hasApplied;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showStatusUpdateDialog() async {
    String newStatus = _currentAnimal.status;

    await showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Durumu Güncelle'),
            content: DropdownButtonFormField<String>(
              value: newStatus,
              decoration: const InputDecoration(labelText: 'Yeni Durum'),
              items: const [
                DropdownMenuItem(
                  value: 'available',
                  child: Text('Sahiplendirilebilir (Available)'),
                ),
                DropdownMenuItem(
                  value: 'treatment',
                  child: Text('Tedavide (Treatment)'),
                ),
                DropdownMenuItem(
                  value: 'adopted',
                  child: Text('Sahiplenildi (Adopted)'),
                ),
              ],
              onChanged: (val) {
                if (val != null) newStatus = val;
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('İptal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  try {
                    await _animalService.updateAnimalStatus(
                      _currentAnimal.id,
                      newStatus,
                    );

                    if (mounted) {
                      setState(() {
                        _currentAnimal = AnimalModel(
                          id: _currentAnimal.id,
                          name: _currentAnimal.name,
                          species: _currentAnimal.species,
                          breed: _currentAnimal.breed,
                          age: _currentAnimal.age,
                          gender: _currentAnimal.gender,
                          description: _currentAnimal.description,
                          status: newStatus,
                          imageUrl: _currentAnimal.imageUrl,
                          isSpayed:
                              _currentAnimal.isSpayed, // Mevcut durumu koru
                        );
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Durum başarıyla güncellendi'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Hata: $e')));
                    }
                  }
                },
                child: const Text('Kaydet'),
              ),
            ],
          ),
    );
  }

  Future<void> _confirmWithdraw() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Başvuruyu Geri Çek'),
            content: const Text(
              'Bu hayvan için yaptığınız sahiplenme başvurusunu iptal etmek istediğinize emin misiniz?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Vazgeç'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Başvuruyu İptal Et',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await _adoptionService.withdrawApplication(_currentAnimal.id);
        if (mounted) {
          setState(() => _isApplied = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Başvurunuz başarıyla geri çekildi.')),
          );
        }
      } catch (e) {
        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    }
  }

  Future<void> _showAdoptionDialog() async {
    final msgCtrl = TextEditingController();
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Sahiplenme Başvurusu'),
            content: TextField(
              controller: msgCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Neden sahiplenmek istiyorsun?',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('İptal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final message = msgCtrl.text.trim();
                  if (message.isEmpty) return;
                  Navigator.pop(ctx);
                  try {
                    await _adoptionService.applyForAnimal(
                      _currentAnimal.id,
                      message,
                    );
                    if (mounted) {
                      setState(() {
                        _isApplied = true;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Başvuru gönderildi!')),
                      );
                    }
                  } catch (e) {
                    final cleanError = e.toString().replaceAll(
                      'Exception: ',
                      '',
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(cleanError),
                          backgroundColor: Colors.red.shade600,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Gönder'),
              ),
            ],
          ),
    );
  }

  Future<void> _showHealthRecordDialog() async {
    final descCtrl = TextEditingController();
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Sağlık Kaydı Ekle'),
            content: TextField(
              controller: descCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Aşı / Tedavi Açıklaması',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('İptal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (descCtrl.text.isEmpty) return;
                  Navigator.pop(ctx);
                  try {
                    await _healthService.addRecord(
                      _currentAnimal.id,
                      descCtrl.text.trim(),
                    );
                    setState(() {
                      _currentAnimal = AnimalModel(
                        id: _currentAnimal.id,
                        name: _currentAnimal.name,
                        species: _currentAnimal.species,
                        breed: _currentAnimal.breed,
                        age: _currentAnimal.age,
                        gender: _currentAnimal.gender,
                        description: _currentAnimal.description,
                        status: 'treatment',
                        imageUrl: _currentAnimal.imageUrl,
                        isSpayed: _currentAnimal.isSpayed,
                      );
                    });
                  } catch (e) {
                    if (mounted)
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Hata: $e')));
                  }
                },
                child: const Text('Ekle'),
              ),
            ],
          ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Hayvanı Sil'),
            content: const Text(
              'Bu kaydı silmek istediğinize emin misiniz? Bu işlem geri alınamaz.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('İptal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Sil', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await _animalService.deleteAnimal(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kayıt başarıyla silindi')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentAnimal.name),
        actions: [
          if (_isShelter) ...[
            IconButton(
              icon: const Icon(Icons.edit_note_rounded),
              onPressed:
                  () => Navigator.pushNamed(
                    context,
                    '/edit-animal',
                    arguments: _currentAnimal,
                  ),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_forever_rounded,
                color: Colors.redAccent,
              ),
              onPressed: () => _confirmDelete(context, _currentAnimal.id),
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: _currentAnimal.id,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child:
                      _currentAnimal.imageUrl == null ||
                              _currentAnimal.imageUrl!.isEmpty
                          ? Container(
                            color: Colors.purple.shade50,
                            child: const Center(
                              child: Icon(Icons.pets, size: 64),
                            ),
                          )
                          : Image.network(
                            _currentAnimal.imageUrl!,
                            fit: BoxFit.cover,
                          ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              _currentAnimal.name,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              '${_currentAnimal.species} • ${_currentAnimal.gender} • ${_currentAnimal.age} yaş',
            ),

            if (_currentAnimal.breed != null &&
                _currentAnimal.breed!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Cinsi: ${_currentAnimal.breed}',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            const SizedBox(height: 12),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        _currentAnimal.status == 'available'
                            ? Colors.green.withOpacity(0.12)
                            : _currentAnimal.status == 'adopted'
                            ? Colors.red.withOpacity(0.12)
                            : Colors.orange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text('Durum: ${_currentAnimal.status}'),
                ),
                if (_isShelter) ...[
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _showStatusUpdateDialog,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 20,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 18),
            Text(
              _currentAnimal.description.isEmpty
                  ? 'Açıklama yok.'
                  : _currentAnimal.description,
              style: const TextStyle(height: 1.5),
            ),
            const SizedBox(height: 22),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sağlık Geçmişi',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (_isShelter)
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.purple),
                    onPressed: _showHealthRecordDialog,
                  ),
              ],
            ),

            // --- YENİ EKLENEN KISIRLAŞTIRMA KONTROLÜ ---
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color:
                    _currentAnimal.isSpayed
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        _currentAnimal.isSpayed
                            ? Icons.check_circle
                            : Icons.warning_amber_rounded,
                        color:
                            _currentAnimal.isSpayed
                                ? Colors.green
                                : Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _currentAnimal.isSpayed
                            ? 'Kısırlaştırıldı'
                            : 'Kısırlaştırılmadı',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color:
                              _currentAnimal.isSpayed
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                  if (_isShelter)
                    Switch(
                      value: _currentAnimal.isSpayed,
                      activeColor: Colors.green,
                      onChanged: (val) async {
                        try {
                          await _animalService.updateSpayedStatus(
                            _currentAnimal.id,
                            val,
                          );
                          setState(() {
                            _currentAnimal = AnimalModel(
                              id: _currentAnimal.id,
                              name: _currentAnimal.name,
                              species: _currentAnimal.species,
                              breed: _currentAnimal.breed,
                              age: _currentAnimal.age,
                              gender: _currentAnimal.gender,
                              description: _currentAnimal.description,
                              status: _currentAnimal.status,
                              imageUrl: _currentAnimal.imageUrl,
                              isSpayed: val, // Değeri güncelliyoruz
                            );
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Kısırlaştırma durumu güncellendi'),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Hata: $e')));
                        }
                      },
                    ),
                ],
              ),
            ),

            // ---------------------------------------------
            FutureBuilder<List<HealthRecordModel>>(
              future: _healthService.getRecords(_currentAnimal.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                if (snapshot.data!.isEmpty)
                  return const Text(
                    'Henüz sağlık kaydı bulunmuyor.',
                    style: TextStyle(color: Colors.grey),
                  );
                return Column(
                  children:
                      snapshot.data!
                          .map(
                            (record) => Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.medical_services,
                                  color: Colors.green,
                                ),
                                title: Text(record.description),
                                subtitle: Text(
                                  record.treatmentDate != null
                                      ? "${record.treatmentDate!.day}/${record.treatmentDate!.month}/${record.treatmentDate!.year}"
                                      : '',
                                ),
                              ),
                            ),
                          )
                          .toList(),
                );
              },
            ),
            const SizedBox(height: 30),
            if (!_isShelter) ...[
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed:
                      () => Navigator.pushNamed(
                        context,
                        '/donation',
                        arguments: _currentAnimal,
                      ),
                  icon: const Icon(Icons.volunteer_activism),
                  label: const Text('Bağış Yap'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed:
                      _currentAnimal.status == 'adopted'
                          ? null
                          : (_isApplied
                              ? _confirmWithdraw
                              : _showAdoptionDialog),
                  icon: Icon(
                    _isApplied ? Icons.assignment_turned_in : Icons.favorite,
                  ),
                  label: Text(
                    _currentAnimal.status == 'adopted'
                        ? 'Sahiplenildi'
                        : (_isApplied
                            ? 'Başvuruldu'
                            : 'Sahiplenme Başvurusu Yap'),
                  ),
                  style:
                      _isApplied
                          ? ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple.shade100,
                            foregroundColor: Colors.purple.shade900,
                          )
                          : null,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
