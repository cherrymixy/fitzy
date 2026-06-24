/// 사용자 프로필 (경로 A 로컬).
///
/// 아이디(@) 필드는 없음 — 로컬 전용 경로 A에서는 전역 유니크를 보장할 수
/// 없으므로 제거했다. 식별/표시는 닉네임으로 한다.
class UserProfile {
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
    required this.nickname,
    required this.gender,
    this.genderPrivate = false,
    this.tags = const <String>[],
    this.profileImagePath,
  });
}
