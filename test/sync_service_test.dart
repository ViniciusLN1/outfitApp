import 'dart:ffi';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:outfit_app/database/app_database.dart';
import 'package:outfit_app/services/sync_service.dart';
import 'package:outfit_app/services/user_scope.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:sqlite3/open.dart';

Future<void> _linuxSqliteOverride() async {
  open.overrideFor(
    OperatingSystem.linux,
    () => DynamicLibrary.open('libsqlite3.so.0'),
  );
}

class _FakePathProvider extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  final String docsPath;
  _FakePathProvider(this.docsPath);

  @override
  Future<String?> getApplicationDocumentsPath() async => docsPath;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  if (Platform.isLinux) {
    open.overrideFor(
      OperatingSystem.linux,
      () => DynamicLibrary.open('libsqlite3.so.0'),
    );
    databaseIsolateSetup = _linuxSqliteOverride;
  }

  late Directory docs;
  final service = SyncService();

  setUp(() async {
    docs = await Directory.systemTemp.createTemp('outfit_docs');
    PathProviderPlatform.instance = _FakePathProvider(docs.path);
  });

  tearDown(() => docs.delete(recursive: true));

  Future<AppDatabase> seedDb(UserScope scope, String imagePath) async {
    final db = AppDatabase.open(scope.dbFileName);
    await db.clothingDao.upsertItem(ClothingItemsCompanion(
      id: const Value('item-1'),
      name: const Value('Camisa teste'),
      imagePath: Value(imagePath),
      category: const Value('camisa'),
      dateAdded: const Value(0),
    ));
    return db;
  }

  test('round-trip buildBundle -> restoreBundle reescreve image_path',
      () async {
    const source = UserScope(7);
    final sourceClothing =
        await Directory(p.join(docs.path, source.clothingDirName))
            .create(recursive: true);
    final png = File(p.join(sourceClothing.path, 'peca.png'));
    await png.writeAsBytes([1, 2, 3]);
    final avatar =
        File(p.join(docs.path, source.profileDirName, 'avatar.jpg'));
    await avatar.parent.create(recursive: true);
    await avatar.writeAsBytes([9, 9]);

    final db = await seedDb(source, png.path);
    final zip = await service.buildBundle(db, source);
    await db.close();
    final zipBytes = await zip.readAsBytes();
    await zip.parent.delete(recursive: true);

    const dest = UserScope(9);
    final avatarPath = await service.restoreBundle(zipBytes, dest);

    expect(File(p.join(docs.path, dest.dbFileName)).existsSync(), isTrue);
    final restoredPng =
        File(p.join(docs.path, dest.clothingDirName, 'peca.png'));
    expect(restoredPng.existsSync(), isTrue);
    expect(await restoredPng.readAsBytes(), [1, 2, 3]);
    expect(avatarPath,
        p.join(docs.path, dest.profileDirName, 'avatar.jpg'));

    final destDb = AppDatabase.open(dest.dbFileName);
    final items = await destDb.select(destDb.clothingItems).get();
    await destDb.close();
    expect(items, hasLength(1));
    expect(items.single.imagePath, restoredPng.path);
  });

  test('adoptGuestData copia dados do convidado sem alterá-los', () async {
    const guest = UserScope(null);
    final guestClothing =
        await Directory(p.join(docs.path, guest.clothingDirName))
            .create(recursive: true);
    final png = File(p.join(guestClothing.path, 'peca.png'));
    await png.writeAsBytes([5, 5]);

    final guestDb = await seedDb(guest, png.path);
    await guestDb.close();

    expect(await service.hasGuestData(), isTrue);

    const user = UserScope(3);
    await service.adoptGuestData(user);

    final userPng = File(p.join(docs.path, user.clothingDirName, 'peca.png'));
    expect(userPng.existsSync(), isTrue);

    final userDb = AppDatabase.open(user.dbFileName);
    final items = await userDb.select(userDb.clothingItems).get();
    await userDb.close();
    expect(items.single.imagePath, userPng.path);

    // Convidado intacto.
    expect(png.existsSync(), isTrue);
    final guestDb2 = AppDatabase.open(guest.dbFileName);
    final guestItems = await guestDb2.select(guestDb2.clothingItems).get();
    await guestDb2.close();
    expect(guestItems.single.imagePath, png.path);
  });

  test('hasGuestData é falso sem banco nem imagens de convidado', () async {
    expect(await service.hasGuestData(), isFalse);
  });
}
