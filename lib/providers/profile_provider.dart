import 'dart:convert';

import 'package:crypto/crypto.dart';
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

  /// 로그인 상태(게이트는 이 값으로 메인/인증 플로우를 분기).
  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  Future<void> load() async {
    _profile = await _repo.loadProfile();
    // 플래그 없으면(레거시) 프로필 존재 = 로그인 상태로 자동 처리.
    _loggedIn = (await _repo.loadLoggedIn()) ?? (_profile != null);
    _loaded = true;
    notifyListeners();
  }

  Future<void> _setLoggedIn(bool value) async {
    _loggedIn = value;
    await _repo.saveLoggedIn(value);
    notifyListeners();
  }

  /// 로그아웃 — 프로필은 유지(다시 로그인 가능), 게이트만 인증 플로우로.
  Future<void> logout() => _setLoggedIn(false);

  /// 가입된 아이디(찾기 화면 표시용). 없으면 null.
  String? get registeredUserId => _profile?.userId;

  /// 패스워드 재설정(경로 A 로컬) — 해시는 단방향이라 복구 불가, 새로 지정.
  /// 성공이면 null, 실패면 사유 문자열.
  Future<String?> resetPassword(String newPassword) async {
    final p = _profile ?? await _repo.loadProfile();
    if (p == null) return '가입된 계정이 없어요.';
    final e = validatePassword(newPassword);
    if (e != null) return e;
    p.password = hashPassword(newPassword);
    await _repo.saveProfile(p);
    _profile = p;
    notifyListeners();
    return null;
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
    if (v.length > 12) return '닉네임은 12자 이하로 입력해 주세요.';
    return null;
  }

  static String? validateUserId(String value) {
    if (!_userIdPattern.hasMatch(value)) {
      return '아이디는 영소문자·숫자·_ 4~20자입니다.';
    }
    return null;
  }

  static String? validatePassword(String value) {
    if (value.length < 6) return '패스워드는 6자 이상이어야 해요.';
    return null;
  }

  /// 패스워드 해시(로컬 저장용). 평문 대신 sha256 해시를 저장/대조한다.
  static String hashPassword(String pw) =>
      sha256.convert(utf8.encode('fitzy.salt:$pw')).toString();

  /// 가입: 형식검증 → 아이디 중복검사 → 저장.
  /// 성공이면 null, 실패면 사유 문자열(회색박스 UI가 표시).
  Future<String?> createProfile({
    required String userId,
    required String password,
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

    final pwError = validatePassword(password);
    if (pwError != null) return pwError;

    if (gender.trim().isEmpty) return '성별을 선택해 주세요.';

    if (await _repo.isUserIdTaken(userId)) {
      return '이미 사용 중인 아이디입니다.';
    }

    await saveProfile(UserProfile(
      userId: userId,
      password: hashPassword(password),
      nickname: nickname.trim(),
      gender: gender,
      genderPrivate: genderPrivate,
      tags: tags,
      profileImagePath: profileImagePath,
    ));
    await _setLoggedIn(true);
    return null;
  }

  /// 아이디 중복 여부(중복 검사 버튼용).
  Future<bool> isUserIdTaken(String userId) => _repo.isUserIdTaken(userId);

  /// 로그인: 저장된 프로필과 아이디·패스워드 대조(경로 A 로컬).
  /// 성공이면 null + 프로필 적용, 실패면 사유 문자열.
  Future<String?> login(String userId, String password) async {
    final p = await _repo.loadProfile();
    if (p == null || p.userId != userId) return '가입된 계정이 없어요.';
    if (p.password != hashPassword(password)) {
      return '아이디 또는 패스워드가 맞지 않아요.';
    }
    _profile = p;
    await _setLoggedIn(true);
    return null;
  }
}
