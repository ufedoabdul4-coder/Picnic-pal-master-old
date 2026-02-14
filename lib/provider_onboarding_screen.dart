import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'service_provider_selection_screen.dart';

class ProviderOnboardingScreen extends StatelessWidget {
  const ProviderOnboardingScreen({super.key});

  Future<void> _skip(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_provider_prompt', true);
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.business_center_outlined, size: 80, color: theme.colorScheme.primary),
              const SizedBox(height: 30),
              Text(
                "Become a Service Provider?",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                "Join our network of event planners, hotel managers, and more. You can manage your services directly from this account.",
                style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const ServiceProviderSelectionScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Yes, I'm a Provider", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => _skip(context),
                child: Text("Skip for now", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}