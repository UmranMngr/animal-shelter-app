import 'dart:async'; // EKLENDİ: StreamSubscription kullanabilmek için
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // EKLENDİ: AuthChangeEvent ve AuthState için
import '../../services/auth_service.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _authService = AuthService();

  bool _loading = false;
  StreamSubscription<AuthState>?
  _authStateSubscription; // EKLENDİ: Dinleyiciyi tanımlıyoruz

  @override
  void initState() {
    super.initState();

    // EKLENDİ: Sayfa açılır açılmaz giriş durumunu dinlemeye başlıyoruz
    _authStateSubscription = Supabase.instance.client.auth.onAuthStateChange
        .listen((data) {
          final AuthChangeEvent event = data.event;
          if (event == AuthChangeEvent.signedIn) {
            // E-posta onaylandı ve kullanıcı giriş yaptı, direkt ana sayfaya yönlendir
            if (mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              );
            }
          }
        });
  }

  @override
  void dispose() {
    // EKLENDİ: Sayfa kapanırken dinleyiciyi iptal ediyoruz ki arka planda çalışmaya devam etmesin
    _authStateSubscription?.cancel();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await _authService.signIn(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Giriş başarısız: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final role =
        (ModalRoute.of(context)?.settings.arguments as String?) ?? 'donor';
    final title =
        role == 'shelter' ? 'Barınak Sahibi Girişi' : 'Kullanıcı Girişi';

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.96),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 24,
                      offset: Offset(0, 10),
                      color: Colors.black12,
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 6),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _emailCtrl,
                        decoration: const InputDecoration(labelText: 'E-posta'),
                        validator:
                            (v) =>
                                v == null || v.trim().isEmpty
                                    ? 'E-posta gerekli'
                                    : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Şifre'),
                        validator:
                            (v) =>
                                v == null || v.trim().isEmpty
                                    ? 'Şifre gerekli'
                                    : null,
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        text: 'Giriş Yap',
                        loading: _loading,
                        onPressed: _login,
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/register',
                            arguments: role,
                          );
                        },
                        child: const Text('Hesabın yok mu? Kayıt ol'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
