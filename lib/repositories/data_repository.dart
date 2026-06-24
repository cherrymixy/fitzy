import '../models/coin_state.dart';
import '../models/day_record.dart';
import '../models/user_profile.dart';

/// 데이터 계층 추상 인터페이스 — 경로 A(로컬)↔B(Firebase) 교체점.
///
/// 화면/프로바이더는 이 인터페이스에만 의존한다. 구현 교체 시
/// (StorageService → FirestoreRepository) 호출부는 불변.
/// 이미지는 '경로(String)'만 다루며, 파일 복사/삭제는 ImageStoreService 담당.
abstract class DataRepository {
  // --- Profile (단일 사용자) ---
  Future<UserProfile?> loadProfile();
  Future<void> saveProfile(UserProfile profile);

  /// 아이디 중복 여부.
  /// [A] 로컬 대조(전역 유니크 아님), [B] Firestore 전역 유니크.
  Future<bool> isUserIdTaken(String userId);

  /// 로그인 상태(없으면 null — 레거시 프로필은 자동 로그인 처리).
  Future<bool?> loadLoggedIn();
  Future<void> saveLoggedIn(bool value);

  // --- Coin ---
  /// 없으면 기본값 const CoinState() 반환(미지급 상태).
  Future<CoinState> loadCoinState();
  Future<void> saveCoinState(CoinState state);

  // --- DayRecord ---
  Future<DayRecord?> loadDayRecord(String dateKey);
  Future<List<DayRecord>> loadAllDayRecords();
  Future<void> saveDayRecord(DayRecord record);
  Future<void> deleteDayRecord(String dateKey);
}
