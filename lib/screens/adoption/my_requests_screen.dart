import 'package:flutter/material.dart';
import '../../services/adoption_service.dart';

class MyRequestsScreen extends StatelessWidget {
  const MyRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = AdoptionService();

    return Scaffold(
      appBar: AppBar(title: const Text('Sahiplenme Başvurularım')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: service.getMyRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          final requests = snapshot.data ?? [];

          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pets, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    'Henüz bir sahiplenme başvurunuz yok.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final item = requests[index];
              final animal = item['animals'] as Map<String, dynamic>? ?? {};
              final status = item['status']?.toString() ?? 'pending';

              // TARİH FORMATLAMA (GG/AA/YYYY)
              final createdAtStr = item['created_at'];
              String formattedDate = "";
              if (createdAtStr != null) {
                final date = DateTime.parse(createdAtStr).toLocal();
                formattedDate = "${date.day}/${date.month}/${date.year}";
              }

              Color statusColor;
              String statusText;
              IconData statusIcon;

              if (status == 'approved') {
                statusColor = Colors.green;
                statusText = 'Onaylandı';
                statusIcon = Icons.check_circle;
              } else if (status == 'rejected') {
                statusColor = Colors.red;
                statusText = 'Reddedildi';
                statusIcon = Icons.cancel;
              } else {
                statusColor = Colors.orange;
                statusText = 'Değerlendiriliyor';
                statusIcon = Icons.access_time_filled;
              }

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(14),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      width: 64,
                      height: 64,
                      child:
                          animal['image_url'] != null &&
                                  animal['image_url'].toString().isNotEmpty
                              ? Image.network(
                                animal['image_url'],
                                fit: BoxFit.cover,
                              )
                              : Container(
                                color: Colors.purple.shade50,
                                child: const Icon(Icons.pets),
                              ),
                    ),
                  ),
                  // BAŞLIK KISMINA TARİH EKLENDİ
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        animal['name']?.toString() ?? 'Bilinmeyen Hayvan',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, size: 14, color: statusColor),
                              const SizedBox(width: 4),
                              Text(
                                statusText,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
