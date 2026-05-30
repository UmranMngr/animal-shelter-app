import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/profile_service.dart';
import '../../widgets/app_logo_title.dart';
import '../adoption/adoption_screen.dart';
import '../donation/donation_screen.dart';
import '../donation/all_donations_screen.dart'; // YENİ EKLENDİ
import '../profile/profile_screen.dart';
import '../shelter/adoption_requests_screen.dart';
import '../shelter/add_animal_screen.dart';
import '../shelter/dashboard_screen.dart';
import 'animal_list_screen.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: ProfileService().getMyProfile(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Profil yüklenemedi: ${snapshot.error}')),
          );
        }

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final role = (snapshot.data!['role']?.toString() ?? 'donor');
        return _HomeContent(role: role);
      },
    );
  }
}

class _HomeContent extends StatefulWidget {
  final String role;

  const _HomeContent({required this.role});

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  final _auth = AuthService();
  int _index = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    if (widget.role == 'shelter') {
      _pages = const [
        AnimalListScreen(showOnlyAvailable: false),
        AddAnimalScreen(),
        AdoptionRequestsScreen(),
        DashboardScreen(),
        ProfileScreen(),
      ];
    } else {
      _pages = const [
        AnimalListScreen(showOnlyAvailable: true),
        DonationScreen(),
        AdoptionScreen(),
        AllDonationsScreen(), // GÜNCELLENDİ (Eskiden MyDonationsScreen idi)
        ProfileScreen(),
      ];
    }
  }

  List<BottomNavigationBarItem> get _items {
    if (widget.role == 'shelter') {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Hayvanlar'),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_box_rounded),
          label: 'Ekle',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.fact_check_rounded),
          label: 'Başvurular',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_rounded),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ];
    }

    return const [
      BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Hayvanlar'),
      BottomNavigationBarItem(
        icon: Icon(Icons.volunteer_activism),
        label: 'Bağış',
      ),
      BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Sahiplenme'),
      BottomNavigationBarItem(
        icon: Icon(Icons.public),
        label: 'Topluluk',
      ), // GÜNCELLENDİ (İkon ve İsim)
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
    ];
  }

  String get _title {
    if (widget.role == 'shelter') {
      return const [
        'Hayvanlar',
        'Hayvan Ekle',
        'Başvurular',
        'Dashboard',
        'Profil',
      ][_index];
    }
    return const [
      'Hayvanlar',
      'Bağış',
      'Sahiplenme',
      'Topluluk', // GÜNCELLENDİ
      'Profil',
    ][_index];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: AppLogoTitle(
          title: 'Patili Dostlar',
          trailing: IconButton(
            onPressed: () async {
              await _auth.signOut();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            icon: const Icon(Icons.logout_rounded, color: Color(0xFFE37C9E)),
          ),
        ),
      ),
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.purple,
        unselectedItemColor: AppColors.muted,
        onTap: (value) => setState(() => _index = value),
        items: _items,
      ),
    );
  }
}
