import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/user_scope.dart';
import 'auth_controller.dart';
import 'clothing_controller.dart';
import 'preferences.dart';

part 'sync_controller.g.dart';

enum SyncPhase { idle, syncing, error }

class SyncState {
  final SyncPhase phase;
  final DateTime? lastSyncAt;
  const SyncState({this.phase = SyncPhase.idle, this.lastSyncAt});

  SyncState copyWith({SyncPhase? phase, DateTime? lastSyncAt}) => SyncState(
        phase: phase ?? this.phase,
        lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      );
}

/// Sobe o bundle da conta logada: com debounce a cada mudança no banco
/// (qualquer tabela) e sob demanda via [syncNow]. Falha só marca
/// [SyncPhase.error] — nunca bloqueia nem crasha o uso do app.
@Riverpod(keepAlive: true)
class SyncController extends _$SyncController {
  static const _debounceDelay = Duration(seconds: 20);
  Timer? _debounce;

  @override
  SyncState build() {
    _debounce?.cancel();
    ref.onDispose(() => _debounce?.cancel());

    final session = ref.watch(authControllerProvider).valueOrNull;
    if (session == null) return const SyncState();

    final db = ref.watch(appDatabaseProvider);
    final sub = db.tableUpdates().listen((_) {
      _debounce?.cancel();
      _debounce = Timer(_debounceDelay, syncNow);
    });
    ref.onDispose(sub.cancel);

    final millis = ref
        .read(sharedPreferencesProvider)
        .getInt('last_sync_at_${session.userId}');
    return SyncState(
      lastSyncAt:
          millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis),
    );
  }

  Future<void> syncNow() async {
    final session = ref.read(authControllerProvider).valueOrNull;
    if (session == null || state.phase == SyncPhase.syncing) return;
    _debounce?.cancel();
    state = state.copyWith(phase: SyncPhase.syncing);
    try {
      final zip = await ref.read(syncServiceProvider).buildBundle(
            ref.read(appDatabaseProvider),
            ref.read(currentUserScopeProvider),
          );
      try {
        await ref.read(authApiServiceProvider).uploadBackup(zip, session.token);
      } finally {
        await zip.parent.delete(recursive: true);
      }
      final now = DateTime.now();
      await ref.read(sharedPreferencesProvider).setInt(
            'last_sync_at_${session.userId}',
            now.millisecondsSinceEpoch,
          );
      state = SyncState(phase: SyncPhase.idle, lastSyncAt: now);
    } catch (_) {
      state = state.copyWith(phase: SyncPhase.error);
    }
  }
}
