import 'package:flutter/material.dart';
import '../../services/adoption_service.dart';

class AdoptionRequestsScreen extends StatefulWidget {
  const AdoptionRequestsScreen({super.key});

  @override
  State<AdoptionRequestsScreen> createState() => _AdoptionRequestsScreenState();
}

class _AdoptionRequestsScreenState extends State<AdoptionRequestsScreen> {
  final service = AdoptionService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sahiplenme Başvuruları')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: service.getShelterRequests(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data!;

          if (requests.isEmpty) {
            return const Center(child: Text('Başvuru yok'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = requests[index];
              final animal = item['animals'] as Map<String, dynamic>? ?? {};
              final profile = item['profiles'] as Map<String, dynamic>? ?? {};
              final status = item['status']?.toString() ?? 'pending';

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 16,
                      offset: Offset(0, 6),
                      color: Colors.black12,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      animal['name']?.toString() ?? 'Hayvan',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Başvuran: ${profile['name']?.toString() ?? profile['email']?.toString() ?? ''}',
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Durum: ${status == 'approved' ? 'Onaylandı' : 'Bekliyor'}',
                    ),
                    const SizedBox(height: 12),

                    // DURUM ONAYLANDI İSE YAZI GÖSTER, DEĞİLSE BUTONLARI GÖSTER
                    status == 'approved'
                        ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Onaylandı',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                        : Row(
                          children: [
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              onPressed: () async {
                                try {
                                  await service.approve(
                                    item['id'].toString(),
                                    item['animal_id'].toString(),
                                  );
                                  if (!mounted) return;
                                  setState(
                                    () {},
                                  ); // Ekranı "Onaylandı" yazması için yenile
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Başvuru onaylandı'),
                                    ),
                                  );
                                } catch (e) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Hata: $e')),
                                  );
                                }
                              },
                              icon: const Icon(
                                Icons.check,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Onayla',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 10),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              onPressed: () async {
                                try {
                                  await service.reject(item['id'].toString());
                                  if (!mounted) return;
                                  setState(
                                    () {},
                                  ); // Listeden silinmesi için ekranı yenile
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Başvuru reddedildi ve silindi',
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Hata: $e')),
                                  );
                                }
                              },
                              icon: const Icon(Icons.close),
                              label: const Text('Reddet'),
                            ),
                          ],
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
