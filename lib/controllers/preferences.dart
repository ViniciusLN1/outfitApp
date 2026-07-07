import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'preferences.g.dart';

/// Instância de [SharedPreferences] carregada no bootstrap (`main`) e injetada
/// via override. Mantida síncrona para que tema e perfil sejam lidos de imediato,
/// sem flash na primeira renderização.
@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(SharedPreferencesRef ref) =>
    throw UnimplementedError('sharedPreferencesProvider deve ser sobrescrito');
