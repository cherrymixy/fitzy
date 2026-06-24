import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';
import '../repositories/data_repository.dart';

/// 프로필 상태. DataRepository에만 의존, 변경 시 즉시 저장.
class ProfileProvider extends ChangeNotifier {
  ProfileProvider(this._repo);

  final DataRepository _repo;

  UserProfile? _profile;
  UserProfile? get profile => _profile;
  bool get hasProfile => _profile != null;

  Future<void> load() async {
    _profile = await _repo.loadProfile();
    notifyListeners();
  }

  /// 프로필 생성/갱신 후 즉시 저장.
  Future<void> saveProfile(UserProfile profile) async {
    _profile = profile;
    await _repo.saveProfile(profile);
    notifyListeners();
  }
}
