import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/outfit_controller.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalItems = ref.watch(totalClothingItemsProvider);
    final totalOutfitsCount = ref.watch(totalOutfitsProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 52,
                child: Icon(Icons.person, size: 52),
              ),
              const SizedBox(height: 16),
              const Text(
                'Usuário',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatCard(label: 'Peças', valueAsync: totalItems),
                  _StatCard(label: 'Outfits', valueAsync: totalOutfitsCount),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final AsyncValue<int> valueAsync;

  const _StatCard({required this.label, required this.valueAsync});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        child: Column(
          children: [
            valueAsync.when(
              data: (v) => Text(
                '$v',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              loading: () => const SizedBox(
                height: 36,
                width: 36,
                child: CircularProgressIndicator(),
              ),
              error: (err, st) => const Text('--', style: TextStyle(fontSize: 36)),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
