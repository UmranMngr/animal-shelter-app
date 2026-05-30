import 'package:flutter/material.dart';
import '../../models/animal_model.dart';
import '../../services/adoption_service.dart';
import '../../services/animal_service.dart';

class AdoptionScreen extends StatefulWidget {
  const AdoptionScreen({super.key});

  @override
  State<AdoptionScreen> createState() => _AdoptionScreenState();
}

class _AdoptionScreenState extends State<AdoptionScreen> {
  final Set<String> _appliedAnimalIds = {};
  final _adoptionService = AdoptionService(); // Servis tanımlandı
  bool _isLoading = true; // Başlangıç yüklemesi için

  @override
  void initState() {
    super.initState();
    _fetchMyApplications(); // Sayfa açıldığında mevcut başvuruları çek
  }

  // Kullanıcının mevcut başvurularını veri tabanından kontrol eder
  Future<void> _fetchMyApplications() async {
    try {
      final requests = await _adoptionService.getMyRequests();
      // Sadece 'pending' (beklemede) olan başvuruların ID'lerini listeye ekle
      final pendingIds =
          requests
              .where((r) => r['status'] == 'pending')
              .map((r) => r['animal_id'].toString())
              .toList();

      if (mounted) {
        setState(() {
          _appliedAnimalIds.addAll(pendingIds);
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // BAŞVURUYU GERİ ÇEKME DİYALOĞU
  Future<void> _confirmWithdraw(BuildContext context, String animalId) async {
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
        await _adoptionService.withdrawApplication(animalId);
        if (mounted) {
          setState(() {
            _appliedAnimalIds.remove(animalId); // Listeden kaldır
          });
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

  // MESAJ KUTUSUNU AÇAN FONKSİYON
  Future<void> _showAdoptionDialog(
    BuildContext context,
    String animalId,
  ) async {
    final msgCtrl = TextEditingController();

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Sahiplenme Başvurusu'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Neden bu dostumuzu sahiplenmek istiyorsunuz?'),
                const SizedBox(height: 15),
                TextField(
                  controller: msgCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Mesajınızı buraya yazın...',
                    filled: true,
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                ),
              ],
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
                    await _adoptionService.applyForAnimal(animalId, message);

                    if (mounted) {
                      setState(() {
                        _appliedAnimalIds.add(animalId);
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Başvurunuz mesajınızla birlikte iletildi!',
                          ),
                        ),
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

  @override
  Widget build(BuildContext context) {
    final animalService = AnimalService();

    return Scaffold(
      appBar: AppBar(title: const Text('Sahiplenme')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : FutureBuilder<List<AnimalModel>>(
                future: animalService.getAnimals(availableOnly: true),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Hata: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final animals = snapshot.data!;

                  if (animals.isEmpty) {
                    return const Center(
                      child: Text('Sahiplenilebilir hayvan yok'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: animals.length,
                    itemBuilder: (context, index) {
                      final animal = animals[index];
                      final isApplied = _appliedAnimalIds.contains(animal.id);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 16,
                              offset: Offset(0, 7),
                              color: Colors.black12,
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: SizedBox(
                              width: 64,
                              height: 64,
                              child:
                                  animal.imageUrl == null ||
                                          animal.imageUrl!.isEmpty
                                      ? Container(
                                        color: Colors.purple.shade50,
                                        child: const Icon(Icons.pets),
                                      )
                                      : Image.network(
                                        animal.imageUrl!,
                                        fit: BoxFit.cover,
                                      ),
                            ),
                          ),
                          title: Text(
                            animal.name,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          subtitle: Text(
                            '${animal.species} • ${animal.age} yaş',
                          ),
                          trailing: ElevatedButton(
                            // DEĞİŞİKLİK: Başvurulduysa tıklandığında _confirmWithdraw çalışır
                            onPressed:
                                isApplied
                                    ? () => _confirmWithdraw(context, animal.id)
                                    : () =>
                                        _showAdoptionDialog(context, animal.id),
                            // Görseli de başvurulduğunda biraz daha soft hale getirebiliriz
                            style:
                                isApplied
                                    ? ElevatedButton.styleFrom(
                                      backgroundColor: Colors.purple.shade50,
                                      foregroundColor: Colors.purple.shade900,
                                    )
                                    : null,
                            child: Text(isApplied ? 'Başvuruldu' : 'Başvur'),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
