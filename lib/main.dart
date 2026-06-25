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

/// 넓은 웹 화면(데스크탑)에서는 폰 프레임(SSOT 393×852)으로 중앙 정렬 + 맞춤
/// 스케일. 앱이 절대좌표 기반이라 전체 창에 펼치면 깨지므로 폰 캔버스 안에서
/// 그대로 렌더하고 FittedBox로 창에 맞춘다. 모바일/네이티브는 그대로(변경 없음).
Widget _responsiveFrame(BuildContext context, Widget? child) {
  final mq = MediaQuery.of(context);
  final content = child ?? const SizedBox.shrink();
  if (!kIsWeb || mq.size.width <= 600) return content;

  const fw = 393.0, fh = 852.0;
  return ColoredBox(
    color: const Color(0xFFE7E7EA),
    child: Center(
      child: FittedBox(
        fit: BoxFit.contain,
        child: Container(
          width: fw,
          height: fh,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 40,
                offset: Offset(0, 14),
              ),
            ],
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
        ),
      ),
    ),
  );
}
