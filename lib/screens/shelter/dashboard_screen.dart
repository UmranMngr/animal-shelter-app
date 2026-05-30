import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../services/animal_service.dart';
import '../../services/adoption_service.dart';
import '../../services/donation_service.dart';
import '../../widgets/stat_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _donationService = DonationService();

  Future<_DashboardData> _load() async {
    final animalService = AnimalService();
    final adoptionService = AdoptionService();

    final totals = await _donationService.getTotalsByType();
    final animals = await animalService.getAnimals(availableOnly: false);
    final requests = await adoptionService.getAllRequests();

    return _DashboardData(
      food: totals['food'] ?? 0,
      vaccine: totals['vaccine'] ?? 0,
      spay: totals['spay'] ?? 0,
      treatment: totals['treatment'] ?? 0,
      care: totals['care'] ?? 0,
      totalAnimals: animals.length,
      pendingRequests:
          requests.where((e) => e['status']?.toString() == 'pending').length,
    );
  }

  Future<void> _showEditPricesDialog() async {
    // Mevcut fiyatları çek
    final prices = await _donationService.getPrices();

    final foodCtrl = TextEditingController(text: prices['food'].toString());
    final vacCtrl = TextEditingController(text: prices['vaccine'].toString());
    final spayCtrl = TextEditingController(text: prices['spay'].toString());
    final treatCtrl = TextEditingController(
      text: prices['treatment'].toString(),
    );
    final careCtrl = TextEditingController(text: prices['care'].toString());

    if (!mounted) return;

    await showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text(
              'Bağış Fiyatlarını Düzenle',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: foodCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Mama Fiyatı (TL)',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: vacCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Aşı Fiyatı (TL)',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: spayCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Kısırlaştırma Fiyatı (TL)',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: treatCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Tedavi Fiyatı (TL)',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: careCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Bakım Fiyatı (TL)',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('İptal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await _donationService.updatePrices(
                    double.tryParse(foodCtrl.text) ?? 200,
                    double.tryParse(vacCtrl.text) ?? 500,
                    double.tryParse(spayCtrl.text) ?? 1500,
                    double.tryParse(treatCtrl.text) ?? 1000,
                    double.tryParse(careCtrl.text) ?? 300,
                  );
                  setState(() {}); // Ekranı yenile
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fiyatlar güncellendi')),
                  );
                },
                child: const Text('Kaydet'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note, color: Colors.purple, size: 28),
            onPressed: _showEditPricesDialog,
            tooltip: 'Fiyatları Düzenle',
          ),
        ],
      ),
      body: FutureBuilder<_DashboardData>(
        future: _load(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text('Hata: ${snapshot.error}'));

          final data = snapshot.data!;
          final total =
              data.food + data.vaccine + data.spay + data.treatment + data.care;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.25,
                  children: [
                    StatCard(
                      title: 'Toplam Hayvan',
                      value: data.totalAnimals.toString(),
                      icon: Icons.pets,
                      color: AppColors.purple,
                    ),
                    StatCard(
                      title: 'Bekleyen Başvuru',
                      value: data.pendingRequests.toString(),
                      icon: Icons.pending_actions,
                      color: AppColors.pink,
                    ),
                    StatCard(
                      title: 'Toplam Bağış',
                      value: '${total.toStringAsFixed(0)} TL',
                      icon: Icons.volunteer_activism,
                      color: AppColors.blue,
                    ),
                    StatCard(
                      title: 'Tedavi & Bakım',
                      value:
                          '${(data.treatment + data.care).toStringAsFixed(0)} TL',
                      icon: Icons.medical_services,
                      color: AppColors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 16,
                        offset: Offset(0, 6),
                        color: Colors.black12,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Bağış Dağılımı',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 260,
                        child:
                            total == 0
                                ? const Center(child: Text('Henüz veri yok'))
                                : PieChart(
                                  PieChartData(
                                    centerSpaceRadius: 48,
                                    sectionsSpace: 4,
                                    sections: [
                                      if (data.food > 0)
                                        PieChartSectionData(
                                          value: data.food,
                                          title: 'Mama',
                                          color: AppColors.purple,
                                          radius: 60,
                                          titleStyle: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      if (data.vaccine > 0)
                                        PieChartSectionData(
                                          value: data.vaccine,
                                          title: 'Aşı',
                                          color: AppColors.blue,
                                          radius: 60,
                                          titleStyle: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      if (data.spay > 0)
                                        PieChartSectionData(
                                          value: data.spay,
                                          title: 'Kısır',
                                          color: AppColors.pink,
                                          radius: 60,
                                          titleStyle: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      if (data.treatment > 0)
                                        PieChartSectionData(
                                          value: data.treatment,
                                          title: 'Tedavi',
                                          color: AppColors.green,
                                          radius: 60,
                                          titleStyle: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      if (data.care > 0)
                                        PieChartSectionData(
                                          value: data.care,
                                          title: 'Bakım',
                                          color: Colors.orange,
                                          radius: 60,
                                          titleStyle: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DashboardData {
  final double food, vaccine, spay, treatment, care;
  final int totalAnimals, pendingRequests;
  _DashboardData({
    required this.food,
    required this.vaccine,
    required this.spay,
    required this.treatment,
    required this.care,
    required this.totalAnimals,
    required this.pendingRequests,
  });
}
