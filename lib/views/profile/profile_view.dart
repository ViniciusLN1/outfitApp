import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/outfit_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/theme_controller.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalItems = ref.watch(totalClothingItemsProvider);
    final totalOutfits = ref.watch(totalOutfitsProvider);
    final themeMode = ref.watch(themeModeProvider);
    final profile = ref.watch(profileProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          children: [
            _AvatarSection(profile: profile),
            const SizedBox(height: 16),
            _UsernameSection(username: profile.username),
            const SizedBox(height: 36),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatCard(label: 'Peças', valueAsync: totalItems),
                _StatCard(label: 'Outfits', valueAsync: totalOutfits),
              ],
            ),
            const SizedBox(height: 40),
            _ThemeToggle(isDark: isDark),
          ],
        ),
      ),
    );
  }
}

// ─── Avatar ───────────────────────────────────────────────────────────────────

class _AvatarSection extends ConsumerWidget {
  final ProfileState profile;
  const _AvatarSection({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasPhoto =
        profile.photoPath != null && File(profile.photoPath!).existsSync();

    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 56,
            backgroundColor: colorScheme.primaryContainer,
            backgroundImage:
                hasPhoto ? FileImage(File(profile.photoPath!)) : null,
            child: hasPhoto
                ? null
                : Icon(Icons.person, size: 56, color: colorScheme.primary),
          ),
          GestureDetector(
            onTap: () => ref.read(profileProvider.notifier).pickAndSavePhoto(),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
              child: Icon(Icons.camera_alt,
                  size: 16, color: colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Username ─────────────────────────────────────────────────────────────────

class _UsernameSection extends ConsumerWidget {
  final String username;
  const _UsernameSection({required this.username});

  void _editUsername(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController(text: username);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Alterar nome'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            labelText: 'Seu nome',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = ctrl.text.trim();
              if (name.isNotEmpty) {
                ref.read(profileProvider.notifier).setUsername(name);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          username,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.edit_outlined, size: 20),
          onPressed: () => _editUsername(context, ref),
          tooltip: 'Alterar nome',
        ),
      ],
    );
  }
}

// ─── Stats ────────────────────────────────────────────────────────────────────

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
                    fontSize: 36, fontWeight: FontWeight.bold),
              ),
              loading: () => const SizedBox(
                height: 36,
                width: 36,
                child: CircularProgressIndicator(),
              ),
              error: (e, st) =>
                  const Text('--', style: TextStyle(fontSize: 36)),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// ─── Theme toggle ─────────────────────────────────────────────────────────────

class _ThemeToggle extends ConsumerWidget {
  final bool isDark;
  const _ThemeToggle({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.light_mode),
            const SizedBox(width: 8),
            Switch(
              value: isDark,
              onChanged: (v) => ref
                  .read(themeModeProvider.notifier)
                  .setMode(v ? ThemeMode.dark : ThemeMode.light),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.dark_mode),
          ],
        ),
        Text(
          isDark ? 'Tema Escuro' : 'Tema Claro',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
