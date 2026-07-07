import 'dart:io';
import 'dart:ui' as ui;

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

  /// Proporção (largura / altura) intrínseca de cada imagem, usada para que a
  /// moldura de seleção e a alça acompanhem a peça e não o quadrado invisível.
  final Map<ClothingCategory, double> _aspect = {};

  ClothingCategory? _selected;
  int _zTop = 0;

  /// Estado incremental do gesto de pinça (escala). Guardar a escala anterior e
  /// a contagem de dedos evita o "colapso" do tamanho quando a pinça termina e
  /// um dos dedos sai antes do outro (a escala volta a 1.0 com um dedo só).
  double _lastScale = 1.0;
  int _lastPointers = 0;

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
    _loadAspects();
  }

  Future<void> _loadAspects() async {
    final loaded = <ClothingCategory, double>{};
    for (final entry in _items.entries) {
      try {
        final bytes = await File(entry.value.imagePath).readAsBytes();
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        final img = frame.image;
        loaded[entry.key] = img.width / img.height;
        img.dispose();
      } catch (_) {
        // Mantém proporção quadrada (1.0) caso a imagem não possa ser lida.
      }
    }
    if (!mounted) return;
    setState(() => _aspect.addAll(loaded));
  }

  void _onStart(ClothingCategory c) {
    setState(() {
      _selected = c;
      _zTop += 1;
      _transforms[c] = _transforms[c]!.copyWith(z: _zTop);
      _lastScale = 1.0;
      _lastPointers = 0;
    });
  }

  void _onUpdate(
    ClothingCategory c,
    ScaleUpdateDetails d,
    double cw,
    double ch,
  ) {
    final t = _transforms[c]!;
    var size = t.size;
    // Só redimensiona com 2+ dedos. Aplica a escala de forma incremental
    // (fator entre quadros) e ignora o quadro em que a contagem de dedos muda,
    // evitando o salto/colapso ao iniciar ou encerrar a pinça.
    if (d.pointerCount >= 2 && _lastPointers >= 2) {
      final factor = d.scale / _lastScale;
      size = (t.size * factor).clamp(0.08, 1.4);
    }
    _lastScale = d.scale;
    _lastPointers = d.pointerCount;
    setState(() {
      _transforms[c] = t.copyWith(
        size: size,
        centerX: (t.centerX + d.focalPointDelta.dx / cw).clamp(0.0, 1.0),
        centerY: (t.centerY + d.focalPointDelta.dy / ch).clamp(0.0, 1.0),
      );
    });
  }

  void _resizeByHandle(ClothingCategory c, Offset delta, double cw) {
    final t = _transforms[c]!;
    // A peça cresce simetricamente em torno do centro, então a alça precisa do
    // dobro do deslocamento para acompanhar o dedo. Usar dx + dy permite
    // redimensionar arrastando na diagonal independente da proporção da peça.
    final deltaSize = (delta.dx + delta.dy) / cw;
    setState(() {
      _transforms[c] = t.copyWith(size: (t.size + deltaSize).clamp(0.08, 1.4));
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

  /// Grava o arranjo no controller. Idempotente: pode ser chamado tanto pelos
  /// botões de concluir quanto ao sair pelo gesto/botão "voltar".
  void _commit() {
    ref.read(constructorControllerProvider.notifier).setTransforms(_transforms);
  }

  void _confirm() {
    _commit();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _commit();
      },
      child: Scaffold(
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
      ),
    );
  }

  Widget _buildStack(double cw, double ch) {
    final ordered = _items.keys.toList()
      ..sort((a, b) => _transforms[a]!.z.compareTo(_transforms[b]!.z));
    final scheme = Theme.of(context).colorScheme;

    final sel = _selected;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _selected = null),
          ),
        ),
        for (final c in ordered) _buildPiece(c, cw, ch, scheme),
        // A alça vive acima de todas as peças (não aninhada no GestureDetector
        // de escala da peça), evitando que o gesto de escala do pai sobrescreva
        // o redimensionamento e faça a peça voltar ao tamanho anterior.
        if (sel != null && _items.containsKey(sel))
          _buildHandle(sel, cw, ch, scheme),
      ],
    );
  }

  Widget _buildHandle(
    ClothingCategory c,
    double cw,
    double ch,
    ColorScheme scheme,
  ) {
    final t = _transforms[c]!;
    final side = t.size * cw;
    final boxLeft = t.centerX * cw - side / 2;
    final boxTop = t.centerY * ch - side / 2;
    final (iw, ih) = _imageRect(c, side);
    final cornerX = boxLeft + (side - iw) / 2 + iw;
    final cornerY = boxTop + (side - ih) / 2 + ih;
    const handle = 26.0;

    return Positioned(
      left: cornerX - handle / 2,
      top: cornerY - handle / 2,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (d) => _resizeByHandle(c, d.delta, cw),
        child: Container(
          width: handle,
          height: handle,
          decoration: BoxDecoration(
            color: scheme.primary,
            shape: BoxShape.circle,
            border: Border.all(color: scheme.onPrimary, width: 1.5),
          ),
          child: Icon(Icons.open_in_full, size: 14, color: scheme.onPrimary),
        ),
      ),
    );
  }

  /// Largura/altura reais da imagem (BoxFit.contain) dentro do quadrado [side].
  (double, double) _imageRect(ClothingCategory c, double side) {
    final ar = _aspect[c] ?? 1.0;
    if (ar >= 1) return (side, side / ar);
    return (side * ar, side);
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

    // Retângulo real ocupado pela imagem (BoxFit.contain) dentro do quadrado.
    // A moldura segue este retângulo, não o quadrado invisível.
    final (iw, ih) = _imageRect(c, side);
    final imgLeft = (side - iw) / 2;
    final imgTop = (side - ih) / 2;

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
            ExtendedImage.file(
              File(_items[c]!.imagePath),
              fit: BoxFit.contain,
            ),
            if (selected)
              Positioned(
                left: imgLeft,
                top: imgTop,
                width: iw,
                height: ih,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: scheme.primary, width: 1.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
