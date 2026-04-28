import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/user/presentation/pages/start_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: AppTheme.darkTheme,
      home: const StartPage(),
    );
  }
}
