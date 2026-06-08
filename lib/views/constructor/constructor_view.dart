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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: _buildCanvas(canvas),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Center(
              child: SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () => _showSaveDialog(context, ref, canvas),
                  child: const Text('Salvar Outfit'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCanvas(CanvasState canvas) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Linha 1: Chapéu/Boné - centralizado
        Center(
          child: SizedBox(
            width: 180,
            child: _Slot(
              category: ClothingCategory.chapeu,
              item: canvas[ClothingCategory.chapeu],
              height: 80,
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Linha 2: Camisa | Blusa/Jaqueta
        Row(
          children: [
            Expanded(
              child: _Slot(
                category: ClothingCategory.camisa,
                item: canvas[ClothingCategory.camisa],
                height: 120,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Slot(
                category: ClothingCategory.blusa,
                item: canvas[ClothingCategory.blusa],
                height: 120,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Linha 3: Cinto + Complemento à direita
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _Slot(
                category: ClothingCategory.cinto,
                item: canvas[ClothingCategory.cinto],
                height: 70,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Slot(
                category: ClothingCategory.complemento,
                item: canvas[ClothingCategory.complemento],
                height: 70,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Linha 4: Calça - centralizado
        Center(
          child: SizedBox(
            width: 220,
            child: _Slot(
              category: ClothingCategory.calca,
              item: canvas[ClothingCategory.calca],
              height: 130,
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Linha 5: Sapato - centralizado
        Center(
          child: SizedBox(
            width: 180,
            child: _Slot(
              category: ClothingCategory.sapato,
              item: canvas[ClothingCategory.sapato],
              height: 80,
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  void _showSaveDialog(BuildContext context, WidgetRef ref, CanvasState canvas) {
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

class _Slot extends ConsumerWidget {
  final ClothingCategory category;
  final ClothingItem? item;
  final double height;

  const _Slot({
    required this.category,
    required this.item,
    this.height = 100,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _openSheet(context, ref),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: height,
        decoration: BoxDecoration(
          border: Border.all(
            color: item != null
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade400,
            width: item != null ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: item != null
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.04)
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: item == null
              ? _EmptySlot(category: category)
              : _FilledSlot(item: item!),
        ),
      ),
    );
  }

  void _openSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _CategorySheet(category: category),
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
        Icon(Icons.add_circle_outline, color: Colors.grey.shade400, size: 20),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            category.displayName,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
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
        ExtendedImage.file(
          File(item.imagePath),
          width: 70,
          fit: BoxFit.cover,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            item.name,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _CategorySheet extends ConsumerWidget {
  final ClothingCategory category;
  const _CategorySheet({required this.category});

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
              category.displayName,
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
