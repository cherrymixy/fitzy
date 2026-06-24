import 'image_fs_web.dart' if (dart.library.io) 'image_fs_io.dart' as fs;

/// 사용자 이미지 파일 생애주기 관리 (크로스플랫폼).
///
/// 모바일: documents 하위로 복사하고 **상대경로**(`board_images/xxx`)를 저장,
/// 표시 시 [resolve]로 현재 세션 절대경로로 재구성(iOS 컨테이너 UUID 변경 대응).
/// 웹: 파일시스템이 없어 image_picker의 blob URL을 그대로 저장/표시(세션 한정).
class ImageStoreService {
  static const String _subdir = 'board_images';

  String? _docsPath;

  /// 앱 시작 시 1회 호출(main). documents 절대경로를 캐시(웹은 빈 문자열).
  Future<void> init() async {
    _docsPath ??= await fs.documentsPath();
  }

  Future<String> _ensureDocsPath() async =>
      _docsPath ??= await fs.documentsPath();

  /// 저장 참조를 표시용 경로로 변환.
  /// - 웹: blob URL 그대로
  /// - 모바일: 상대경로→현재 docs 결합, 레거시 절대경로는 board_images부터 추출
  String resolve(String stored) {
    if (fs.kIsWebFs) return stored;
    final marker = stored.indexOf('$_subdir/');
    final rel = marker == -1 ? stored : stored.substring(marker);
    if (rel.startsWith('/')) return rel;
    final docs = _docsPath;
    return (docs == null || docs.isEmpty) ? rel : '$docs/$rel';
  }

  /// picker 결과를 영구화하고 저장 참조 반환(모바일=상대경로, 웹=blob URL).
  Future<String> save(
    String pickedPath, {
    required String dateKey,
    required String categoryId,
  }) async {
    if (fs.kIsWebFs) return pickedPath;
    final docs = await _ensureDocsPath();
    await fs.ensureDir('$docs/$_subdir');
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final rel = '$_subdir/${dateKey}_${categoryId}_$stamp${_ext(pickedPath)}';
    await fs.copyTo(pickedPath, '$docs/$rel');
    return rel;
  }

  /// 저장된 파일 삭제(웹은 no-op).
  Future<void> delete(String storedPath) async {
    if (fs.kIsWebFs) return;
    await _ensureDocsPath();
    await fs.deletePath(resolve(storedPath));
  }

  /// 교체: 새 파일 영구화 후 옛 파일 삭제, 새 참조 반환.
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
