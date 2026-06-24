import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/board_provider.dart';
import 'providers/coin_provider.dart';
import 'providers/profile_provider.dart';
import 'repositories/data_repository.dart';
import 'services/image_store_service.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // 경로 A(로컬). 경로 B 전환 시 이 한 줄만 FirestoreRepository로 교체.
  final DataRepository repository = StorageService(prefs);
  final imageStore = ImageStoreService();

  runApp(FitzyApp(repository: repository, imageStore: imageStore));
}

/// STEP 3: 데이터 계층(Repository)·상태(Provider) 배선. 화면은 아직 빈 셸.
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
      child: const MaterialApp(
        title: 'FITZY',
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Text('FITZY'),
          ),
        ),
      ),
    );
  }
}
