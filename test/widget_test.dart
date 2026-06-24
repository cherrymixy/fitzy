// 게이트 스모크: 프로필이 없으면 첫 실행에 온보딩이 뜬다.
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitzy/main.dart';
import 'package:fitzy/services/image_store_service.dart';
import 'package:fitzy/services/storage_service.dart';

void main() {
  testWidgets('첫 실행: 프로필 없으면 온보딩이 뜬다', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      FitzyApp(
        repository: StorageService(prefs),
        imageStore: ImageStoreService(),
      ),
    );
    await tester.pump(); // ProfileProvider.load() 완료
    await tester.pump(); // 온보딩으로 리빌드

    expect(find.text('다음'), findsOneWidget); // 온보딩 첫 페이지 CTA
  });
}
