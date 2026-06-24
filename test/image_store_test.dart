// 이미지 경로 resolve의 마이그레이션 로직: 레거시 절대경로 → 상대경로 추출.
// (docs 절대경로 결합은 라이브(시드) 검증으로 확인. 여기선 추출 규칙만.)
import 'package:flutter_test/flutter_test.dart';

import 'package:fitzy/services/image_store_service.dart';

void main() {
  test('resolve: 레거시 절대경로에서 board_images 상대경로 추출', () {
    final store = ImageStoreService(); // init 안 함 → docsPath null(추출만 검증)

    // 이미 상대경로면 그대로(추후 docs와 결합)
    expect(store.resolve('board_images/a.jpg'), 'board_images/a.jpg');

    // 레거시 절대경로(옛 컨테이너 UUID) → board_images부터 떼어 상대경로화
    expect(
      store.resolve(
        '/var/Containers/Data/Application/OLD-UUID/Documents/board_images/a.jpg',
      ),
      'board_images/a.jpg',
    );

    // board_images 마커가 없는 절대경로는 그대로 둔다
    expect(store.resolve('/somewhere/else.jpg'), '/somewhere/else.jpg');
  });
}
