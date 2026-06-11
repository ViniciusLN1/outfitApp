import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';

import '../../controllers/clothing_controller.dart';
import '../../controllers/constructor_controller.dart';
import '../../controllers/outfit_controller.dart';
import '../../database/app_database.dart';
import '../../widgets/outfit_layout_preview.dart';
import 'outfit_adjust_view.dart';

class ConstructorView extends ConsumerStatefulWidget {
  const ConstructorView({super.key});

  @override
  ConsumerState<ConstructorView> createState() => _ConstructorViewState();
}

class _ConstructorViewState extends ConsumerState<ConstructorView> {
  void _openAdjust(ConstructorState canvas) {
    if (canvas.occupied.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione peças antes de ajustar.')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const OutfitAdjustView()),
    );
  }

  Future<void> _showSaveDialog(ConstructorState canvas) async {
    final nameController = TextEditingController();
    await showDialog<void>(
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

              final placements = <OutfitItemPlacement>[
                for (final entry in canvas.items.entries)
                  if (entry.value != null)
                    (
                      itemId: entry.value!.id,
                      transform: canvas.transforms[entry.key]!,
                    ),
              ];

              await ref
                  .read(outfitControllerProvider.notifier)
                  .saveOutfit(name: name, placements: placements);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Outfit salvo!')),
                );
                await _askExportToGallery(canvas);
              }

              ref.read(constructorControllerProvider.notifier).clearAll();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _askExportToGallery(ConstructorState canvas) async {
    if (!mounted) return;
    final export = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Salvar na galeria?'),
        content:
            const Text('Deseja salvar a imagem deste look na sua galeria de fotos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Não'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sim'),
          ),
        ],
      ),
    );

    if (export != true || !mounted) return;

    try {
      final placements = <OutfitPlacement>[
        for (final entry in canvas.items.entries)
          if (entry.value != null)
            OutfitPlacement(
              item: entry.value!,
              transform: canvas.transforms[entry.key]!,
            ),
      ];

      final pngBytes = await renderOutfitPng(placements);
      if (pngBytes == null) return;

      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if (!hasAccess) await Gal.requestAccess(toAlbum: true);

      await Gal.putImageBytes(pngBytes, album: 'OutfitApp');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Look salvo na galeria!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar na galeria: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _openAdjust(canvas),
                  icon: const Icon(Icons.tune, size: 18),
                  label: const Text('Ajustar'),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 170,
                  child: ElevatedButton(
                    onPressed: () => _showSaveDialog(canvas),
                    child: const Text('Salvar Outfit'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCanvas(ConstructorState canvas) {
    // Eixo central vertical e simétrico: chapéu, camisa, cinto, calça, sapato.
    // Acessórios à esquerda da camisa; Blusa/Jaqueta à direita.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: SizedBox(
            width: 150,
            child: _Slot(
              category: ClothingCategory.chapeu,
              item: canvas.items[ClothingCategory.chapeu],
              height: 72,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: _Slot(
                category: ClothingCategory.acessorios,
                item: canvas.items[ClothingCategory.acessorios],
                height: 96,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 4,
              child: _Slot(
                category: ClothingCategory.camisa,
                item: canvas.items[ClothingCategory.camisa],
                height: 144,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: _Slot(
                category: ClothingCategory.blusa,
                item: canvas.items[ClothingCategory.blusa],
                height: 96,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Center(
          child: SizedBox(
            width: 200,
            child: _Slot(
              category: ClothingCategory.cinto,
              item: canvas.items[ClothingCategory.cinto],
              height: 54,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: SizedBox(
            width: 190,
            child: _Slot(
              category: ClothingCategory.calca,
              item: canvas.items[ClothingCategory.calca],
              height: 150,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: SizedBox(
            width: 150,
            child: _Slot(
              category: ClothingCategory.sapato,
              item: canvas.items[ClothingCategory.sapato],
              height: 78,
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
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
                : Theme.of(context).colorScheme.outlineVariant,
            width: item != null ? 1.6 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
          color: item != null
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.04)
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
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

  // Glifo semântico por categoria. Material Icons não tem peças de roupa
  // específicas, então usamos emoji (universal e consistente) para as peças e
  // reservamos um ícone Material apenas para o cinto, que não tem emoji.
  static const _emojiMap = {
    ClothingCategory.chapeu: '🧢',
    ClothingCategory.camisa: '👕',
    ClothingCategory.blusa: '🧥',
    ClothingCategory.calca: '👖',
    ClothingCategory.sapato: '👞',
    ClothingCategory.acessorios: '⌚',
  };
  static const _fallbackIcon = Icons.horizontal_rule; // cinto

  @override
  Widget build(BuildContext context) {
    final emoji = _emojiMap[category];
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Stack(
      alignment: Alignment.center,
      children: [
        emoji != null
            ? Opacity(
                opacity: 0.12,
                child: Text(emoji, style: const TextStyle(fontSize: 50)),
              )
            : Icon(_fallbackIcon, size: 56, color: muted.withValues(alpha: 0.12)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              emoji != null
                  ? Text(emoji, style: const TextStyle(fontSize: 24))
                  : Icon(_fallbackIcon, size: 26,
                      color: muted.withValues(alpha: 0.7)),
              const SizedBox(height: 4),
              Text(
                category.displayName,
                style: TextStyle(
                  color: muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Slots laterais estreitos: exibe apenas a peça, centralizada.
        if (constraints.maxWidth < 130) {
          return Padding(
            padding: const EdgeInsets.all(6),
            child: ExtendedImage.file(
              File(item.imagePath),
              fit: BoxFit.contain,
            ),
          );
        }
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
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
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
