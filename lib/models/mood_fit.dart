/// 무드(추구미) 정의 — Select의 9무드(J1~J9). 불변.
///
/// 무드 이미지는 성별 2종(girl/boy)이 있어 [imageAsset]에는 `{gender}` 토큰을
/// 담은 placeholder 경로를 보관하고, 표시 시 [imageAssetFor]로 치환한다.
class MoodFit {
  /// 무드 id(= 이미지 파일명, DayRecord.moodFitId). 예: 'lovely'.
  final String id;

  /// 한글 무드명. 예: '러블리'.
  final String nameKo;

  /// 성별 토큰을 포함한 이미지 경로 placeholder.
  /// 예: 'assets/images/moods/{gender}/lovely.png'
  final String imageAsset;

  const MoodFit({
    required this.id,
    required this.nameKo,
    required this.imageAsset,
  });

  /// `{gender}`를 'girl' 또는 'boy'로 치환한 실제 에셋 경로.
  String imageAssetFor(String gender) =>
      imageAsset.replaceAll('{gender}', gender);
}
