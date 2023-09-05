import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/app_bloc.dart';
import 'home_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: ((BuildContext context) => AppBloc()),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.red,
          ),
          home: const MyHomePage(),
        ));
  }
}
