import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/constructor_controller.dart';
import '../../controllers/nav_controller.dart';
import '../../controllers/outfit_controller.dart';

class OutfitsView extends ConsumerStatefulWidget {
  const OutfitsView({super.key});

  @override
  ConsumerState<OutfitsView> createState() => _OutfitsViewState();
}

class _OutfitsViewState extends ConsumerState<OutfitsView> {
  OutfitSortMode _sortMode = OutfitSortMode.favoritesFirst;

  Future<void> _confirmDelete(String id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir outfit'),
        content: Text('Deseja excluir "$name"? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(outfitControllerProvider.notifier).deleteOutfit(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final outfitsAsync = ref.watch(outfitsSortedProvider(_sortMode));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Outfits'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: DropdownButton<OutfitSortMode>(
              value: _sortMode,
              underline: const SizedBox.shrink(),
              onChanged: (v) => setState(() => _sortMode = v!),
              items: const [
                DropdownMenuItem(
                  value: OutfitSortMode.favoritesFirst,
                  child: Text('Favoritos'),
                ),
                DropdownMenuItem(
                  value: OutfitSortMode.mostUsed,
                  child: Text('Mais Usados'),
                ),
              ],
            ),
          ),
        ],
      ),
      body: outfitsAsync.when(
        data: (outfits) {
          if (outfits.isEmpty) {
            return const Center(child: Text('Nenhum outfit salvo ainda.'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: outfits.length,
            itemBuilder: (context, index) {
              final outfit = outfits[index];
              final isFav = outfit.isFavorite == 1;
              return Card(
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          outfit.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(
                            isFav ? Icons.star : Icons.star_border,
                            color: isFav ? Colors.amber : null,
                          ),
                          onPressed: () => ref
                              .read(outfitControllerProvider.notifier)
                              .toggleFavorite(outfit.id, isFav),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () async {
                            await ref
                                .read(constructorControllerProvider.notifier)
                                .loadOutfit(outfit.id);
                            ref
                                .read(currentTabIndexProvider.notifier)
                                .setTab(3);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          onPressed: () => _confirmDelete(outfit.id, outfit.name),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
    );
  }
}
