// 저장된 이미지 참조를 플랫폼에 맞게 표시.
// 기본(웹)은 Image.network, dart:io 가능한 환경(모바일/데스크탑)은 Image.file.
export 'local_image_web.dart' if (dart.library.io) 'local_image_io.dart';
