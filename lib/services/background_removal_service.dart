import 'dart:async';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';

class BackgroundRemovalService {
  static const Duration _timeout = AppConfig.backgroundRemovalTimeout;

  // Client compartilhado: mantém keep-alive e evita abrir socket por request.
  static final http.Client _client = http.Client();

  Future<Uint8List> removeBackground(
    Uint8List imageBytes, {
    String filename = 'photo.jpg',
  }) async {
    final uri =
        Uri.parse('${AppConfig.backgroundRemovalBaseUrl}/remove-background');
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
