import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';

import '../../controllers/clothing_controller.dart';
import '../../controllers/constructor_controller.dart';
import '../../controllers/nav_controller.dart';
import '../../controllers/outfit_controller.dart';
import '../../database/app_database.dart';
import '../../widgets/async_section.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/empty_state.dart';
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
    if (canvas.occupied.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Adicione pelo menos uma peça antes de salvar o outfit.'),
        ),
      );
      return;
    }
    final isEditing = canvas.editingOutfitId != null;
    final nameController =
        TextEditingController(text: canvas.editingOutfitName ?? '');
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? 'Atualizar Outfit' : 'Salvar Outfit'),
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
          // Em edição, oferece explicitamente "Salvar como novo" para o usuário
          // que quer derivar um look novo sem sobrescrever o original.
          if (isEditing)
            TextButton(
              onPressed: () => _persist(ctx, nameController.text, asNew: true),
              child: const Text('Salvar como novo'),
            ),
          ElevatedButton(
            onPressed: () => _persist(ctx, nameController.text, asNew: false),
            child: Text(isEditing ? 'Atualizar' : 'Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _persist(
    BuildContext ctx,
    String rawName, {
    required bool asNew,
  }) async {
    final name = rawName.trim();
    if (name.isEmpty) return;
    Navigator.pop(ctx);

    // Lê o estado vivo no momento de salvar (e não o snapshot capturado no
    // build), garantindo que os ajustes feitos na tela "Ajustar" sejam
    // persistidos no lugar exato em que ficaram.
    final live = ref.read(constructorControllerProvider);
    final existingId = asNew ? null : live.editingOutfitId;

    final placements = <OutfitItemPlacement>[
      for (final entry in live.items.entries)
        if (entry.value != null)
          (
            itemId: entry.value!.id,
            transform: live.transforms[entry.key]!,
          ),
    ];

    try {
      await ref.read(outfitControllerProvider.notifier).saveOutfit(
            name: name,
            placements: placements,
            existingId: existingId,
          );
    } catch (e) {
      // Mantém o canvas intacto para o usuário tentar de novo.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar o outfit: $e')),
        );
      }
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(existingId == null
              ? 'Outfit salvo!'
              : 'Outfit atualizado!'),
        ),
      );
      await _askExportToGallery(live);
    }

    ref.read(constructorControllerProvider.notifier).clearAll();
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
            onPressed: () async {
              if (canvas.occupied.isEmpty) return;
              final ok = await confirmDialog(
                context,
                title: 'Limpar canvas',
                message: 'Remover todas as peças do look em montagem?',
                confirmLabel: 'Limpar',
                destructive: true,
              );
              if (ok) {
                ref.read(constructorControllerProvider.notifier).clearAll();
              }
            },
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
                ElevatedButton(
                  onPressed: () => _showSaveDialog(canvas),
                  child: const Text('Salvar Outfit'),
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
    // Larguras proporcionais ao espaço disponível (responsivo).
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth.clamp(0.0, 420.0);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: SizedBox(
                width: w * 0.44,
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
                width: w * 0.58,
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
                width: w * 0.55,
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
                width: w * 0.44,
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
      },
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
            width: item != null ? 1.4 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: item != null
              ? Theme.of(context).colorScheme.surfaceContainerHighest
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(7),
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

  // Rótulo do placeholder em inglês (só no canvas do construtor).
  static const _labels = {
    ClothingCategory.chapeu: 'Hat',
    ClothingCategory.camisa: 'Shirt',
    ClothingCategory.blusa: 'Jacket',
    ClothingCategory.cinto: 'Belt',
    ClothingCategory.calca: 'Pants',
    ClothingCategory.sapato: 'Shoes',
    ClothingCategory.acessorios: 'Accessories',
  };

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Adicionar ${category.displayName}',
      child: ExcludeSemantics(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              (_labels[category] ?? category.name).toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

class _FilledSlot extends StatelessWidget {
  final ClothingItem item;
  const _FilledSlot({required this.item});

  @override
  Widget build(BuildContext context) {
    // Padrão único para todos os slots: apenas a peça, centralizada.
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: ExtendedImage.file(
          File(item.imagePath),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _CategorySheet extends ConsumerWidget {
  final ClothingCategory category;
  const _CategorySheet({required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(clothingByCategoryProvider(category.name));

    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: scheme.outlineVariant,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Text(
              category.displayName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: AsyncSection(
              value: itemsAsync,
              builder: (items) {
                if (items.isEmpty) {
                  return EmptyState(
                    icon: Icons.checkroom_outlined,
                    title: 'Nada em ${category.displayName}',
                    message:
                        'Capture uma peça desta categoria para usá-la aqui.',
                    actionLabel: 'Capturar peça',
                    onAction: () {
                      Navigator.pop(context);
                      ref.read(currentTabIndexProvider.notifier).setTab(2);
                    },
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
                  itemBuilder: (_, i) => Material(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        ref
                            .read(constructorControllerProvider.notifier)
                            .selectItem(category, items[i]);
                        Navigator.pop(context);
                      },
                      child: Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: ExtendedImage.file(
                                File(items[i].imagePath),
                                fit: BoxFit.contain,
                                width: double.infinity,
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            color: scheme.surface,
                            padding: const EdgeInsets.all(4),
                            child: Text(
                              items[i].name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
