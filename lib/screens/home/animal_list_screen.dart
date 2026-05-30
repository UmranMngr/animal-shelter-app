import 'package:flutter/material.dart';
import '../../models/animal_model.dart';
import '../../services/animal_service.dart';
import '../../widgets/category_card.dart';
import 'category_animals_screen.dart';

class AnimalListScreen extends StatelessWidget {
  final bool showOnlyAvailable;

  const AnimalListScreen({super.key, required this.showOnlyAvailable});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await AnimalService().getAnimals(availableOnly: showOnlyAvailable);
      },
      child: FutureBuilder<List<AnimalModel>>(
        future: AnimalService().getAnimals(availableOnly: showOnlyAvailable),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final animals = snapshot.data!;

          if (animals.isEmpty) {
            return const Center(child: Text('Gösterilecek hayvan yok'));
          }

          // HAYVANLARI TÜRLERİNE (Species) GÖRE GRUPLUYORUZ
          final Map<String, List<AnimalModel>> groupedAnimals = {};
          for (var animal in animals) {
            final species = animal.species;
            if (!groupedAnimals.containsKey(species)) {
              groupedAnimals[species] = [];
            }
            groupedAnimals[species]!.add(animal);
          }

          // Kategorileri listeye dök
          final categories = groupedAnimals.keys.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final species = categories[index];
              final animalsInSpecies = groupedAnimals[species]!;

              // Sadece fotoğrafı olanları slider için çekiyoruz
              final imageUrls =
                  animalsInSpecies
                      .where(
                        (a) => a.imageUrl != null && a.imageUrl!.isNotEmpty,
                      )
                      .map((a) => a.imageUrl!)
                      .toList();

              return CategoryCard(
                species: species,
                imageUrls: imageUrls,
                onTap: () {
                  // Kategoriye tıklanınca yeni sayfaya yönlendiriyoruz
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => CategoryAnimalsScreen(
                            species: species,
                            allAnimalsInSpecies: animalsInSpecies,
                          ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
