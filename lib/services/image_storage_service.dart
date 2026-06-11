import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
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
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Future<void> deleteImage(String path) async {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}
