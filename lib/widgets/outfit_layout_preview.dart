import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/clothing_controller.dart';
import '../database/app_database.dart';
import '../models/item_transform.dart';

/// Calcula o retângulo do canvas (proporção [kOutfitCanvasAspect]) que cabe
/// dentro de [box], mantendo o arranjo idêntico em qualquer tamanho.
Size fitOutfitCanvas(Size box) {
  final boxAspect = box.width / box.height;
  if (boxAspect > kOutfitCanvasAspect) {
    final ch = box.height;
    return Size(ch * kOutfitCanvasAspect, ch);
  }
  final cw = box.width;
  return Size(cw, cw / kOutfitCanvasAspect);
}

/// Compõe o look (mesmo arranjo do editor/preview) num PNG transparente,
/// desenhando cada peça com `BoxFit.contain` na sua posição/tamanho salvos.
/// Usado para exportar a imagem ajustada para a galeria.
Future<Uint8List?> renderOutfitPng(
  List<OutfitPlacement> placements, {
  double width = 1080,
}) async {
  if (placements.isEmpty) return null;
  final cw = width;
  final ch = width / kOutfitCanvasAspect;

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, cw, ch));
  final paint = Paint()..filterQuality = FilterQuality.high;

  final ordered = [...placements]
    ..sort((a, b) => a.transform.z.compareTo(b.transform.z));

  for (final p in ordered) {
    final bytes = await File(p.item.imagePath).readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final img = frame.image;

    final side = p.transform.size * cw;
    final left = p.transform.centerX * cw - side / 2;
    final top = p.transform.centerY * ch - side / 2;
    final dst = _containRect(
      Size(img.width.toDouble(), img.height.toDouble()),
      Rect.fromLTWH(left, top, side, side),
    );

    canvas.drawImageRect(
      img,
      Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
      dst,
      paint,
    );
    img.dispose();
  }

  final picture = recorder.endRecording();
  final image = await picture.toImage(cw.round(), ch.round());
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  picture.dispose();
  return byteData?.buffer.asUint8List();
}

/// Retângulo de destino para `BoxFit.contain` de [imageSize] dentro de [box].
Rect _containRect(Size imageSize, Rect box) {
  final scale = math.min(
    box.width / imageSize.width,
    box.height / imageSize.height,
  );
  final w = imageSize.width * scale;
  final h = imageSize.height * scale;
  return Rect.fromLTWH(
    box.left + (box.width - w) / 2,
    box.top + (box.height - h) / 2,
    w,
    h,
  );
}

/// Renderiza um look a partir das peças + posicionamento salvos (somente
/// leitura). Reutilizado no card e no detalhe da aba Outfits e na Home.
class OutfitLayoutPreview extends ConsumerWidget {
  final String outfitId;
  final EdgeInsets padding;

  const OutfitLayoutPreview({
    super.key,
    required this.outfitId,
    this.padding = const EdgeInsets.all(8),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(outfitPlacementsProvider(outfitId));
    return async.when(
      data: (placements) {
        if (placements.isEmpty) {
          return Center(
            child: Icon(Icons.style_outlined,
                size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
          );
        }
        return Padding(
          padding: padding,
          child: OutfitCanvas(placements: placements),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => const SizedBox.shrink(),
    );
  }
}

/// Stack posicionado que desenha as peças nas coordenadas normalizadas.
class OutfitCanvas extends StatelessWidget {
  final List<OutfitPlacement> placements;

  const OutfitCanvas({super.key, required this.placements});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final canvas = fitOutfitCanvas(constraints.biggest);
        final cw = canvas.width;
        final ch = canvas.height;
        return Center(
          child: SizedBox(
            width: cw,
            height: ch,
            child: Stack(
              children: [
                for (final p in placements)
                  Positioned(
                    left: p.transform.centerX * cw - (p.transform.size * cw) / 2,
                    top: p.transform.centerY * ch - (p.transform.size * cw) / 2,
                    width: p.transform.size * cw,
                    height: p.transform.size * cw,
                    child: ExtendedImage.file(
                      File(p.item.imagePath),
                      fit: BoxFit.contain,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
