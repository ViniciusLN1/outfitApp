import 'dart:typed_data';

import 'package:http/http.dart' as http;

class BackgroundRemovalService {
  // 10.0.2.2 = host machine via emulador Android.
  // Para dispositivo físico, usar o IP LAN da máquina host.
  static const String _baseUrl = 'http://10.0.2.2:8000';

  Future<Uint8List> removeBackground(
    Uint8List imageBytes, {
    String filename = 'photo.jpg',
  }) async {
    final uri = Uri.parse('$_baseUrl/remove-background');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(
        http.MultipartFile.fromBytes('file', imageBytes, filename: filename),
      );
    final streamed = await request.send();
    if (streamed.statusCode != 200) {
      throw Exception('Background removal failed: ${streamed.statusCode}');
    }
    return streamed.stream.toBytes();
  }
}
