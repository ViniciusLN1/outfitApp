import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'preferences.dart';

part 'profile_controller.g.dart';

class ProfileState {
  final String username;
  final String? photoPath;

  const ProfileState({this.username = 'Usuário', this.photoPath});

  ProfileState copyWith({String? username, String? photoPath}) {
    return ProfileState(
      username: username ?? this.username,
      photoPath: photoPath ?? this.photoPath,
    );
  }
}

@Riverpod(keepAlive: true)
class ProfileController extends _$ProfileController {
  static const _keyUsername = 'username';
  static const _keyPhoto = 'photoPath';

  @override
  ProfileState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return ProfileState(
      username: prefs.getString(_keyUsername) ?? 'Usuário',
      photoPath: prefs.getString(_keyPhoto),
    );
  }

  Future<void> setUsername(String name) async {
    state = state.copyWith(username: name);
    await ref.read(sharedPreferencesProvider).setString(_keyUsername, name);
  }

  Future<void> pickAndSavePhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    final dir = await getApplicationDocumentsDirectory();
    final profileDir = Directory('${dir.path}/profile');
    await profileDir.create(recursive: true);
    final file = File('${profileDir.path}/avatar.jpg');
    await file.writeAsBytes(bytes);

    state = state.copyWith(photoPath: file.path);
    await ref.read(sharedPreferencesProvider).setString(_keyPhoto, file.path);
  }
}
