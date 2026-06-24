/// 사용자 프로필 (경로 A 로컬).
class UserProfile {
  /// 내부 식별 아이디(불변). 경로 A에서는 전역 유니크를 보장하지 않고
  /// 형식검증 + 로컬 대조만 한다(전역 유니크는 경로 B에서). [[ID 유니크 추상화]]
  final String userId;

  /// 표시 닉네임(편집 가능).
  String nickname;

  /// 성별(필수). 무드 이미지 세트(girl/boy) 선택에도 사용한다.
  /// 비공개는 [genderPrivate]로 표시만 숨기고 값 자체는 유지한다.
  String gender;

  /// 프로필에서 성별을 숨길지 여부(값은 유지, 표시만 비공개).
  bool genderPrivate;

  /// 선택 태그(#무드 등). 갱신 시 새 리스트로 교체.
  List<String> tags;

  /// image_store가 documents로 복사한 경로만 저장(선택).
  String? profileImagePath;

  UserProfile({
    required this.userId,
    required this.nickname,
    required this.gender,
    this.genderPrivate = false,
    this.tags = const <String>[],
    this.profileImagePath,
  });
}
