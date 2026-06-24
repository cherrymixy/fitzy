import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// 사용자 이미지 파일 생애주기 관리.
///
/// image_picker가 준 임시 파일을 documents 하위로 '복사'해 영구 경로를 만든다.
/// 교체/삭제 시 옛 파일을 정리한다. 저장되는 것은 항상 이 영구 경로(String).
class ImageStoreService {
  static const String _subdir = 'board_images';

  Future<Directory> _ensureDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/$_subdir');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// picker 임시 파일을 documents로 복사하고 영구 경로 반환.
  Future<String> save(
    String pickedPath, {
    required String dateKey,
    required String categoryId,
  }) async {
    final dir = await _ensureDir();
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final dest = '${dir.path}/${dateKey}_${categoryId}_$stamp${_ext(pickedPath)}';
    await File(pickedPath).copy(dest);
    return dest;
  }

  /// 저장된 파일 삭제(없으면 무시).
  Future<void> delete(String storedPath) async {
    final file = File(storedPath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// 교체: 새 파일 복사 후 옛 파일 삭제, 새 경로 반환.
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
