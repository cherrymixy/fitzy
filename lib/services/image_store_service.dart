import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// 사용자 이미지 파일 생애주기 관리.
///
/// 저장값은 **상대경로**(`board_images/xxx.ext`)다. iOS는 앱 업데이트/복원 시
/// Documents 컨테이너 UUID가 바뀌어 절대경로가 무효화되므로, 절대경로를
/// 영속 저장하면 과거 이미지가 깨진다. 표시 시 [resolve]로 현재 세션의
/// documents 절대경로로 재구성한다.
class ImageStoreService {
  static const String _subdir = 'board_images';

  String? _docsPath;

  /// 앱 시작 시 1회 호출(main). documents 절대경로를 캐시해 [resolve]를
  /// 동기적으로 쓸 수 있게 한다.
  Future<void> init() async {
    _docsPath ??= (await getApplicationDocumentsDirectory()).path;
  }

  Future<String> _ensureDocsPath() async {
    return _docsPath ??= (await getApplicationDocumentsDirectory()).path;
  }

  /// 저장된 경로(상대 또는 레거시 절대)를 현재 세션의 절대경로로 변환.
  /// - 상대경로 `board_images/x` → `<docs>/board_images/x`
  /// - 레거시 절대경로 `/.../board_images/x` → `board_images/x`만 떼어 재구성
  String resolve(String stored) {
    final marker = stored.indexOf('$_subdir/');
    final rel = marker == -1 ? stored : stored.substring(marker);
    if (rel.startsWith('/')) return rel; // 마커 없는 절대경로면 그대로
    final docs = _docsPath;
    return docs == null ? rel : '$docs/$rel';
  }

  /// picker 임시 파일을 documents/board_images로 복사하고 **상대경로** 반환.
  Future<String> save(
    String pickedPath, {
    required String dateKey,
    required String categoryId,
  }) async {
    final docs = await _ensureDocsPath();
    final dir = Directory('$docs/$_subdir');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final rel = '$_subdir/${dateKey}_${categoryId}_$stamp${_ext(pickedPath)}';
    await File(pickedPath).copy('$docs/$rel');
    return rel;
  }

  /// 저장된(상대 또는 레거시) 경로의 파일 삭제(없으면 무시).
  Future<void> delete(String storedPath) async {
    await _ensureDocsPath();
    final file = File(resolve(storedPath));
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// 교체: 새 파일 복사 후 옛 파일 삭제, 새 **상대경로** 반환.
  Future<String> replace({
    String? oldStoredPath,
    required String newPickedPath,
    required String dateKey,
    required String categoryId,
  }) async {
    final newPath = await save(
      newPickedPath,
      dateKey: dateKey,
      categoryId: categoryId,
    );
    if (oldStoredPath != null && oldStoredPath != newPath) {
      await delete(oldStoredPath);
    }
    return newPath;
  }

  /// 확장자(점 포함). 없으면 빈 문자열.
  String _ext(String path) {
    final name = path.split('/').last;
    final dot = name.lastIndexOf('.');
    return dot == -1 ? '' : name.substring(dot);
  }
}
