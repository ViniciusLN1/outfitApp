import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';

class AuthSession {
  final int userId;
  final String username;
  final String token;
  const AuthSession({
    required this.userId,
    required this.username,
    required this.token,
  });
}

/// Erro de negócio da API (credenciais inválidas, username em uso).
/// Falhas de rede/timeout sobem como exceções do http/socket.
class AuthApiException implements Exception {
  final int statusCode;
  const AuthApiException(this.statusCode);
}

class AuthApiService {
  AuthApiService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  final http.Client _client;
  final String _baseUrl;
  static const _timeout = AppConfig.apiTimeout;

  Map<String, String> _auth(String token) => {
        'Authorization': 'Bearer $token',
      };

  Future<AuthSession> _session(String path, String username, String password,
      {required int expected}) async {
    final res = await _client
        .post(
          Uri.parse('$_baseUrl$path'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'username': username, 'password': password}),
        )
        .timeout(_timeout);
    if (res.statusCode != expected) throw AuthApiException(res.statusCode);
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return AuthSession(
      userId: body['user_id'] as int,
      username: body['username'] as String,
      token: body['token'] as String,
    );
  }

  Future<AuthSession> register(String username, String password) =>
      _session('/auth/register', username, password, expected: 201);

  Future<AuthSession> login(String username, String password) =>
      _session('/auth/login', username, password, expected: 200);

  Future<void> logout(String token) async {
    await _client
        .post(Uri.parse('$_baseUrl/auth/logout'), headers: _auth(token))
        .timeout(_timeout);
  }

  Future<void> uploadBackup(File zip, String token) async {
    final request = http.MultipartRequest('PUT', Uri.parse('$_baseUrl/backup'))
      ..headers.addAll(_auth(token))
      ..files.add(await http.MultipartFile.fromPath('file', zip.path));
    final streamed = await _client.send(request).timeout(_timeout);
    unawaited(streamed.stream.drain<void>().catchError((_) {}));
    if (streamed.statusCode != 200) {
      throw AuthApiException(streamed.statusCode);
    }
  }

  /// Retorna os bytes do zip, ou null se o usuário ainda não tem backup (404).
  Future<Uint8List?> downloadBackup(String token) async {
    final res = await _client
        .get(Uri.parse('$_baseUrl/backup'), headers: _auth(token))
        .timeout(_timeout);
    if (res.statusCode == 404) return null;
    if (res.statusCode != 200) throw AuthApiException(res.statusCode);
    return res.bodyBytes;
  }
}
