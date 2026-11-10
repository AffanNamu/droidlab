import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF090D16),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF38BDF8),
          brightness: Brightness.dark,
          surface: const Color(0xFF101827),
        ),
      ),
      home: const DroidLabHome(),
    );
  }
}

class DroidLabHome extends StatelessWidget {
  const DroidLabHome({super.key});

  static const Color cyan = Color(0xFF38BDF8);
  static const Color muted = Color(0xFF94A3B8);
  static const Color panel = Color(0xFF101827);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text.rich(TextSpan(children: [
          TextSpan(text: 'Droid', style: TextStyle(fontWeight: FontWeight.w800)),
          TextSpan(text: 'Lab', style: TextStyle(color: cyan, fontWeight: FontWeight.w800)),
        ])),
        actions: const [Padding(padding: EdgeInsets.only(right: 18), child: Icon(Icons.notifications_none_rounded))],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Text('Your Android engineering studio', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('Import, inspect, edit, build, sign and install — locally on your device.', style: TextStyle(color: muted, height: 1.4)),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(colors: [Color(0xFF10243B), Color(0xFF171B3A)]),
                border: Border.all(color: cyan.withValues(alpha: 0.25)),
              ),
              child: const Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Import. Inspect. Edit. Build.', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
                  SizedBox(height: 8),
                  Text('Work with APKs and Android source projects in your private workspace.', style: TextStyle(color: muted)),
                ])),
                SizedBox(width: 12),
                Icon(Icons.android_rounded, size: 48, color: cyan),
              ]),
            ),
            const SizedBox(height: 18),
            Row(children: [
              Expanded(child: _ActionCard(icon: Icons.install_mobile_rounded, title: 'Import APK', subtitle: 'Inspect an app')),
              const SizedBox(width: 12),
              Expanded(child: _ActionCard(icon: Icons.folder_zip_rounded, title: 'Import Project', subtitle: 'Open source files')),
            ]),
            const SizedBox(height: 26),
            Text('Quick tools', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            const Wrap(spacing: 8, runSpacing: 8, children: [
              _ToolChip(icon: Icons.code_rounded, label: 'Code Editor'),
              _ToolChip(icon: Icons.analytics_outlined, label: 'APK Analyzer'),
              _ToolChip(icon: Icons.build_outlined, label: 'Build & Sign'),
              _ToolChip(icon: Icons.verified_outlined, label: 'Verify APK'),
            ]),
            const SizedBox(height: 26),
            Text('Engine status', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFF172235))),
              child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.memory_rounded, color: cyan),
                SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Native engine foundation', style: TextStyle(fontWeight: FontWeight.w700)),
                  SizedBox(height: 5),
                  Text('Device capability checks will report actual readiness. No placeholder green indicators.', style: TextStyle(color: muted, height: 1.4)),
                ])),
              ]),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.folder_outlined), label: 'Projects'),
          NavigationDestination(icon: Icon(Icons.code), label: 'Workspace'),
          NavigationDestination(icon: Icon(Icons.build_outlined), label: 'Tools'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(color: const Color(0xFF172235), borderRadius: BorderRadius.circular(18)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: DroidLabHome.cyan, size: 28),
      const SizedBox(height: 14),
      Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      const SizedBox(height: 4),
      Text(subtitle, style: const TextStyle(color: DroidLabHome.muted, fontSize: 12)),
    ]),
  );
}

class _ToolChip extends StatelessWidget {
  const _ToolChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Chip(
    avatar: Icon(icon, size: 18, color: DroidLabHome.cyan),
    label: Text(label),
    backgroundColor: const Color(0xFF101827),
    side: BorderSide.none,
  );
}
