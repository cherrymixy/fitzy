// 웹 스텁 — 파일시스템/path_provider 없음.
// 웹은 image_picker의 blob URL을 그대로 쓰므로 복사/삭제는 no-op.
const bool kIsWebFs = true;

Future<String> documentsPath() async => '';

Future<void> copyTo(String from, String to) async {}

Future<void> ensureDir(String dir) async {}

Future<void> deletePath(String path) async {}
