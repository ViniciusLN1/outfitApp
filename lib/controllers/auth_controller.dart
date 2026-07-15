import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/auth_api_service.dart';
import '../services/sync_service.dart';
import '../services/user_scope.dart';
import 'preferences.dart';

export '../services/auth_api_service.dart' show AuthSession, AuthApiException;

part 'auth_controller.g.dart';

/// Resultado do login/registro, para a UI decidir o próximo passo.
enum LoginOutcome {
  /// Backup do servidor restaurado; dados já no lugar.
  restored,

  /// Conta sem backup e sem dados de convidado para importar.
  empty,

  /// Conta sem backup, mas há dados de convidado: a UI pergunta se importa
  /// e então chama [AuthController.completeLogin].
  needsGuestChoice,

  /// Logado, mas o download do backup falhou (rede); dados locais em uso.
  offline,
}

@Riverpod(keepAlive: true)
AuthApiService authApiService(AuthApiServiceRef ref) => AuthApiService();

@Riverpod(keepAlive: true)
SyncService syncService(SyncServiceRef ref) => SyncService();

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  static const _keyUserId = 'auth_user_id';
  static const _keyUsername = 'auth_username';
  static const _keyToken = 'auth_token';

  /// Sessão autenticada aguardando a escolha sobre os dados de convidado;
  /// só é publicada em [completeLogin] (nenhuma conexão aberta no banco da
  /// conta até lá, o que permite copiar arquivos com segurança).
  AuthSession? _pending;

  @override
  AsyncValue<AuthSession?> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final userId = prefs.getInt(_keyUserId);
    final username = prefs.getString(_keyUsername);
    final token = prefs.getString(_keyToken);
    if (userId == null || username == null || token == null) {
      return const AsyncData(null);
    }
    return AsyncData(
      AuthSession(userId: userId, username: username, token: token),
    );
  }

  Future<LoginOutcome> login(String username, String password) =>
      _authenticate(() =>
          ref.read(authApiServiceProvider).login(username, password));

  Future<LoginOutcome> register(String username, String password) =>
      _authenticate(() =>
          ref.read(authApiServiceProvider).register(username, password));

  Future<LoginOutcome> _authenticate(
    Future<AuthSession> Function() request,
  ) async {
    state = const AsyncLoading();
    final AuthSession session;
    try {
      session = await request();
    } catch (_) {
      state = const AsyncData(null);
      rethrow;
    }

    final sync = ref.read(syncServiceProvider);
    final scope = UserScope(session.userId);
    try {
      final zip =
          await ref.read(authApiServiceProvider).downloadBackup(session.token);
      if (zip != null) {
        final avatarPath = await sync.restoreBundle(zip, scope);
        await _publish(session, avatarPath: avatarPath);
        return LoginOutcome.restored;
      }
    } catch (_) {
      // Sem rede para o download: login vale com os dados locais da conta.
      await _publish(session);
      return LoginOutcome.offline;
    }

    if (await sync.hasGuestData()) {
      _pending = session;
      return LoginOutcome.needsGuestChoice;
    }
    await _publish(session);
    return LoginOutcome.empty;
  }

  /// Finaliza um login pendente de [LoginOutcome.needsGuestChoice].
  Future<void> completeLogin({required bool importGuestData}) async {
    final session = _pending;
    _pending = null;
    if (session == null) return;
    String? avatarPath;
    if (importGuestData) {
      try {
        avatarPath = await ref
            .read(syncServiceProvider)
            .adoptGuestData(UserScope(session.userId));
      } catch (_) {
        // Cópia falhou: conta começa vazia, convidado permanece intacto.
      }
    }
    await _publish(session, avatarPath: avatarPath);
  }

  Future<void> _publish(AuthSession session, {String? avatarPath}) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt(_keyUserId, session.userId);
    await prefs.setString(_keyUsername, session.username);
    await prefs.setString(_keyToken, session.token);
    if (avatarPath != null) {
      await prefs.setString('photoPath_${session.userId}', avatarPath);
    }
    state = AsyncData(session);
  }

  Future<void> logout() async {
    final session = state.valueOrNull;
    if (session == null) return;
    try {
      await ref.read(authApiServiceProvider).logout(session.token);
    } catch (_) {
      // Best-effort: revogação falhou (offline), a sessão local sai mesmo assim.
    }
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyToken);
    state = const AsyncData(null);
  }
}
