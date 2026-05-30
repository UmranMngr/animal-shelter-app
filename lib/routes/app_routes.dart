import 'package:flutter/material.dart';

import '../models/animal_model.dart';
import '../screens/adoption/adoption_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/role_selection_screen.dart';
import '../screens/auth/onboarding_screen.dart'; // YENİ EKLENDİ
import '../screens/donation/donation_screen.dart';
import '../screens/donation/my_donations_screen.dart';
import '../screens/home/animal_detail_screen.dart';
import '../screens/home/home_shell.dart';
import '../screens/shelter/adoption_requests_screen.dart';
import '../screens/shelter/add_animal_screen.dart';
import '../screens/shelter/dashboard_screen.dart';
import '../screens/shelter/edit_animal_screen.dart';
import '../screens/adoption/my_requests_screen.dart';

class AppRoutes {
  static final Map<String, WidgetBuilder> routes = {
    '/': (_) => const RoleSelectionScreen(),
    '/login': (_) => const LoginScreen(),
    '/register': (_) => const RegisterScreen(),
    '/onboarding': (_) => const OnboardingScreen(), // YENİ EKLENDİ
    '/home': (_) => const HomeShell(),
    '/edit-animal':
        (context) => EditAnimalScreen(
          animal: ModalRoute.of(context)!.settings.arguments as AnimalModel,
        ),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/animal-detail':
        final animal = settings.arguments as AnimalModel;
        return MaterialPageRoute(
          builder: (_) => AnimalDetailScreen(animal: animal),
        );

      case '/my-requests':
        return MaterialPageRoute(builder: (_) => const MyRequestsScreen());

      case '/my-donations':
        return MaterialPageRoute(builder: (_) => const MyDonationsScreen());

      case '/donation':
        final animal = settings.arguments as AnimalModel?;
        return MaterialPageRoute(
          builder: (_) => DonationScreen(animal: animal),
        );

      case '/adoption':
        return MaterialPageRoute(builder: (_) => const AdoptionScreen());

      case '/add-animal':
        return MaterialPageRoute(builder: (_) => const AddAnimalScreen());

      case '/requests':
        return MaterialPageRoute(
          builder: (_) => const AdoptionRequestsScreen(),
        );

      case '/dashboard':
        return MaterialPageRoute(builder: (_) => const DashboardScreen());

      default:
        return null;
    }
  }
}
