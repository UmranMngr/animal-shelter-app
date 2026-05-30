import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../models/animal_model.dart';
import '../../services/donation_service.dart';

class DonationScreen extends StatefulWidget {
  final AnimalModel? animal;
  const DonationScreen({super.key, this.animal});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  final _service = DonationService();
  late final ConfettiController _confettiController = ConfettiController(
    duration: const Duration(seconds: 3),
  );

  String _donationType = 'food';
  int _count = 1;
  bool _loading = false;
  Map<String, double> _prices = {};

  bool _hasSpayDonation = false;
  bool _isCheckingData = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final prices = await _service.getPrices();
    bool hasSpay = false;

    if (widget.animal != null) {
      hasSpay = await _service.checkSpayDonationExists(widget.animal!.name);
    }

    if (mounted) {
      setState(() {
        _prices = prices;
        _hasSpayDonation = hasSpay;
        _isCheckingData = false;
      });
    }
  }

  String _typeLabel(String value) {
    switch (value) {
      case 'food':
        return 'Mama';
      case 'vaccine':
        return 'Aşı';
      case 'spay':
        return 'Kısırlaştırma';
      case 'treatment':
        return 'Tedavi';
      case 'care':
        return 'Bakım';
      default:
        return value;
    }
  }

  double get _currentTotal => (_prices[_donationType] ?? 0) * _count;

  List<DropdownMenuItem<String>> _buildDonationOptions() {
    List<DropdownMenuItem<String>> items = [
      const DropdownMenuItem(value: 'food', child: Text('Mama Bağışı')),
      const DropdownMenuItem(value: 'vaccine', child: Text('Aşı Bağışı')),
      const DropdownMenuItem(value: 'care', child: Text('Bakım Bağışı')),
    ];

    final animal = widget.animal;

    if (animal == null) {
      items.add(
        const DropdownMenuItem(value: 'spay', child: Text('Kısırlaştırma')),
      );
    } else if (animal.isSpayed == false && _hasSpayDonation == false) {
      items.add(
        const DropdownMenuItem(value: 'spay', child: Text('Kısırlaştırma')),
      );
    }

    if (animal == null || animal.status == 'treatment') {
      items.add(
        const DropdownMenuItem(value: 'treatment', child: Text('Tedavi')),
      );
    }

    return items;
  }

  void _showConfirmation() {
    final typeName = _typeLabel(_donationType);
    final totalStr = _currentTotal.toStringAsFixed(0);

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Bağış Onayı', textAlign: TextAlign.center),
            content: Text(
              '$_count Adet $typeName ($totalStr TL) bağışını onaylıyor musunuz?',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'İptal',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () {
                  Navigator.pop(ctx);
                  _submit();
                },
                child: const Text(
                  'Evet, Onaylıyorum',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      await _service.createDonation(
        donationType: _donationType,
        amount: _currentTotal,
        count: _count,
        animalName: widget.animal?.name,
      );

      if (!mounted) return;

      _confettiController.play();

      showDialog(
        context: context,
        builder:
            (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  const Text(
                    'Desteğiniz İçin Teşekkürler!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Patili dostlarımız adına size minnettarız.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      if (widget.animal != null && _donationType == 'spay') {
                        setState(() {
                          _hasSpayDonation = true;
                          _donationType = 'food';
                        });
                      }
                    },
                    child: const Text('Harika!'),
                  ),
                ],
              ),
            ),
      );

      setState(() => _count = 1);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hata: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final animal = widget.animal;

    // YENİDEN EKLENEN MANTIK: Belirli bir hayvan için mi kısırlaştırma seçildi?
    final bool isSingleAnimalSpay = animal != null && _donationType == 'spay';

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(title: const Text('Bağış Yap')),
          body:
              _isCheckingData
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [
                              BoxShadow(
                                blurRadius: 20,
                                offset: Offset(0, 8),
                                color: Colors.black12,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (animal != null) ...[
                                Text(
                                  '${animal.name} için bağış',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text('${animal.species} • ${animal.age} yaş'),
                                const SizedBox(height: 18),

                                if (animal.isSpayed == false &&
                                    _hasSpayDonation)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.orange.withOpacity(0.3),
                                      ),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          color: Colors.orange,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Bu hayvan için kısırlaştırılma bağışı yapıldı.',
                                            style: TextStyle(
                                              color: Colors.orange,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                              DropdownButtonFormField<String>(
                                value: _donationType,
                                decoration: const InputDecoration(
                                  labelText: 'Bağış Türü',
                                ),
                                items: _buildDonationOptions(),
                                onChanged: (value) {
                                  if (value != null)
                                    setState(() {
                                      _donationType = value;
                                      _count = 1;
                                    });
                                },
                              ),
                              const SizedBox(height: 24),

                              const Text(
                                'Adet Seçiniz:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle,
                                      color: Colors.purple,
                                      size: 36,
                                    ),
                                    onPressed: () {
                                      if (_count > 1) setState(() => _count--);
                                    },
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    child: Text(
                                      '$_count',
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  // GÜNCELLENEN ARTI BUTONU KONTROLÜ (GERİ GELDİ!)
                                  IconButton(
                                    icon: Icon(
                                      Icons.add_circle,
                                      color:
                                          isSingleAnimalSpay
                                              ? Colors.grey
                                              : Colors.purple,
                                      size: 36,
                                    ),
                                    onPressed:
                                        isSingleAnimalSpay
                                            ? () {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Bir hayvan için sadece 1 adet kısırlaştırma bağışı yapılabilir.',
                                                  ),
                                                ),
                                              );
                                            }
                                            : () => setState(() => _count++),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),
                              Center(
                                child: Text(
                                  'Toplam: ${_currentTotal.toStringAsFixed(0)} TL',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.green,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed:
                                      _loading ? null : _showConfirmation,
                                  child:
                                      _loading
                                          ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                          : const Text(
                                            'Bağış Yap',
                                            style: TextStyle(fontSize: 18),
                                          ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.blue.shade100),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text(
                                    'Barınak Bağış Fiyat Listesi',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(color: Colors.blue),
                              const SizedBox(height: 4),
                              Text(
                                '• Mama (Adet): ${_prices['food']?.toStringAsFixed(0)} TL',
                              ),
                              Text(
                                '• Aşı (Adet): ${_prices['vaccine']?.toStringAsFixed(0)} TL',
                              ),
                              Text(
                                '• Kısırlaştırma (Adet): ${_prices['spay']?.toStringAsFixed(0)} TL',
                              ),
                              Text(
                                '• Tedavi (Adet): ${_prices['treatment']?.toStringAsFixed(0)} TL',
                              ),
                              Text(
                                '• Bakım (Adet): ${_prices['care']?.toStringAsFixed(0)} TL',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
        ),

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
}
