import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../controllers/auth_controller.dart';
import 'image_storage_service.dart';

part 'user_scope.g.dart';

/// Nomes de arquivos/diretórios/chaves de prefs segmentados por usuário.
/// `userId == null` é o modo convidado e mantém os paths originais do app.
class UserScope {
  final int? userId;
  const UserScope(this.userId);

  bool get isGuest => userId == null;
  String get dbFileName => isGuest ? 'outfit_app.db' : 'outfit_$userId.db';
  String get clothingDirName => isGuest ? 'clothing' : 'clothing_$userId';
  String get profileDirName => isGuest ? 'profile' : 'profile_$userId';
  String get prefsSuffix => isGuest ? '' : '_$userId';
}

@Riverpod(keepAlive: true)
UserScope currentUserScope(CurrentUserScopeRef ref) {
  final session = ref.watch(authControllerProvider).valueOrNull;
  return UserScope(session?.userId);
}

@Riverpod(keepAlive: true)
ImageStorageService imageStorageService(ImageStorageServiceRef ref) {
  final scope = ref.watch(currentUserScopeProvider);
  return ImageStorageService(scope.clothingDirName);
}
