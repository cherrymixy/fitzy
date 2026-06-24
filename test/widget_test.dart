// 스캐폴드 스모크 테스트: 프로바이더 배선과 함께 셸이 떠서 "FITZY"가 보이는지.
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitzy/main.dart';
import 'package:fitzy/services/image_store_service.dart';
import 'package:fitzy/services/storage_service.dart';

void main() {
  testWidgets('FITZY 워드마크가 렌더된다', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      FitzyApp(
        repository: StorageService(prefs),
        imageStore: ImageStoreService(),
      ),
    );

    expect(find.text('FITZY'), findsOneWidget);
  });
}
