import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/donation_service.dart';

class AllDonationsScreen extends StatefulWidget {
  const AllDonationsScreen({super.key});

  @override
  State<AllDonationsScreen> createState() => _AllDonationsScreenState();
}

class _AllDonationsScreenState extends State<AllDonationsScreen> {
  final _service = DonationService();
  late PageController _pageController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_pageController.hasClients) {
        final int nextPage = _pageController.page!.round() + 1;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  String _formatDonationStats(Map<String, dynamic> stats) {
    List<String> parts = [];
    if (stats['food'] > 0) parts.add('${stats['food']} Mama');
    if (stats['vaccine'] > 0) parts.add('${stats['vaccine']} Aşı');
    if (stats['spay'] > 0) parts.add('${stats['spay']} Kısır.');
    if (stats['treatment'] > 0) parts.add('${stats['treatment']} Tedavi');
    if (stats['care'] > 0) parts.add('${stats['care']} Bakım');

    return parts.isEmpty ? 'Bağış yaptı' : parts.join(', ');
  }

  String _label(String type) {
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
      appBar: AppBar(title: const Text('Topluluk Bağışları')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: const Text(
                'En Çok Destek Olan Kahramanlarımız',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.purple,
                ),
              ),
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _service.getTop7Donors(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 50,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SizedBox(
                    height: 50,
                    child: Center(child: Text('Henüz bağış verisi yok.')),
                  );
                }

                final topDonors = snapshot.data!;

                return Container(
                  height: 48,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.purple.withOpacity(0.3),
                    ),
                  ),
                  child: PageView.builder(
                    controller: _pageController,
                    itemBuilder: (context, index) {
                      final donor = topDonors[index % topDonors.length];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.workspace_premium,
                              color: Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${donor['name']} ➔ ${_formatDonationStats(donor)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.dark,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: const Text(
                'Son 30 Günün Bağışları',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _service.getRecentDonations30Days(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Son 30 günde bağış yapılmadı.'),
                    ),
                  );
                }

                final recentDonations = snapshot.data!;

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: recentDonations.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final donation = recentDonations[index];
                    final profile =
                        donation['profiles'] as Map<String, dynamic>?;
                    final donorName =
                        profile?['name']?.toString() ?? 'İsimsiz Kahraman';

                    final createdAt =
                        DateTime.parse(donation['created_at']).toLocal();
                    final dateString =
                        "${createdAt.day}/${createdAt.month}/${createdAt.year}";

                    // YENİ EKLENEN METİN MANTIĞI: Tavşik için 2 Mama bağışı yaptı
                    final animalName = donation['animal_name']?.toString();
                    final countStr = donation['count']?.toString() ?? '1';
                    final typeStr = _label(donation['donation_type']);

                    String actionText;
                    if (animalName != null && animalName.isNotEmpty) {
                      actionText = '$animalName için $countStr $typeStr yaptı';
                    } else {
                      actionText = '$countStr $typeStr yaptı';
                    }

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 14,
                            offset: Offset(0, 6),
                            color: Colors.black12,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.green.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.favorite,
                              color: AppColors.green,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  donorName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  actionText, // GÜNCELLENDİ
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            dateString,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
