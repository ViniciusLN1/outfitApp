import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier(super.initial);

  static const _keyUsername = 'username';
  static const _keyPhoto = 'photoPath';

  Future<void> setUsername(String name) async {
    state = state.copyWith(username: name);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUsername, name);
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPhoto, file.path);
  }
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(const ProfileState());
});
