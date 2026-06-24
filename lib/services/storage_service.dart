import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/coin_state.dart';
import '../models/day_record.dart';
import '../models/user_profile.dart';
import '../repositories/data_repository.dart';

/// 경로 A 구현: shared_preferences에 JSON 문자열로 영속화.
///
/// 이미지는 '경로(String)'만 저장한다(바이트 X). 모델을 순수하게 두기 위해
/// (역)직렬화는 영속화 세부사항으로 여기에 둔다.
/// 경로 B로 전환 시 이 클래스 대신 FirestoreRepository가 같은 인터페이스를 구현.
class StorageService implements DataRepository {
  StorageService(this._prefs);

  final SharedPreferences _prefs;

  static const String _kProfile = 'fitzy.profile';
  static const String _kCoin = 'fitzy.coin';
  static const String _kRecords = 'fitzy.records'; // { dateKey: recordMap }

  // --- Profile ---
  @override
  Future<UserProfile?> loadProfile() async {
    final raw = _prefs.getString(_kProfile);
    if (raw == null) return null;
    return _profileFromMap(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    await _prefs.setString(_kProfile, jsonEncode(_profileToMap(profile)));
  }

  // --- Coin ---
  @override
  Future<CoinState> loadCoinState() async {
    final raw = _prefs.getString(_kCoin);
    if (raw == null) return const CoinState();
    return _coinFromMap(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> saveCoinState(CoinState state) async {
    await _prefs.setString(_kCoin, jsonEncode(_coinToMap(state)));
  }

  // --- DayRecord ---
  Map<String, dynamic> _readRecords() {
    final raw = _prefs.getString(_kRecords);
    if (raw == null) return <String, dynamic>{};
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> _writeRecords(Map<String, dynamic> all) async {
    await _prefs.setString(_kRecords, jsonEncode(all));
  }

  @override
  Future<DayRecord?> loadDayRecord(String dateKey) async {
    final map = _readRecords()[dateKey];
    if (map == null) return null;
    return _recordFromMap(map as Map<String, dynamic>);
  }

  @override
  Future<List<DayRecord>> loadAllDayRecords() async {
    return _readRecords()
        .values
        .map((m) => _recordFromMap(m as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveDayRecord(DayRecord record) async {
    final all = _readRecords();
    all[record.dateKey] = _recordToMap(record);
    await _writeRecords(all);
  }

  @override
  Future<void> deleteDayRecord(String dateKey) async {
    final all = _readRecords();
    all.remove(dateKey);
    await _writeRecords(all);
  }

  // --- (역)직렬화 ---
  Map<String, dynamic> _profileToMap(UserProfile p) => <String, dynamic>{
        'nickname': p.nickname,
        'gender': p.gender,
        'genderPrivate': p.genderPrivate,
        'tags': p.tags,
        'profileImagePath': p.profileImagePath,
      };

  UserProfile _profileFromMap(Map<String, dynamic> m) => UserProfile(
        nickname: m['nickname'] as String,
        gender: m['gender'] as String,
        genderPrivate: m['genderPrivate'] as bool? ?? false,
        tags: (m['tags'] as List<dynamic>? ?? const <dynamic>[]).cast<String>(),
        profileImagePath: m['profileImagePath'] as String?,
      );

  Map<String, dynamic> _coinToMap(CoinState s) => <String, dynamic>{
        'lastGrantedDateKey': s.lastGrantedDateKey,
        'hasCoinToday': s.hasCoinToday,
        'drawnToday': s.drawnToday,
      };

  CoinState _coinFromMap(Map<String, dynamic> m) => CoinState(
        lastGrantedDateKey: m['lastGrantedDateKey'] as String?,
        hasCoinToday: m['hasCoinToday'] as bool? ?? false,
        drawnToday: m['drawnToday'] as bool? ?? false,
      );

  Map<String, dynamic> _recordToMap(DayRecord r) => <String, dynamic>{
        'dateKey': r.dateKey,
        'moodFitId': r.moodFitId,
        'moodTitle': r.moodTitle,
        'cells': r.cells,
        'isFavorite': r.isFavorite,
        'finalized': r.finalized,
        'createdAt': r.createdAt.toIso8601String(),
        'updatedAt': r.updatedAt.toIso8601String(),
      };

  DayRecord _recordFromMap(Map<String, dynamic> m) => DayRecord(
        dateKey: m['dateKey'] as String,
        moodFitId: m['moodFitId'] as String,
        moodTitle: m['moodTitle'] as String,
        cells: (m['cells'] as Map<String, dynamic>)
            .map((k, v) => MapEntry(k, v as String?)),
        isFavorite: m['isFavorite'] as bool? ?? false,
        finalized: m['finalized'] as bool? ?? false,
        createdAt: DateTime.parse(m['createdAt'] as String),
        updatedAt: DateTime.parse(m['updatedAt'] as String),
      );
}
