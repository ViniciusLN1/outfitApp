import 'dart:async';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class BackgroundRemovalService {
  // 10.0.2.2 = host machine via emulador Android.
  // Para dispositivo físico, usar o IP LAN da máquina host.
  static const String _baseUrl = 'http://192.168.100.232:8000';
  static const Duration _timeout = Duration(seconds: 45);

  // Client compartilhado: mantém keep-alive e evita abrir socket por request.
  static final http.Client _client = http.Client();

  Future<Uint8List> removeBackground(
    Uint8List imageBytes, {
    String filename = 'photo.jpg',
  }) async {
    final uri = Uri.parse('$_baseUrl/remove-background');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(
        http.MultipartFile.fromBytes('file', imageBytes, filename: filename),
      );
    final streamed = await _client.send(request).timeout(_timeout);
    if (streamed.statusCode != 200) {
      // Drena o corpo para liberar a conexão de volta ao pool.
      unawaited(streamed.stream.drain<void>().catchError((_) {}));
      throw Exception('Background removal failed: ${streamed.statusCode}');
    }
    return streamed.stream.toBytes().timeout(_timeout);
  }
}
