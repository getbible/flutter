import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'application/app_state.dart';
import 'presentation/reader_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final AppState state = await AppState.create();
  runApp(ChangeNotifierProvider.value(value: state, child: const GetBibleApp()));
}

class GetBibleApp extends StatelessWidget {
  const GetBibleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    return MaterialApp(
      title: 'getBible.live',
      debugShowCheckedModeBanner: false,
      themeMode: switch (state.preferences.appearanceMode) {
        AppearanceMode.system => ThemeMode.system,
        AppearanceMode.light => ThemeMode.light,
        AppearanceMode.dark => ThemeMode.dark,
      },
      theme: ThemeData(colorSchemeSeed: const Color(0xff276b9c), useMaterial3: true),
      darkTheme: ThemeData(colorSchemeSeed: const Color(0xff7fc8f8), brightness: Brightness.dark, useMaterial3: true),
      home: const ReaderScreen(),
    );
  }
}
