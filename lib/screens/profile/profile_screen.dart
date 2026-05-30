import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/profile_service.dart';
import '../../services/storage_service.dart';
import '../../core/constants/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profileService = ProfileService();
  final _storageService = StorageService();
  final _authService = AuthService();

  bool _isLoadingData = true;
  bool _saving = false;

  // Profil Verileri
  String _email = '';
  String _role = 'donor';
  String? _avatarUrl;

  // Form Kontrolcüleri
  final _nameCtrl = TextEditingController();
  final _occupationCtrl = TextEditingController();
  final _petDetailsCtrl = TextEditingController();

  DateTime? _birthDate;
  String? _livingSpace;
  String? _aloneTime;
  bool _hasExperience = false;
  bool _hasCurrentPet = false;
  bool _hasChildren = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _occupationCtrl.dispose();
    _petDetailsCtrl.dispose();
    super.dispose();
  }

  // SAYFA AÇILIRKEN VERİLERİ 1 KEZ ÇEKİYORUZ (Yazı yazarken silinmemesi için)
  Future<void> _loadProfileData() async {
    try {
      final profile = await _profileService.getMyProfile();
      if (mounted) {
        setState(() {
          _email = profile['email']?.toString() ?? '';
          _role = profile['role']?.toString() ?? 'donor';
          _nameCtrl.text = profile['name']?.toString() ?? '';
          _avatarUrl = profile['avatar_url']?.toString();

          // Sadece Barınak Olmayanlar (Kullanıcılar) için ekstra veriler
          if (_role != 'shelter') {
            _occupationCtrl.text = profile['occupation']?.toString() ?? '';
            _petDetailsCtrl.text =
                profile['current_pet_details']?.toString() ?? '';

            if (profile['birth_date'] != null) {
              _birthDate = DateTime.tryParse(profile['birth_date'].toString());
            }
            _livingSpace = profile['living_space']?.toString();
            _aloneTime = profile['alone_time']?.toString();

            _hasExperience = profile['has_prior_experience'] == true;
            _hasCurrentPet = profile['has_current_pet'] == true;
            _hasChildren = profile['has_children'] == true;
          }

          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingData = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Profil yüklenemedi: $e')));
      }
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _saving = true);
    try {
      // Temel Güncelleme Verileri
      final updateData = <String, dynamic>{
        'name': _nameCtrl.text.trim(),
        'avatar_url': _avatarUrl,
      };

      // Kullanıcıysa ekstra verileri de ekle
      if (_role != 'shelter') {
        updateData.addAll({
          'occupation': _occupationCtrl.text.trim(),
          'birth_date': _birthDate?.toIso8601String(),
          'living_space': _livingSpace,
          'alone_time': _aloneTime,
          'has_prior_experience': _hasExperience,
          'has_current_pet': _hasCurrentPet,
          'current_pet_details':
              _hasCurrentPet ? _petDetailsCtrl.text.trim() : null,
          'has_children': _hasChildren,
        });
      }

      await _profileService.updateFullProfile(updateData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil başarıyla güncellendi')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hata: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // --- AVATAR İŞLEMLERİ (Aynı kaldı) ---
  void _showAvatarOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (ctx) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library,
                    color: Colors.purple,
                  ),
                  title: const Text('Yeni Fotoğraf Yükle'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickAvatar();
                  },
                ),
                if (_avatarUrl != null)
                  ListTile(
                    leading: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                    ),
                    title: const Text(
                      'Mevcut Resmi Kaldır',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      _removeAvatar();
                    },
                  ),
                const SizedBox(height: 10),
              ],
            ),
          ),
    );
  }

  Future<void> _pickAvatar() async {
    setState(() => _saving = true);
    try {
      final url = await _storageService.pickAndUploadAvatar();
      if (url != null && mounted) {
        setState(() => _avatarUrl = url);
        await _saveProfile();
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _removeAvatar() async {
    setState(() => _saving = true);
    try {
      await _profileService.removeAvatar();
      setState(() => _avatarUrl = null);
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil resmi kaldırıldı.')),
        );
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Çıkış Yap'),
            content: const Text('Çıkış yapmak istediğinize emin misiniz?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Vazgeç'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Çıkış Yap',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await _authService.signOut();
      if (mounted)
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- ÜST PROFİL KARTI ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                  GestureDetector(
                    onTap: _saving ? null : _showAvatarOptions,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: Colors.purple.shade50,
                          backgroundImage:
                              _avatarUrl != null
                                  ? NetworkImage(_avatarUrl!)
                                  : null,
                          child:
                              _avatarUrl == null
                                  ? const Icon(
                                    Icons.person,
                                    size: 48,
                                    color: Colors.purple,
                                  )
                                  : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.purple,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _nameCtrl.text.isEmpty
                        ? 'İsimsiz Kullanıcı'
                        : _nameCtrl.text,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(_email),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _role == 'shelter' ? 'Barınak Sahibi' : 'Kullanıcı',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- TEMEL BİLGİLER FORMU ---
            const Text(
              'Temel Bilgiler',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.purple,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Ad Soyad',
                border: OutlineInputBorder(),
              ),
            ),

            // --- KULLANICIYA ÖZEL DETAYLI BİLGİLER ---
            if (_role != 'shelter') ...[
              const SizedBox(height: 24),
              const Text(
                'Kişisel & Yaşam Tarzı',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.purple,
                ),
              ),
              const SizedBox(height: 12),

              // Doğum Tarihi
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _birthDate ?? DateTime(2000),
                    firstDate: DateTime(1930),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) setState(() => _birthDate = date);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _birthDate == null
                            ? 'Doğum Tarihi Seçiniz'
                            : 'Doğum Tarihi: ${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}',
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              _birthDate == null
                                  ? Colors.grey.shade600
                                  : Colors.black87,
                        ),
                      ),
                      const Icon(Icons.calendar_today, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Meslek
              TextField(
                controller: _occupationCtrl,
                decoration: const InputDecoration(
                  labelText: 'Meslek / Çalışma Durumu',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Yaşam Alanı
              DropdownButtonFormField<String>(
                value: _livingSpace,
                decoration: const InputDecoration(
                  labelText: 'Yaşam Alanı',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Apartman Dairesi',
                    child: Text('Apartman Dairesi'),
                  ),
                  DropdownMenuItem(
                    value: 'Bahçeli Müstakil Ev',
                    child: Text('Bahçeli Müstakil Ev'),
                  ),
                  DropdownMenuItem(
                    value: 'Site İçi / Güvenlikli Alan',
                    child: Text('Site İçi / Güvenlikli Alan'),
                  ),
                ],
                onChanged: (val) => setState(() => _livingSpace = val),
              ),
              const SizedBox(height: 16),

              // Yalnızlık Süresi
              DropdownButtonFormField<String>(
                value: _aloneTime,
                decoration: const InputDecoration(
                  labelText: 'Evde Yalnız Kalma Süresi',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Çoğunlukla evdeyim',
                    child: Text('Çoğunlukla evdeyim'),
                  ),
                  DropdownMenuItem(
                    value: '4-6 Saat arası',
                    child: Text('4-6 Saat arası'),
                  ),
                  DropdownMenuItem(
                    value: '8 Saatten fazla',
                    child: Text('8 Saatten fazla'),
                  ),
                ],
                onChanged: (val) => setState(() => _aloneTime = val),
              ),

              const SizedBox(height: 16),

              // Switch Kontrolleri
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Daha önce hayvan baktım'),
                activeColor: AppColors.purple,
                value: _hasExperience,
                onChanged: (val) => setState(() => _hasExperience = val),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Evde çocuk/bebek var'),
                activeColor: AppColors.purple,
                value: _hasChildren,
                onChanged: (val) => setState(() => _hasChildren = val),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Şu an evde baktığım hayvan var'),
                activeColor: AppColors.purple,
                value: _hasCurrentPet,
                onChanged: (val) {
                  setState(() {
                    _hasCurrentPet = val;
                    if (!val) _petDetailsCtrl.clear();
                  });
                },
              ),

              // Evde hayvan varsa detayı aç
              if (_hasCurrentPet)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                  child: TextField(
                    controller: _petDetailsCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Hayvanın Türü ve Cinsi',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
            ],

            const SizedBox(height: 32),

            // --- KAYDET BUTONU ---
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purple,
                ),
                child:
                    _saving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          'Profili Güncelle',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
              ),
            ),

            const SizedBox(height: 24),

            // --- ALT MENÜ BUTONLARI ---
            if (_role != 'shelter') ...[
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/my-requests'),
                  icon: const Icon(Icons.assignment),
                  label: const Text('Sahiplenme Başvurularım'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink.shade400,
                    foregroundColor: Colors.white,
                  ),
                  onPressed:
                      () => Navigator.pushNamed(context, '/my-donations'),
                  icon: const Icon(Icons.favorite_border),
                  label: const Text('Kişisel Bağış Geçmişim'),
                ),
              ),
              const SizedBox(height: 12),
            ],

            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: _confirmSignOut,
                child: const Text(
                  'Çıkış Yap',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
