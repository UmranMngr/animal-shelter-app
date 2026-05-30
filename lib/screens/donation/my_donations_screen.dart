import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/donation_model.dart';
import '../../services/donation_service.dart';

class MyDonationsScreen extends StatelessWidget {
  const MyDonationsScreen({super.key});

  String _typeLabel(String type) {
    switch (type) {
      case 'food':
        return 'Mama Bağışı';
      case 'vaccine':
        return 'Aşı Bağışı';
      case 'spay':
        return 'Kısırlaştırma Bağışı';
      case 'treatment':
        return 'Tedavi Bağışı';
      case 'care':
        return 'Bakım Bağışı';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kişisel Bağış Geçmişim')),
      body: FutureBuilder<List<DonationModel>>(
        future: DonationService().getMyDonations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          final donations = snapshot.data ?? [];

          if (donations.isEmpty) {
            return const Center(
              child: Text(
                'Henüz bağışınız bulunmuyor.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: donations.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final donation = donations[index];

              // YENİ EKLENEN METİN MANTIĞI: Tavşik için 2 Mama Bağışı
              final animalName = donation.animalName;
              String titleText;

              if (animalName != null && animalName.isNotEmpty) {
                titleText =
                    '$animalName için ${donation.count} ${_typeLabel(donation.donationType)}';
              } else {
                titleText =
                    '${donation.count} ${_typeLabel(donation.donationType)}';
              }

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 10,
                      offset: Offset(0, 4),
                      color: Colors.black12,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.pink.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.volunteer_activism,
                        color: AppColors.pink,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            titleText, // GÜNCELLENDİ
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tutar: ${donation.amount.toStringAsFixed(0)} TL',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
