import 'package:flutter_test/flutter_test.dart';
import 'package:outfit_app/services/user_scope.dart';

void main() {
  test('convidado mantém os paths originais do app', () {
    const scope = UserScope(null);
    expect(scope.isGuest, isTrue);
    expect(scope.dbFileName, 'outfit_app.db');
    expect(scope.clothingDirName, 'clothing');
    expect(scope.profileDirName, 'profile');
    expect(scope.prefsSuffix, '');
  });

  test('usuário logado tem paths segmentados pelo id', () {
    const scope = UserScope(42);
    expect(scope.isGuest, isFalse);
    expect(scope.dbFileName, 'outfit_42.db');
    expect(scope.clothingDirName, 'clothing_42');
    expect(scope.profileDirName, 'profile_42');
    expect(scope.prefsSuffix, '_42');
  });
}
