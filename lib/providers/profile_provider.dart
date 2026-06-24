import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';
import '../repositories/data_repository.dart';

/// 프로필 상태. DataRepository에만 의존, 변경 시 즉시 저장.
class ProfileProvider extends ChangeNotifier {
  ProfileProvider(this._repo);

  final DataRepository _repo;

  /// 아이디 형식: 영소문자·숫자·밑줄 4~20자.
  static final RegExp _userIdPattern = RegExp(r'^[a-z0-9_]{4,20}$');

  UserProfile? _profile;
  UserProfile? get profile => _profile;
  bool get hasProfile => _profile != null;

  /// 최초 load() 완료 여부. 게이트가 로딩/분기를 판단하는 데 쓴다.
  bool _loaded = false;
  bool get loaded => _loaded;

  Future<void> load() async {
    _profile = await _repo.loadProfile();
    _loaded = true;
    notifyListeners();
  }

  /// 프로필 생성/갱신 후 즉시 저장.
  Future<void> saveProfile(UserProfile profile) async {
    _profile = profile;
    await _repo.saveProfile(profile);
    notifyListeners();
  }

  // --- 검증(순수 함수). 성공이면 null, 실패면 사유 문자열. ---
  static String? validateNickname(String value) {
    final v = value.trim();
    if (v.isEmpty) return '닉네임을 입력해 주세요.';
    if (v.length > 20) return '닉네임은 20자 이하로 입력해 주세요.';
    return null;
  }

  static String? validateUserId(String value) {
    if (!_userIdPattern.hasMatch(value)) {
      return '아이디는 영소문자·숫자·_ 4~20자입니다.';
    }
    return null;
  }

  /// 가입: 형식검증 → 아이디 중복검사 → 저장.
  /// 성공이면 null, 실패면 사유 문자열(회색박스 UI가 표시).
  Future<String?> createProfile({
    required String userId,
    required String nickname,
    required String gender,
    bool genderPrivate = false,
    List<String> tags = const <String>[],
    String? profileImagePath,
  }) async {
    final nickError = validateNickname(nickname);
    if (nickError != null) return nickError;

    final idError = validateUserId(userId);
    if (idError != null) return idError;

    if (gender.trim().isEmpty) return '성별을 선택해 주세요.';

    if (await _repo.isUserIdTaken(userId)) {
      return '이미 사용 중인 아이디입니다.';
    }

    await saveProfile(UserProfile(
      userId: userId,
      nickname: nickname.trim(),
      gender: gender,
      genderPrivate: genderPrivate,
      tags: tags,
      profileImagePath: profileImagePath,
    ));
    return null;
  }
}
