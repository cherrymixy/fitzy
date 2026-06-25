import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/board_provider.dart';
import 'providers/coin_provider.dart';
import 'providers/profile_provider.dart';
import 'repositories/data_repository.dart';
import 'screens/root_gate.dart';
import 'services/image_store_service.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // 경로 A(로컬). 경로 B 전환 시 이 한 줄만 FirestoreRepository로 교체.
  final DataRepository repository = StorageService(prefs);
  final imageStore = ImageStoreService();
  await imageStore.init(); // documents 절대경로 캐시(상대경로 표시용)

  runApp(FitzyApp(repository: repository, imageStore: imageStore));
}

/// STEP 4: 데이터·상태 배선 + 첫 실행 게이트(온보딩/가입 ↔ 메인).
class FitzyApp extends StatelessWidget {
  const FitzyApp({
    super.key,
    required this.repository,
    required this.imageStore,
  });

  final DataRepository repository;
  final ImageStoreService imageStore;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ImageStoreService>.value(value: imageStore),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(repository)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => CoinProvider(repository)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => BoardProvider(repository, imageStore)..load(),
        ),
      ],
      child: MaterialApp(
        title: 'FITZY',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        builder: _responsiveFrame,
        home: const RootGate(),
      ),
    );
  }
}

/// 웹에서 앱을 SSOT 폰 캔버스(393×852)에 고정하고 뷰포트에 맞춰 스케일(contain)한다.
/// 앱이 절대좌표 기반이라, 캔버스보다 짧은 모바일 뷰포트(브라우저 툴바)나 넓은
/// 데스크탑 창에 그대로 펼치면 아래가 잘리거나 좌상단에 몰린다. 캔버스째 스케일하면
/// 항상 전체가 보인다.
/// - 데스크탑(폭>600): 회색 배경 + 폰 프레임 룩(라운드/그림자)
/// - 모바일 웹: 흰 배경(여백이 앱 배경과 같아 거의 안 보임) + 맞춤 스케일
/// 네이티브(iOS/Android)는 변경 없음.
Widget _responsiveFrame(BuildContext context, Widget? child) {
  final mq = MediaQuery.of(context);
  final content = child ?? const SizedBox.shrink();
  if (!kIsWeb) return content;

  const fw = 393.0, fh = 852.0;
  final wide = mq.size.width > 600;

  final canvas = Container(
    width: fw,
    height: fh,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: wide ? BorderRadius.circular(28) : BorderRadius.zero,
      boxShadow: wide
          ? const [
              BoxShadow(color: Color(0x33000000), blurRadius: 40, offset: Offset(0, 14)),
            ]
          : null,
    ),
    child: MediaQuery(
      data: mq.copyWith(
        size: const Size(fw, fh),
        padding: EdgeInsets.zero,
        viewInsets: EdgeInsets.zero,
        viewPadding: EdgeInsets.zero,
      ),
      child: content,
    ),
  );

  return ColoredBox(
    color: wide ? const Color(0xFFE7E7EA) : Colors.white,
    child: Center(
      child: FittedBox(fit: BoxFit.contain, child: canvas),
    ),
  );
}
