// 웹: 저장된 참조(blob/URL)를 네트워크 이미지로 표시.
import 'package:flutter/widgets.dart';

Widget localImage(
  String path, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  Widget? error,
}) {
  return Image.network(
    path,
    width: width,
    height: height,
    fit: fit,
    errorBuilder: error == null ? null : (_, _, _) => error,
  );
}
