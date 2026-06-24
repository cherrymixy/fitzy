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
}
