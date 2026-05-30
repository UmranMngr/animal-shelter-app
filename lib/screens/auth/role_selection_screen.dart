import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Lottie paketini eklemeyi unutma
import '../../widgets/app_logo_title.dart';
import '../../widgets/gradient_background.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  void _goLogin(BuildContext context, String role) {
    Navigator.pushNamed(context, '/login', arguments: role);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          top:
              false, // Logonun en üste çıkması için SafeAre'yı üstten kapatıyoruz
          child: SingleChildScrollView(
            // BURADAKİ PADDING'İ SİLDİK: padding: const EdgeInsets.symmetric(...)
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. ÜST TARAF VE KENARLARA TAM YAPIŞAN LOGO
                const AppLogoTitle(title: 'Patili Dostlar'),

                // 2. DİĞER İÇERİKLER İÇİN ÖZEL PADDING
                // 2. DİĞER İÇERİKLER İÇİN ÖZEL PADDING (Logodan hemen sonra başlar)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24, // Sağdan ve soldan 24 birim boşluk
                    vertical: 50, // Üstten ve alttan 20 birim boşluk
                  ),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 40,
                      ), // Balonun sığması için logodan sonra ekstra boşluk
                      // KÖPEK VE KONUŞMA BALONU (Sanki o söylüyor gibi)
                      Stack(
                        alignment: Alignment.bottomCenter,
                        clipBehavior: Clip.none,
                        children: [
                          // 1. Köpek Animasyonu
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.22,
                            child: Lottie.asset(
                              'lib/assets/animations/happy_dog.json',
                              fit: BoxFit.contain,
                            ),
                          ),

                          Positioned(
                            left: 115,
                            top: -60,
                            child: const _SpeechBubble(),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 50,
                      ), // Balonlu köpekten sonra kartlara kadar olan boşluk
                      // Giriş Kartları
                      _RoleCard(
                        icon: Icons.volunteer_activism,
                        title: 'Kullanıcı Girişi',
                        subtitle:
                            'Mama, aşı, kısırlaştırma ve destek bağışları',
                        onTap: () => _goLogin(context, 'donor'),
                      ),

                      const SizedBox(height: 20), // İki kart arasındaki boşluk

                      _RoleCard(
                        icon: Icons.home_work_rounded,
                        title: 'Barınak Sahibi Girişi',
                        subtitle:
                            'Hayvan ekleme, başvuru onayı ve yönetim paneli',
                        onTap: () => _goLogin(context, 'shelter'),
                      ),

                      const SizedBox(
                        height: 40,
                      ), // En altta güvenli bir bitiş boşluğu
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({super.key}); // text parametresini sildik

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. ANA BALONCUK
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10),
            ],
          ),
          child: Text(
            'Barınak uygulamana\nhoş geldin ❤️',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 15,
              fontWeight: FontWeight.bold,
              fontFamily: 'Quicksand',
              height: 1.2,
              shadows: [
                Shadow(
                  color: Colors.black38,
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 6),

        // 2. ORTA BOY YUVARLAK
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(left: 35),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(height: 4),

        // 3. EN KÜÇÜK YUVARLAK
        Container(
          width: 7,
          height: 7,
          margin: const EdgeInsets.only(left: 25),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}

// _RoleCard kısmında küçük bir görsel iyileştirme (Cam efekti vurgusu)
class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.white54,
                ), // Yönlendirme ikonu
              ],
            ),
          ),
        ),
      ),
    );
  }
}
