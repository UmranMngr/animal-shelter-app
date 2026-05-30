import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../services/profile_service.dart';
import '../../core/constants/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final ProfileService _profileService = ProfileService();
  late final ConfettiController _confettiController = ConfettiController(
    duration: const Duration(seconds: 2),
  );

  int _currentPage = 0;
  final int _totalPages = 4;
  bool _isLoading = false;

  // Sayfa 1
  final TextEditingController _nameCtrl = TextEditingController();
  DateTime? _selectedDate;

  // Sayfa 2
  final TextEditingController _occupationCtrl = TextEditingController();
  String? _livingSpace;

  // Sayfa 3
  bool? _hasExperience;
  bool? _hasCurrentPet;
  final TextEditingController _petDetailsCtrl = TextEditingController();

  // Sayfa 4
  bool? _hasChildren;
  String? _aloneTime;

  @override
  void dispose() {
    _pageController.dispose();
    _nameCtrl.dispose();
    _occupationCtrl.dispose();
    _petDetailsCtrl.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  bool _canGoNext() {
    if (_currentPage == 0) {
      return _nameCtrl.text.trim().isNotEmpty && _selectedDate != null;
    } else if (_currentPage == 1) {
      return _occupationCtrl.text.trim().isNotEmpty && _livingSpace != null;
    } else if (_currentPage == 2) {
      if (_hasCurrentPet == true) {
        return _hasExperience != null && _petDetailsCtrl.text.trim().isNotEmpty;
      }
      return _hasExperience != null && _hasCurrentPet != null;
    } else if (_currentPage == 3) {
      return _hasChildren != null && _aloneTime != null;
    }
    return true;
  }

  Future<void> _nextPage() async {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      await _submitData();
    }
  }

  Future<void> _submitData() async {
    setState(() => _isLoading = true);
    try {
      final data = {
        'name': _nameCtrl.text.trim(),
        'birthDate': _selectedDate?.toIso8601String(),
        'occupation': _occupationCtrl.text.trim(),
        'hasPriorExperience': _hasExperience,
        'hasCurrentPet': _hasCurrentPet,
        'currentPetDetails':
            _hasCurrentPet == true ? _petDetailsCtrl.text.trim() : null,
        'livingSpace': _livingSpace,
        'hasChildren': _hasChildren,
        'aloneTime': _aloneTime,
      };

      await _profileService.saveOnboardingData(data);
      _confettiController.play();

      if (!mounted) return;

      // Başarı Ekranı
      showDialog(
        barrierDismissible: false,
        context: context,
        builder:
            (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 60),
                  const SizedBox(height: 16),
                  const Text(
                    'Harika!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Profiliniz patili dostlarımızla tanışmak için artık hazır.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purple,
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    child: const Text(
                      'Ana Sayfaya Git',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hata: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildOptionTile(String title, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.purple.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.purple : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.purple : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.purple),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                // İlerleme Çubuğu (Progress Bar)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Row(
                    children: [
                      if (_currentPage > 0)
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, size: 20),
                          onPressed:
                              () => _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              ),
                        )
                      else
                        const SizedBox(width: 48), // Dengelemek için

                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: (_currentPage + 1) / _totalPages,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.purple,
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                // Sayfalar
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics:
                        const NeverScrollableScrollPhysics(), // Kaydırmayı engelle, sadece butonla geçilsin
                    onPageChanged: (idx) => setState(() => _currentPage = idx),
                    children: [
                      // SAYFA 1
                      _buildPageContainer(
                        title: "Tanışalım! 🐾",
                        subtitle:
                            "Sıcak bir 'merhaba' diyebilmemiz için bize biraz kendinizden bahseder misiniz?",
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Adınız ve Soyadınız',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _nameCtrl,
                              decoration: const InputDecoration(
                                hintText: 'Örn: Merve Adalı',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Doğum Tarihiniz',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Yasal sahiplenme prosedürleri için 18 yaş kontrolü yapmamız gerekiyor.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime(2000),
                                  firstDate: DateTime(1930),
                                  lastDate: DateTime.now(),
                                );
                                if (date != null)
                                  setState(() => _selectedDate = date);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _selectedDate == null
                                          ? 'Doğum tarihinizi seçin'
                                          : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                                      style: TextStyle(
                                        color:
                                            _selectedDate == null
                                                ? Colors.grey.shade600
                                                : Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.calendar_today,
                                      color: AppColors.purple,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // SAYFA 2
                      _buildPageContainer(
                        title: "Yaşam Tarzınız 🏡",
                        subtitle:
                            "Patili dostlarımızın ihtiyaçlarına uygun doğru eşleşmeyi bulabilmemiz için önemli detaylar.",
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Mesleğiniz / Çalışma Durumunuz?',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Dostunuza ayırabileceğiniz vakti öngörebilmemiz için minik bir ipucu!',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _occupationCtrl,
                              decoration: const InputDecoration(
                                hintText:
                                    'Örn: Öğrenci, Yazılımcı, Evden Çalışan',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Nasıl bir evde yaşıyorsunuz?',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            _buildOptionTile(
                              'Apartman Dairesi',
                              _livingSpace == 'Apartman Dairesi',
                              () => setState(
                                () => _livingSpace = 'Apartman Dairesi',
                              ),
                            ),
                            _buildOptionTile(
                              'Bahçeli Müstakil Ev',
                              _livingSpace == 'Bahçeli Müstakil Ev',
                              () => setState(
                                () => _livingSpace = 'Bahçeli Müstakil Ev',
                              ),
                            ),
                            _buildOptionTile(
                              'Site İçi / Güvenlikli Alan',
                              _livingSpace == 'Site İçi / Güvenlikli Alan',
                              () => setState(
                                () =>
                                    _livingSpace = 'Site İçi / Güvenlikli Alan',
                              ),
                            ),
                          ],
                        ),
                      ),

                      // SAYFA 3
                      _buildPageContainer(
                        title: "Tüylü Dostlarla Geçmişiniz 🐕",
                        subtitle:
                            "Patili ev arkadaşlığı konusunda ne kadar tecrübelisiniz?",
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Daha önce tüylü bir dosta ev arkadaşlığı yaptınız mı?',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            _buildOptionTile(
                              'Evet, epey tecrübeliyim',
                              _hasExperience == true,
                              () => setState(() => _hasExperience = true),
                            ),
                            _buildOptionTile(
                              'Hayır, bu ilk heyecanım olacak!',
                              _hasExperience == false,
                              () => setState(() => _hasExperience = false),
                            ),
                            const SizedBox(height: 20),

                            const Text(
                              'Şu an evinizi paylaştığınız patili bir dostunuz var mı?',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            _buildOptionTile(
                              'Evet, var',
                              _hasCurrentPet == true,
                              () => setState(() => _hasCurrentPet = true),
                            ),
                            _buildOptionTile(
                              'Hayır, yok',
                              _hasCurrentPet == false,
                              () => setState(() {
                                _hasCurrentPet = false;
                                _petDetailsCtrl.clear();
                              }),
                            ),

                            // Animasyonlu ekstra soru alanı
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: _hasCurrentPet == true ? 120 : 0,
                              clipBehavior: Clip.hardEdge,
                              decoration: const BoxDecoration(),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Ne harika! Onun türü ve cinsi nedir?',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.purple,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '(Yeni gelecek dostumuzla anlaşıp anlaşamayacaklarını tahmin etmemiz için çok önemli.)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: _petDetailsCtrl,
                                      decoration: const InputDecoration(
                                        hintText:
                                            'Örn: Kedi - Tekir, 3 Yaşında',
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (_) => setState(() {}),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // SAYFA 4
                      _buildPageContainer(
                        title: "Ev Ortamı 🧸",
                        subtitle:
                            "Son birkaç küçük detayla profilinizi tamamlıyoruz.",
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Evinizde sizinle yaşayan küçük bir çocuk veya bebek var mı?',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            _buildOptionTile(
                              'Evet, evde çocuk var',
                              _hasChildren == true,
                              () => setState(() => _hasChildren = true),
                            ),
                            _buildOptionTile(
                              'Hayır, çocuk yok',
                              _hasChildren == false,
                              () => setState(() => _hasChildren = false),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Patili dostumuz gün içinde evde ortalama ne kadar yalnız kalacak?',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            _buildOptionTile(
                              'Çoğunlukla evdeyim',
                              _aloneTime == 'Çoğunlukla evdeyim',
                              () => setState(
                                () => _aloneTime = 'Çoğunlukla evdeyim',
                              ),
                            ),
                            _buildOptionTile(
                              '4-6 Saat arası',
                              _aloneTime == '4-6 Saat arası',
                              () =>
                                  setState(() => _aloneTime = '4-6 Saat arası'),
                            ),
                            _buildOptionTile(
                              '8 Saatten fazla',
                              _aloneTime == '8 Saatten fazla',
                              () => setState(
                                () => _aloneTime = '8 Saatten fazla',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // İleri Butonu Alt Kısım
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: const Offset(0, -4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _canGoNext()
                                ? AppColors.purple
                                : Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _canGoNext() && !_isLoading ? _nextPage : null,
                      child:
                          _isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : Text(
                                _currentPage == _totalPages - 1
                                    ? 'Profili Tamamla'
                                    : 'İleri',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      _canGoNext()
                                          ? Colors.white
                                          : Colors.grey.shade500,
                                ),
                              ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Konfeti!
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: 3.14 / 2,
            maxBlastForce: 5,
            minBlastForce: 2,
            emissionFrequency: 0.05,
            numberOfParticles: 50,
            gravity: 0.1,
          ),
        ),
      ],
    );
  }

  // Yardımcı Widget: Sayfa İskeleti
  Widget _buildPageContainer({
    required String title,
    required String subtitle,
    required Widget content,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          content,
          const SizedBox(height: 32), // Alt boşluk
        ],
      ),
    );
  }
}
