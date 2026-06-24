// 모바일/데스크탑: 로컬 파일 이미지.
import 'dart:io';

import 'package:flutter/widgets.dart';

Widget localImage(
  String path, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  Widget? error,
}) {
  return Image.file(
    File(path),
    width: width,
    height: height,
    fit: fit,
    errorBuilder: error == null ? null : (_, _, _) => error,
  );
}
