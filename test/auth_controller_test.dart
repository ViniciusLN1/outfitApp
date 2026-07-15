import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:outfit_app/controllers/auth_controller.dart';
import 'package:outfit_app/controllers/preferences.dart';
import 'package:outfit_app/services/auth_api_service.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakePathProvider extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  final String docsPath;
  _FakePathProvider(this.docsPath);

  @override
  Future<String?> getApplicationDocumentsPath() async => docsPath;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory docs;
  late SharedPreferences prefs;

  setUp(() async {
    docs = await Directory.systemTemp.createTemp('outfit_docs');
    PathProviderPlatform.instance = _FakePathProvider(docs.path);
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  tearDown(() => docs.delete(recursive: true));

  ProviderContainer container(MockClient client) => ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          authApiServiceProvider.overrideWithValue(
            AuthApiService(client: client, baseUrl: 'http://test'),
          ),
        ],
      );

  MockClient apiOk() => MockClient((request) async {
        if (request.url.path == '/auth/login' ||
            request.url.path == '/auth/register') {
          return http.Response(
            jsonEncode({'token': 'tok123', 'user_id': 5, 'username': 'vini'}),
            request.url.path.endsWith('register') ? 201 : 200,
          );
        }
        if (request.url.path == '/backup') {
          return http.Response('not found', 404);
        }
        return http.Response('ok', 200);
      });

  test('login sem backup nem convidado publica sessão e grava prefs',
      () async {
    final c = container(apiOk());
    addTearDown(c.dispose);
    final outcome =
        await c.read(authControllerProvider.notifier).login('vini', 'secret1');

    expect(outcome, LoginOutcome.empty);
    final session = c.read(authControllerProvider).value;
    expect(session?.userId, 5);
    expect(session?.username, 'vini');
    expect(prefs.getInt('auth_user_id'), 5);
    expect(prefs.getString('auth_token'), 'tok123');
  });

  test('credenciais inválidas lançam AuthApiException e mantêm deslogado',
      () async {
    final c = container(
      MockClient((_) async => http.Response('unauthorized', 401)),
    );
    addTearDown(c.dispose);

    await expectLater(
      c.read(authControllerProvider.notifier).login('vini', 'errada1'),
      throwsA(isA<AuthApiException>()),
    );
    expect(c.read(authControllerProvider).value, isNull);
    expect(prefs.getInt('auth_user_id'), isNull);
  });

  test('auto-login lê a sessão das prefs', () async {
    await prefs.setInt('auth_user_id', 8);
    await prefs.setString('auth_username', 'ana');
    await prefs.setString('auth_token', 'tok999');

    final c = container(apiOk());
    addTearDown(c.dispose);
    final session = c.read(authControllerProvider).value;
    expect(session?.userId, 8);
    expect(session?.username, 'ana');
  });

  test('logout limpa prefs e volta ao convidado', () async {
    final c = container(apiOk());
    addTearDown(c.dispose);
    await c.read(authControllerProvider.notifier).login('vini', 'secret1');

    await c.read(authControllerProvider.notifier).logout();
    expect(c.read(authControllerProvider).value, isNull);
    expect(prefs.getInt('auth_user_id'), isNull);
    expect(prefs.getString('auth_token'), isNull);
  });
}
