import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart' show Value;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../database/app_database.dart';
import 'user_scope.dart';

/// Monta/restaura o bundle de backup (zip com o banco, as peças e o avatar)
/// e copia dados do convidado para uma conta. Só mexe em arquivos — sessão e
/// prefs ficam com os controllers.
class SyncService {
  static const _dbEntry = 'outfit.db';
  static const _clothingPrefix = 'clothing/';
  static const _avatarEntry = 'profile/avatar.jpg';

  Future<Directory> _docsDir() => getApplicationDocumentsDirectory();

  Future<bool> hasGuestData() async {
    final docs = await _docsDir();
    const guest = UserScope(null);
    if (await File(p.join(docs.path, guest.dbFileName)).exists()) return true;
    final dir = Directory(p.join(docs.path, guest.clothingDirName));
    return await dir.exists() && !await dir.list().isEmpty;
  }

  /// Zipa um snapshot consistente do banco (VACUUM INTO) + PNGs + avatar.
  Future<File> buildBundle(AppDatabase db, UserScope scope) async {
    final docs = await _docsDir();
    final tmp = await Directory.systemTemp.createTemp('outfit_sync');
    try {
      final snapshot = p.join(tmp.path, 'snapshot.db');
      await db.customStatement(
        "VACUUM INTO '${snapshot.replaceAll("'", "''")}'",
      );

      final archive = Archive();
      final dbBytes = await File(snapshot).readAsBytes();
      archive.addFile(ArchiveFile(_dbEntry, dbBytes.length, dbBytes));

      final clothingDir = Directory(p.join(docs.path, scope.clothingDirName));
      if (await clothingDir.exists()) {
        await for (final entry in clothingDir.list()) {
          if (entry is! File) continue;
          final bytes = await entry.readAsBytes();
          archive.addFile(ArchiveFile(
            '$_clothingPrefix${p.basename(entry.path)}',
            bytes.length,
            bytes,
          ));
        }
      }

      final avatar =
          File(p.join(docs.path, scope.profileDirName, 'avatar.jpg'));
      if (await avatar.exists()) {
        final bytes = await avatar.readAsBytes();
        archive.addFile(ArchiveFile(_avatarEntry, bytes.length, bytes));
      }

      final meta = utf8.encode(jsonEncode({'version': 1}));
      archive.addFile(ArchiveFile('meta.json', meta.length, meta));

      final out = File(p.join(tmp.path, 'backup.zip'));
      await out.writeAsBytes(ZipEncoder().encode(archive)!, flush: true);
      return out;
    } catch (_) {
      await tmp.delete(recursive: true);
      rethrow;
    }
  }

  /// Substitui os dados locais do [scope] pelo conteúdo do zip e reescreve os
  /// `image_path` para o diretório novo. Retorna o path do avatar restaurado
  /// (ou null). Deve rodar ANTES de a sessão ser publicada, para que nenhuma
  /// conexão esteja aberta nesse banco.
  Future<String?> restoreBundle(Uint8List zipBytes, UserScope scope) async {
    final archive = ZipDecoder().decodeBytes(zipBytes);
    final dbFile = archive.findFile(_dbEntry);
    if (dbFile == null) {
      throw const FormatException('Backup inválido: banco ausente.');
    }

    final docs = await _docsDir();
    final clothingDir = Directory(p.join(docs.path, scope.clothingDirName));
    if (await clothingDir.exists()) {
      await clothingDir.delete(recursive: true);
    }
    await clothingDir.create(recursive: true);

    await File(p.join(docs.path, scope.dbFileName))
        .writeAsBytes(dbFile.content as List<int>, flush: true);

    String? avatarPath;
    for (final entry in archive.files) {
      if (!entry.isFile) continue;
      if (entry.name.startsWith(_clothingPrefix)) {
        final name = p.basename(entry.name);
        await File(p.join(clothingDir.path, name))
            .writeAsBytes(entry.content as List<int>, flush: true);
      } else if (entry.name == _avatarEntry) {
        final avatar =
            File(p.join(docs.path, scope.profileDirName, 'avatar.jpg'));
        await avatar.parent.create(recursive: true);
        await avatar.writeAsBytes(entry.content as List<int>, flush: true);
        avatarPath = avatar.path;
      }
    }

    await _rewriteImagePaths(scope, clothingDir.path);
    return avatarPath;
  }

  /// Copia banco, peças e avatar do convidado para os paths da conta
  /// (o convidado permanece intacto). Retorna o path do avatar copiado.
  Future<String?> adoptGuestData(UserScope user) async {
    final docs = await _docsDir();
    const guest = UserScope(null);

    final guestDb = File(p.join(docs.path, guest.dbFileName));
    if (await guestDb.exists()) {
      await guestDb.copy(p.join(docs.path, user.dbFileName));
    }

    final userClothing = Directory(p.join(docs.path, user.clothingDirName));
    if (await userClothing.exists()) {
      await userClothing.delete(recursive: true);
    }
    await userClothing.create(recursive: true);
    final guestClothing = Directory(p.join(docs.path, guest.clothingDirName));
    if (await guestClothing.exists()) {
      await for (final entry in guestClothing.list()) {
        if (entry is! File) continue;
        await entry.copy(p.join(userClothing.path, p.basename(entry.path)));
      }
    }

    String? avatarPath;
    final guestAvatar =
        File(p.join(docs.path, guest.profileDirName, 'avatar.jpg'));
    if (await guestAvatar.exists()) {
      final dest = File(p.join(docs.path, user.profileDirName, 'avatar.jpg'));
      await dest.parent.create(recursive: true);
      await guestAvatar.copy(dest.path);
      avatarPath = dest.path;
    }

    if (await guestDb.exists()) {
      await _rewriteImagePaths(user, userClothing.path);
    }
    return avatarPath;
  }

  /// Os `image_path` do banco são absolutos e apontam para o diretório de
  /// origem (outro aparelho ou o do convidado); reescreve cada um para
  /// `<clothingDir>/<basename>`.
  Future<void> _rewriteImagePaths(UserScope scope, String clothingDir) async {
    final db = AppDatabase.open(scope.dbFileName);
    try {
      final rows = await db.select(db.clothingItems).get();
      for (final row in rows) {
        final rewritten = p.join(clothingDir, p.basename(row.imagePath));
        if (rewritten == row.imagePath) continue;
        await (db.update(db.clothingItems)
              ..where((t) => t.id.equals(row.id)))
            .write(ClothingItemsCompanion(imagePath: Value(rewritten)));
      }
    } finally {
      await db.close();
    }
  }
}
