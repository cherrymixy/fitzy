// 프로필 저장 + 아이디 형식검증/중복검사(경로 A 로컬).
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitzy/providers/profile_provider.dart';
import 'package:fitzy/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('아이디 형식검증', () {
    test('유효한 아이디는 통과', () {
      expect(ProfileProvider.validateUserId('fitzy_01'), isNull);
    });
    test('무효한 아이디는 사유 반환', () {
      expect(ProfileProvider.validateUserId('ab'), isNotNull); // 너무 짧음
      expect(ProfileProvider.validateUserId('Fitzy'), isNotNull); // 대문자
      expect(ProfileProvider.validateUserId('has space'), isNotNull);
    });
  });

  test('닉네임 검증', () {
    expect(ProfileProvider.validateNickname('승아'), isNull);
    expect(ProfileProvider.validateNickname('   '), isNotNull);
  });

  test('createProfile: 저장 + 아이디 중복검사 + 왕복', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final repo = StorageService(prefs);
    final provider = ProfileProvider(repo);
    await provider.load();

    // 최초 가입 성공
    final error1 = await provider.createProfile(
      userId: 'fitzy_01',
      password: 'pw123456',
      nickname: '승아',
      gender: 'girl',
    );
    expect(error1, isNull);
    expect(provider.hasProfile, isTrue);
    expect(provider.profile!.userId, 'fitzy_01');

    // 로컬 중복검사
    expect(await repo.isUserIdTaken('fitzy_01'), isTrue);
    expect(await repo.isUserIdTaken('other_99'), isFalse);

    // 같은 아이디 재가입 → 중복 에러
    final error2 = await provider.createProfile(
      userId: 'fitzy_01',
      password: 'pw123456',
      nickname: '다른',
      gender: 'boy',
    );
    expect(error2, isNotNull);

    // 성별 미선택 → 에러
    final error3 = await provider.createProfile(
      userId: 'new_user',
      password: 'pw123456',
      nickname: '닉',
      gender: '',
    );
    expect(error3, isNotNull);

    // 저장→로드 왕복(userId 포함)
    final loaded = await StorageService(prefs).loadProfile();
    expect(loaded, isNotNull);
    expect(loaded!.userId, 'fitzy_01');
    expect(loaded.nickname, '승아');
    expect(loaded.gender, 'girl');
  });

  test('패스워드 해시 저장 + 로그인/로그아웃', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final repo = StorageService(prefs);
    final provider = ProfileProvider(repo);
    await provider.load();

    await provider.createProfile(
      userId: 'cherry',
      password: 'pw123456',
      nickname: '체리',
      gender: 'girl',
    );

    // 저장된 패스워드는 평문이 아니라 해시
    final stored = await repo.loadProfile();
    expect(stored!.password, isNot('pw123456'));
    expect(stored.password, ProfileProvider.hashPassword('pw123456'));

    // 로그아웃 → 로그인 round-trip
    await provider.logout();
    expect(provider.loggedIn, isFalse);
    expect(await provider.login('cherry', 'wrong-pw'), isNotNull);
    expect(provider.loggedIn, isFalse);
    expect(await provider.login('cherry', 'pw123456'), isNull);
    expect(provider.loggedIn, isTrue);
  });

  test('패스워드 재설정: 옛 비번 실패, 새 비번 로그인', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final provider = ProfileProvider(StorageService(prefs));
    await provider.load();
    await provider.createProfile(
      userId: 'cherry',
      password: 'old123456',
      nickname: '체리',
      gender: 'girl',
    );

    expect(provider.registeredUserId, 'cherry');
    expect(await provider.resetPassword('123'), isNotNull); // 너무 짧음
    expect(await provider.resetPassword('new567890'), isNull);

    await provider.logout();
    expect(await provider.login('cherry', 'old123456'), isNotNull);
    expect(await provider.login('cherry', 'new567890'), isNull);
    expect(provider.loggedIn, isTrue);
  });
}
