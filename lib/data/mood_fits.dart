import '../models/mood_fit.dart';

/// 9 무드(Select J1~J9). 리스트 순서 = 그리드 순서.
///
/// imageAsset의 `{gender}`는 표시 시 UserProfile.gender(girl/boy)로 치환한다.
/// 경로는 placeholder이며 실제 에셋은 `assets/images/moods/{girl,boy}/{id}.png`.
const List<MoodFit> kMoodFits = <MoodFit>[
  MoodFit(id: 'lovely',  nameKo: '러블리', imageAsset: 'assets/images/moods/{gender}/lovely.png'),
  MoodFit(id: 'casual',  nameKo: '캐주얼', imageAsset: 'assets/images/moods/{gender}/casual.png'),
  MoodFit(id: 'sporty',  nameKo: '스포티', imageAsset: 'assets/images/moods/{gender}/sporty.png'),
  MoodFit(id: 'street',  nameKo: '스트릿', imageAsset: 'assets/images/moods/{gender}/street.png'),
  MoodFit(id: 'minimal', nameKo: '미니멀', imageAsset: 'assets/images/moods/{gender}/minimal.png'),
  MoodFit(id: 'vintage', nameKo: '빈티지', imageAsset: 'assets/images/moods/{gender}/vintage.png'),
  MoodFit(id: 'preppy',  nameKo: '프레피', imageAsset: 'assets/images/moods/{gender}/preppy.png'),
  MoodFit(id: 'chic',    nameKo: '시크',   imageAsset: 'assets/images/moods/{gender}/chic.png'),
  MoodFit(id: 'purity',  nameKo: '청순',   imageAsset: 'assets/images/moods/{gender}/purity.png'),
];
