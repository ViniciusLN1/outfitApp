import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/clothing_controller.dart';
import '../../controllers/constructor_controller.dart';
import '../../controllers/outfit_controller.dart';
import '../../database/app_database.dart';

class ConstructorView extends ConsumerWidget {
  const ConstructorView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvas = ref.watch(constructorControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Construtor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: 'Limpar canvas',
            onPressed: () =>
                ref.read(constructorControllerProvider.notifier).clearAll(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: ClothingCategory.values
                  .map((cat) => _CategorySlot(
                        category: cat,
                        item: canvas[cat],
                      ))
                  .toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Salvar Outfit'),
                onPressed: () => _showSaveDialog(context, ref, canvas),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSaveDialog(
    BuildContext context,
    WidgetRef ref,
    CanvasState canvas,
  ) {
    final nameController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Salvar Outfit'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nome do outfit',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(ctx);
              final itemIds = canvas.values
                  .whereType<ClothingItem>()
                  .map((i) => i.id)
                  .toList();
              await ref
                  .read(outfitControllerProvider.notifier)
                  .saveOutfit(name: name, itemIds: itemIds);
              ref.read(constructorControllerProvider.notifier).clearAll();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Outfit salvo!')),
                );
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}

class _CategorySlot extends ConsumerWidget {
  final ClothingCategory category;
  final ClothingItem? item;

  const _CategorySlot({required this.category, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _openSheet(context, ref),
      child: Container(
        height: 110,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: item != null
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade400,
            width: item != null ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: item == null
            ? _EmptySlot(category: category)
            : _FilledSlot(item: item!),
      ),
    );
  }

  void _openSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _CategoryBottomSheet(category: category),
    );
  }
}

class _EmptySlot extends StatelessWidget {
  final ClothingCategory category;

  const _EmptySlot({required this.category});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_circle_outline, color: Colors.grey.shade400),
        const SizedBox(width: 8),
        Text(
          category.name[0].toUpperCase() + category.name.substring(1),
          style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
        ),
      ],
    );
  }
}

class _FilledSlot extends StatelessWidget {
  final ClothingItem item;

  const _FilledSlot({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
          child: ExtendedImage.file(
            File(item.imagePath),
            width: 90,
            height: 110,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            item.name,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

class _CategoryBottomSheet extends ConsumerWidget {
  final ClothingCategory category;

  const _CategoryBottomSheet({required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(clothingByCategoryProvider(category.name));

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              category.name[0].toUpperCase() + category.name.substring(1),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: itemsAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return const Center(
                    child: Text('Nenhuma peça nessa categoria.'),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: items.length,
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: () {
                      ref
                          .read(constructorControllerProvider.notifier)
                          .selectItem(category, items[i]);
                      Navigator.pop(context);
                    },
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          Expanded(
                            child: ExtendedImage.file(
                              File(items[i].imagePath),
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4),
                            child: Text(
                              items[i].name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
            ),
          ),
        ],
      ),
    );
  }
}
