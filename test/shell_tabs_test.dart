// 로그인 후 4탭 셸에서 My·Calendar 탭이 예외 없이 렌더되는지(시뮬 탭 캡처 대체).
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitzy/main.dart';
import 'package:fitzy/services/image_store_service.dart';
import 'package:fitzy/services/storage_service.dart';

void main() {
  testWidgets('로그인 후 My·Calendar 탭 전환 렌더', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'flutter.fitzy.profile':
          '{"userId":"cherry","nickname":"체리","gender":"girl",'
              '"genderPrivate":false,"tags":["러블리"],"profileImagePath":null}',
    });
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      FitzyApp(
        repository: StorageService(prefs),
        imageStore: ImageStoreService(),
      ),
    );
    await tester.pump(); // load 완료
    await tester.pump(); // MainShell 리빌드

    // 셸(상단 FITZY) 표시
    expect(find.text('FITZY'), findsOneWidget);

    // My 탭
    await tester.tap(find.text('My'));
    await tester.pumpAndSettle();
    expect(find.text('체리'), findsOneWidget);
    expect(find.text('@cherry · girl'), findsOneWidget);
    expect(find.text('설정'), findsOneWidget);

    // Calendar 탭
    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();
    expect(find.text('이번 달 기록'), findsOneWidget);
    expect(find.text('가장 많이 기록한 무드'), findsOneWidget);
  });
}
