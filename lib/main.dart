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
        home: const RootGate(),
      ),
    );
  }
}
