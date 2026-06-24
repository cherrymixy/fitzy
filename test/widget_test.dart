// STEP 1 스캐폴드 스모크 테스트: 셸이 떠서 "FITZY"가 보이는지만 확인.
import 'package:flutter_test/flutter_test.dart';

import 'package:fitzy/main.dart';

void main() {
  testWidgets('FITZY 워드마크가 렌더된다', (WidgetTester tester) async {
    await tester.pumpWidget(const FitzyApp());

    expect(find.text('FITZY'), findsOneWidget);
  });
}
