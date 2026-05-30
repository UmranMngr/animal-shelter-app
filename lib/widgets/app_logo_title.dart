import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class AppLogoTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const AppLogoTitle({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 20,
        right: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE37C9E).withOpacity(0.2),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE37C9E).withOpacity(0.1),
            width: 1.5,
          ),
        ),
      ),
      child: SizedBox(
        height: 70,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFE37C9E),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.pets, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
