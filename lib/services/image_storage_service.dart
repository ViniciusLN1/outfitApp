import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ImageStorageService {
  // Evita uma chamada de platform channel + mkdir por salvamento.
  static Future<Directory>? _clothingDir;

  static Future<Directory> _ensureDir() => _clothingDir ??= () async {
        final dir = await getApplicationDocumentsDirectory();
        return Directory(p.join(dir.path, 'clothing')).create(recursive: true);
      }();

  Future<String> savePng(Uint8List bytes, {String? filename}) async {
    final clothingDir = await _ensureDir();
    final name = filename ?? '${const Uuid().v4()}.png';
    final file = File(p.join(clothingDir.path, name));
    final trimmed = await trimTransparentBorder(bytes);
    await file.writeAsBytes(trimmed, flush: true);
    return file.path;
  }

  static const _trimFlagKey = 'images_trimmed_v1';

  /// Migração one-shot: peças salvas antes do corte de margens transparentes
  /// mantêm as bordas assimétricas do rembg, deixando a peça fora do centro do
  /// próprio retângulo. Reprocessa cada PNG existente uma única vez.
  static Future<void> trimExistingImages(SharedPreferences prefs) async {
    if (prefs.getBool(_trimFlagKey) ?? false) return;
    try {
      final dir = await _ensureDir();
      await for (final entry in dir.list()) {
        if (entry is! File || !entry.path.endsWith('.png')) continue;
        try {
          final bytes = await entry.readAsBytes();
          final trimmed = await trimTransparentBorder(bytes);
          if (!identical(trimmed, bytes)) {
            await entry.writeAsBytes(trimmed, flush: true);
          }
        } catch (_) {
          // Uma imagem ilegível não interrompe as demais.
        }
      }
      await prefs.setBool(_trimFlagKey, true);
    } catch (_) {
      // Sem flag gravada: tenta de novo no próximo startup.
    }
  }

  Future<void> deleteImage(String path) async {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }

  /// Corta as margens totalmente transparentes da imagem. Sem isso, o rembg
  /// preserva as dimensões da foto original e uma peça fora do centro da foto
  /// fica visualmente deslocada dentro do seu retângulo nos looks salvos.
  /// Imagens sem transparência (fundo mantido) retornam inalteradas.
  static Future<Uint8List> trimTransparentBorder(Uint8List bytes) async {
    ui.Image? img;
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      img = frame.image;
      final data = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (data == null) return bytes;

      final w = img.width;
      final h = img.height;
      final px = data.buffer.asUint8List();
      var minX = w, minY = h, maxX = -1, maxY = -1;
      for (var y = 0; y < h; y++) {
        final row = y * w * 4;
        for (var x = 0; x < w; x++) {
          if (px[row + x * 4 + 3] > 8) {
            if (x < minX) minX = x;
            if (x > maxX) maxX = x;
            if (y < minY) minY = y;
            if (y > maxY) maxY = y;
          }
        }
      }
      // Vazia ou já justa: mantém os bytes originais.
      if (maxX < 0 ||
          (minX == 0 && minY == 0 && maxX == w - 1 && maxY == h - 1)) {
        return bytes;
      }

      final cw = maxX - minX + 1;
      final ch = maxY - minY + 1;
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      canvas.drawImageRect(
        img,
        ui.Rect.fromLTWH(
          minX.toDouble(),
          minY.toDouble(),
          cw.toDouble(),
          ch.toDouble(),
        ),
        ui.Rect.fromLTWH(0, 0, cw.toDouble(), ch.toDouble()),
        ui.Paint(),
      );
      final picture = recorder.endRecording();
      final cropped = await picture.toImage(cw, ch);
      picture.dispose();
      final out = await cropped.toByteData(format: ui.ImageByteFormat.png);
      cropped.dispose();
      return out?.buffer.asUint8List() ?? bytes;
    } catch (_) {
      return bytes;
    } finally {
      img?.dispose();
    }
  }
}
