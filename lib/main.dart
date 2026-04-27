import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/app.dart';
import 'features/user/data/user_storage_service.dart';
import 'features/user/state/user_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  final userStorageService = UserStorageService();
  await userStorageService.init();

  runApp(
    ProviderScope(
      overrides: [
        userStorageServiceProvider.overrideWithValue(userStorageService),
      ],
      child: const MyApp(),
    ),
  );
}
