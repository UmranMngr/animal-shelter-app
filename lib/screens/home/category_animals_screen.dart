import 'package:flutter/material.dart';
import '../../models/animal_model.dart';
import '../../widgets/animal_card.dart';

class CategoryAnimalsScreen extends StatefulWidget {
  final String species;
  final List<AnimalModel> allAnimalsInSpecies;

  const CategoryAnimalsScreen({
    super.key,
    required this.species,
    required this.allAnimalsInSpecies,
  });

  @override
  State<CategoryAnimalsScreen> createState() => _CategoryAnimalsScreenState();
}

class _CategoryAnimalsScreenState extends State<CategoryAnimalsScreen> {
  // Seçilen Filtreler
  String? _selectedAge;
  String? _selectedBreed;
  String? _selectedGender;
  String? _selectedStatus;

  // Filtrelenmiş Listeyi Döndüren Getter
  List<AnimalModel> get _filteredAnimals {
    return widget.allAnimalsInSpecies.where((animal) {
      final matchAge =
          _selectedAge == null || animal.age.toString() == _selectedAge;
      final matchBreed =
          _selectedBreed == null || animal.breed == _selectedBreed;
      final matchGender =
          _selectedGender == null || animal.gender == _selectedGender;
      final matchStatus =
          _selectedStatus == null || animal.status == _selectedStatus;

      return matchAge && matchBreed && matchGender && matchStatus;
    }).toList();
  }

  void _showFilterModal() {
    // Veritabanındaki (O anki listedeki) mevcut eşsiz filtre seçeneklerini çıkartıyoruz
    final availableAges =
        widget.allAnimalsInSpecies.map((a) => a.age.toString()).toSet().toList()
          ..sort();
    final availableBreeds =
        widget.allAnimalsInSpecies
            .map((a) => a.breed)
            .where((b) => b != null && b!.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    final availableGenders =
        widget.allAnimalsInSpecies.map((a) => a.gender).toSet().toList()
          ..sort();
    final availableStatuses =
        widget.allAnimalsInSpecies.map((a) => a.status).toSet().toList()
          ..sort();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 24,
                left: 24,
                right: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filtrele',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _selectedAge = null;
                            _selectedBreed = null;
                            _selectedGender = null;
                            _selectedStatus = null;
                          });
                          setState(() {});
                        },
                        child: const Text(
                          'Temizle',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // YAŞ FİLTRESİ
                  if (availableAges.isNotEmpty) ...[
                    const Text(
                      'Yaş',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Wrap(
                      spacing: 8,
                      children:
                          availableAges
                              .map(
                                (age) => ChoiceChip(
                                  label: Text('$age Yaş'),
                                  selected: _selectedAge == age,
                                  onSelected: (selected) {
                                    setModalState(
                                      () =>
                                          _selectedAge = selected ? age : null,
                                    );
                                    setState(() {});
                                  },
                                ),
                              )
                              .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // CİNS FİLTRESİ
                  if (availableBreeds.isNotEmpty) ...[
                    const Text(
                      'Cins',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Wrap(
                      spacing: 8,
                      children:
                          availableBreeds
                              .map(
                                (breed) => ChoiceChip(
                                  label: Text(breed!),
                                  selected: _selectedBreed == breed,
                                  onSelected: (selected) {
                                    setModalState(
                                      () =>
                                          _selectedBreed =
                                              selected ? breed : null,
                                    );
                                    setState(() {});
                                  },
                                ),
                              )
                              .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // CİNSİYET FİLTRESİ
                  if (availableGenders.isNotEmpty) ...[
                    const Text(
                      'Cinsiyet',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Wrap(
                      spacing: 8,
                      children:
                          availableGenders
                              .map(
                                (gender) => ChoiceChip(
                                  label: Text(gender),
                                  selected: _selectedGender == gender,
                                  onSelected: (selected) {
                                    setModalState(
                                      () =>
                                          _selectedGender =
                                              selected ? gender : null,
                                    );
                                    setState(() {});
                                  },
                                ),
                              )
                              .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // DURUM FİLTRESİ
                  if (availableStatuses.isNotEmpty) ...[
                    const Text(
                      'Durum',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Wrap(
                      spacing: 8,
                      children:
                          availableStatuses
                              .map(
                                (status) => ChoiceChip(
                                  label: Text(status),
                                  selected: _selectedStatus == status,
                                  onSelected: (selected) {
                                    setModalState(
                                      () =>
                                          _selectedStatus =
                                              selected ? status : null,
                                    );
                                    setState(() {});
                                  },
                                ),
                              )
                              .toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Sonuçları Göster'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final animals = _filteredAnimals; // Filtrelenmiş güncel listeyi al

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.species),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: Colors.purple),
            onPressed: _showFilterModal,
          ),
        ],
      ),
      body:
          animals.isEmpty
              ? Center(
                child: Text(
                  'Bu filtrelere uygun ${widget.species} bulunamadı.',
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                itemCount: animals.length,
                itemBuilder: (context, index) {
                  final animal = animals[index];
                  return AnimalCard(
                    animal: animal,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/animal-detail',
                        arguments: animal,
                      );
                    },
                  );
                },
              ),
    );
  }
}
