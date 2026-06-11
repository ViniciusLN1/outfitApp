import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/constructor_controller.dart';
import '../../database/app_database.dart';
import '../../models/item_transform.dart';
import '../../widgets/outfit_layout_preview.dart';

/// Editor livre: permite arrastar e redimensionar cada peça do look antes de
/// salvar. As alterações são gravadas no [ConstructorController] ao concluir.
class OutfitAdjustView extends ConsumerStatefulWidget {
  const OutfitAdjustView({super.key});

  @override
  ConsumerState<OutfitAdjustView> createState() => _OutfitAdjustViewState();
}

class _OutfitAdjustViewState extends ConsumerState<OutfitAdjustView> {
  late final Map<ClothingCategory, ClothingItem> _items;
  late final Map<ClothingCategory, ItemTransform> _transforms;

  ClothingCategory? _selected;
  int _zTop = 0;
  double _startSize = 0;

  @override
  void initState() {
    super.initState();
    final s = ref.read(constructorControllerProvider);
    _items = {
      for (final c in s.occupied) c: s.items[c]!,
    };
    _transforms = {
      for (final c in _items.keys) c: s.transforms[c]!,
    };
    _zTop = _transforms.values.fold(0, (m, t) => t.z > m ? t.z : m);
  }

  void _onStart(ClothingCategory c) {
    setState(() {
      _selected = c;
      _zTop += 1;
      _transforms[c] = _transforms[c]!.copyWith(z: _zTop);
      _startSize = _transforms[c]!.size;
    });
  }

  void _onUpdate(
    ClothingCategory c,
    ScaleUpdateDetails d,
    double cw,
    double ch,
  ) {
    final t = _transforms[c]!;
    setState(() {
      _transforms[c] = t.copyWith(
        size: (_startSize * d.scale).clamp(0.08, 1.4),
        centerX: (t.centerX + d.focalPointDelta.dx / cw).clamp(0.0, 1.0),
        centerY: (t.centerY + d.focalPointDelta.dy / ch).clamp(0.0, 1.0),
      );
    });
  }

  void _resizeByHandle(ClothingCategory c, double dx, double cw) {
    final t = _transforms[c]!;
    setState(() {
      _transforms[c] = t.copyWith(size: (t.size + dx / cw).clamp(0.08, 1.4));
    });
  }

  void _reset() {
    setState(() {
      for (final c in _items.keys) {
        _transforms[c] = defaultTransformFor(c.name);
      }
      _selected = null;
    });
  }

  void _confirm() {
    ref.read(constructorControllerProvider.notifier).setTransforms(_transforms);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustar Look'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt),
            tooltip: 'Restaurar padrão',
            onPressed: _items.isEmpty ? null : _reset,
          ),
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Concluir',
            onPressed: _items.isEmpty ? null : _confirm,
          ),
        ],
      ),
      body: _items.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Adicione peças no construtor para poder ajustá-las.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Text(
                    'Arraste para mover. Use dois dedos (pinça) ou a alça no '
                    'canto para redimensionar a peça selecionada.',
                    style: TextStyle(
                        fontSize: 12, color: scheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        border: Border.all(color: scheme.outlineVariant),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final canvas =
                              fitOutfitCanvas(constraints.biggest);
                          return Center(
                            child: SizedBox(
                              width: canvas.width,
                              height: canvas.height,
                              child: _buildStack(canvas.width, canvas.height),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: SizedBox(
                    width: 220,
                    child: ElevatedButton(
                      onPressed: _confirm,
                      child: const Text('Concluir ajuste'),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStack(double cw, double ch) {
    final ordered = _items.keys.toList()
      ..sort((a, b) => _transforms[a]!.z.compareTo(_transforms[b]!.z));
    final scheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _selected = null),
          ),
        ),
        for (final c in ordered) _buildPiece(c, cw, ch, scheme),
      ],
    );
  }

  Widget _buildPiece(
    ClothingCategory c,
    double cw,
    double ch,
    ColorScheme scheme,
  ) {
    final t = _transforms[c]!;
    final side = t.size * cw;
    final left = t.centerX * cw - side / 2;
    final top = t.centerY * ch - side / 2;
    final selected = _selected == c;

    return Positioned(
      left: left,
      top: top,
      width: side,
      height: side,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onScaleStart: (_) => _onStart(c),
        onScaleUpdate: (d) => _onUpdate(c, d, cw, ch),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: selected
                  ? BoxDecoration(
                      border: Border.all(color: scheme.primary, width: 1.5),
                      borderRadius: BorderRadius.circular(4),
                    )
                  : null,
              child: ExtendedImage.file(
                File(_items[c]!.imagePath),
                fit: BoxFit.contain,
              ),
            ),
            if (selected)
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanUpdate: (d) => _resizeByHandle(c, d.delta.dx, cw),
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: scheme.onPrimary, width: 1.5),
                    ),
                    child: Icon(Icons.open_in_full,
                        size: 14, color: scheme.onPrimary),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
