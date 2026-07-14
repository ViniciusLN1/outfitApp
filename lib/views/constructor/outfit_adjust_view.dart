import 'dart:io';
import 'dart:math' as math;
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

  /// Posição X acumulada sem snap durante o gesto, para o dedo conseguir
  /// "escapar" do imã do centro continuando o arraste.
  double _rawX = 0.5;
  bool _gestureMoved = false;
  bool _snapGuide = false;

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
      _lastScale = 1.0;
      _lastPointers = 0;
      _rawX = _transforms[c]!.centerX;
      _gestureMoved = false;
      _snapGuide = false;
    });
  }

  void _onUpdate(
    ClothingCategory c,
    ScaleUpdateDetails d,
    double cw,
    double ch,
  ) {
    var t = _transforms[c]!;
    // Traz para frente apenas quando o gesto vira movimento real, para um
    // simples toque de seleção não reordenar as camadas permanentemente.
    if (!_gestureMoved &&
        (d.focalPointDelta != Offset.zero || d.pointerCount >= 2)) {
      _gestureMoved = true;
      _zTop += 1;
      t = t.copyWith(z: _zTop);
    }
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
    // Snap suave ao centro horizontal; a posição crua acumulada permite sair
    // do imã continuando o arraste.
    _rawX = (_rawX + d.focalPointDelta.dx / cw).clamp(0.0, 1.0);
    const snap = 0.02;
    final snapped = (_rawX - 0.5).abs() < snap;
    setState(() {
      _snapGuide = snapped;
      _transforms[c] = t.copyWith(
        size: size,
        centerX: snapped ? 0.5 : _rawX,
        centerY: (t.centerY + d.focalPointDelta.dy / ch).clamp(0.0, 1.0),
      );
    });
  }

  void _onEnd() {
    if (_snapGuide) setState(() => _snapGuide = false);
  }

  void _resizeByHandle(ClothingCategory c, Offset delta, double cw) {
    final t = _transforms[c]!;
    // A alça fica no canto visível da imagem; o novo tamanho é derivado da
    // posição do canto após o delta (por eixo, vence o maior), de modo que a
    // alça acompanha o dedo 1:1 em qualquer direção de arraste.
    final ar = _aspect[c] ?? 1.0;
    final (iw, ih) = _imageRect(c, t.size * cw);
    final halfW = iw / 2 + delta.dx;
    final halfH = ih / 2 + delta.dy;
    final sideFromW = ar >= 1 ? halfW * 2 : halfW * 2 / ar;
    final sideFromH = ar >= 1 ? halfH * 2 * ar : halfH * 2;
    final newSide = math.max(sideFromW, sideFromH);
    setState(() {
      _transforms[c] = t.copyWith(size: (newSide / cw).clamp(0.08, 1.4));
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
                        borderRadius: BorderRadius.circular(12),
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
                  child: ElevatedButton(
                    onPressed: _confirm,
                    child: const Text('Concluir ajuste'),
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
        if (_snapGuide)
          Positioned(
            left: cw / 2 - 0.5,
            top: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Container(width: 1, color: scheme.primary),
            ),
          ),
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

    // A área de gesto cobre apenas o retângulo visível da imagem (BoxFit
    // .contain), não o quadrado invisível — as faixas transparentes do
    // quadrado deixam de bloquear o toque nas peças de baixo.
    // Key por categoria: o z-bump reordena os filhos do Stack no meio do
    // gesto; sem key o element é reciclado para outra peça e o arraste passa
    // a mover a peça errada.
    return Positioned(
      key: ValueKey(c),
      left: left,
      top: top,
      width: side,
      height: side,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Positioned.fill dá constraints justas ao quadrado: o contain
          // centraliza a imagem, igual ao preview salvo e ao export PNG.
          Positioned.fill(
            child: IgnorePointer(
              child: ExtendedImage.file(
                File(_items[c]!.imagePath),
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            left: imgLeft,
            top: imgTop,
            width: iw,
            height: ih,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onScaleStart: (_) => _onStart(c),
              onScaleUpdate: (d) => _onUpdate(c, d, cw, ch),
              onScaleEnd: (_) => _onEnd(),
              child: selected
                  ? Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: scheme.primary, width: 1.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
