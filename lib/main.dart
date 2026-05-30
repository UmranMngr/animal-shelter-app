import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://kmtswoukaamvrojufned.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttdHN3b3VrYWFtdnJvanVmbmVkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjczNjY3NzEsImV4cCI6MjA4Mjk0Mjc3MX0.yxogUX97by9xsdoq05UA_H1H2dGPZgTtcdL0IyMukKE',
  );
  runApp(const ShelterApp());
}

class ShelterApp extends StatelessWidget {
  const ShelterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shelter App',
      theme: ThemeData(fontFamily: 'Quicksand'),
      initialRoute: '/',
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
