// 모바일/데스크탑 구현 — dart:io + path_provider.
import 'dart:io';

import 'package:path_provider/path_provider.dart';

const bool kIsWebFs = false;

Future<String> documentsPath() async =>
    (await getApplicationDocumentsDirectory()).path;

Future<void> copyTo(String from, String to) async {
  await File(from).copy(to);
}

Future<void> ensureDir(String dir) async {
  final d = Directory(dir);
  if (!await d.exists()) {
    await d.create(recursive: true);
  }
}

Future<void> deletePath(String path) async {
  final f = File(path);
  if (await f.exists()) {
    await f.delete();
  }
}
