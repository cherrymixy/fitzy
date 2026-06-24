import 'package:flutter/foundation.dart';

import '../data/board_categories.dart';
import '../data/mood_fits.dart';
import '../models/day_record.dart';
import '../repositories/data_repository.dart';
import '../services/date_keys.dart';
import '../services/image_store_service.dart';

/// 보드(DayRecord) 상태. 변경 시 즉시 저장.
///
/// DataRepository(레코드 영속화)에 더해, 칸 이미지의 복사/교체/삭제를 위해
/// ImageStoreService에도 의존한다 — 파일 생애주기가 보드의 본질 기능이라
/// 불가피(구체 저장소가 아닌 서비스 의존).
///
/// 마감(finalized) 트리거는 STEP 6에서. 여기서는 마감된 보드의 '이미지
/// 추가/수정만' 막는 가드만 둔다(제목·즐겨찾기는 마감 후에도 허용).
class BoardProvider extends ChangeNotifier {
  BoardProvider(this._repo, this._imageStore);

  final DataRepository _repo;
  final ImageStoreService _imageStore;

  final Map<String, DayRecord> _records = <String, DayRecord>{};

  List<DayRecord> get all => _records.values.toList();
  DayRecord? recordOn(String dateKey) => _records[dateKey];

  Future<void> load() async {
    final list = await _repo.loadAllDayRecords();
    _records
      ..clear()
      ..addEntries(list.map((r) => MapEntry(r.dateKey, r)));
    notifyListeners();
  }

  /// 레코드 생성/교체 후 즉시 저장.
  Future<void> upsert(DayRecord record) async {
    _records[record.dateKey] = record;
    await _repo.saveDayRecord(record);
    notifyListeners();
  }

  /// 뽑기 직후 오늘 무드 보드 생성. 이미 오늘 보드가 있으면 무시(덮어쓰기 X).
  /// 제목 기본값=무드명, cells는 9칸 빈칸으로 초기화.
  Future<void> createTodayRecord(String moodFitId, DateTime now) async {
    final dateKey = dateKeyOf(now);
    if (_records.containsKey(dateKey)) return;
    final mood = kMoodFits.firstWhere((m) => m.id == moodFitId);
    final cells = <String, String?>{
      for (final category in kBoardCategories) category.id: null,
    };
    await upsert(DayRecord(
      dateKey: dateKey,
      moodFitId: moodFitId,
      moodTitle: mood.nameKo,
      cells: cells,
      createdAt: now,
      updatedAt: now,
    ));
  }

  /// 레코드와 그에 속한 이미지 파일까지 삭제.
  Future<void> remove(String dateKey) async {
    final record = _records.remove(dateKey);
    if (record != null) {
      for (final path in record.cells.values) {
        if (path != null) await _imageStore.delete(path);
      }
    }
    await _repo.deleteDayRecord(dateKey);
    notifyListeners();
  }

  /// 칸 이미지 설정/교체(마감 전만). 새 파일 복사→옛 파일 삭제→즉시 저장.
  Future<void> setCellImage(
    String dateKey,
    String categoryId,
    String pickedPath,
  ) async {
    final record = _records[dateKey];
    if (record == null || record.finalized) return;
    final newPath = await _imageStore.replace(
      oldStoredPath: record.cells[categoryId],
      newPickedPath: pickedPath,
      dateKey: dateKey,
      categoryId: categoryId,
    );
    record.cells[categoryId] = newPath;
    record.updatedAt = DateTime.now();
    await _repo.saveDayRecord(record);
    notifyListeners();
  }

  /// 칸 비우기(마감 전만). 파일 삭제→즉시 저장.
  Future<void> clearCellImage(String dateKey, String categoryId) async {
    final record = _records[dateKey];
    if (record == null || record.finalized) return;
    final old = record.cells[categoryId];
    if (old != null) await _imageStore.delete(old);
    record.cells[categoryId] = null;
    record.updatedAt = DateTime.now();
    await _repo.saveDayRecord(record);
    notifyListeners();
  }

  /// 즐겨찾기 토글(마감 후에도 허용).
  Future<void> toggleFavorite(String dateKey) async {
    final record = _records[dateKey];
    if (record == null) return;
    record.isFavorite = !record.isFavorite;
    record.updatedAt = DateTime.now();
    await _repo.saveDayRecord(record);
    notifyListeners();
  }

  /// 제목(무드명) 편집(마감 후에도 허용).
  Future<void> editTitle(String dateKey, String title) async {
    final record = _records[dateKey];
    if (record == null) return;
    record.moodTitle = title;
    record.updatedAt = DateTime.now();
    await _repo.saveDayRecord(record);
    notifyListeners();
  }
}
