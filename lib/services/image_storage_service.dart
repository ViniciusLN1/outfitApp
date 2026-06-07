import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ImageStorageService {
  Future<String> savePng(Uint8List bytes, {String? filename}) async {
    final dir = await getApplicationDocumentsDirectory();
    final clothingDir = Directory(p.join(dir.path, 'clothing'));
    await clothingDir.create(recursive: true);
    final name = filename ?? '${const Uuid().v4()}.png';
    final file = File(p.join(clothingDir.path, name));
    await file.writeAsBytes(bytes);
    return file.path;
  }

  Future<void> deleteImage(String path) async {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}
