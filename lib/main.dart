import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/navigation/app_shell.dart';
import 'src/theme/droidlab_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: DroidLabApp()));
}

class DroidLabApp extends StatelessWidget {
  const DroidLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DroidLab',
      debugShowCheckedModeBanner: false,
      theme: DroidLabTheme.dark(),
      home: const AppShell(),
    );
  }
}
