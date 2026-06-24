// 로그인 후 셸(SSOT) + 4탭이 예외 없이 렌더되는지.
// IndexedStack은 모든 탭을 빌드하므로 탭 전환 없이 각 탭 내용으로 검증.
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitzy/main.dart';
import 'package:fitzy/services/image_store_service.dart';
import 'package:fitzy/services/storage_service.dart';

void main() {
  testWidgets('로그인 후 셸·4탭 렌더', (WidgetTester tester) async {
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

    // 활성 네비 라벨 + Select 본문
    expect(find.text('Select'), findsOneWidget);
    expect(find.text('Pick Your Fit'), findsOneWidget);

    // IndexedStack이 모든 탭을 빌드(비선택 탭은 offstage) → skipOffstage:false로 검증
    expect(find.text('체리', skipOffstage: false), findsOneWidget);
    expect(find.text('이번 달 기록', skipOffstage: false), findsOneWidget);
  });
}
