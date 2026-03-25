import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'providers/workspace_provider.dart';
import 'screens/workspace_selection_screen.dart';
import 'screens/workspace_home_screen.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  final windowController = await WindowController.fromCurrentEngine();
  final windowArgs = windowController.arguments;

  // Determine if this is a sub-window (new window)
  bool isNewWindow = false;
  if (windowArgs.isNotEmpty) {
    try {
      final parsed = jsonDecode(windowArgs) as Map<String, dynamic>;
      isNewWindow = parsed['newWindow'] == true;
    } catch (_) {}
  }

  if (isNewWindow) {
    // Sub-window: configure window options and show
    const windowOptions = WindowOptions(
      size: Size(800, 600),
      center: true,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(MyApp(skipRestore: isNewWindow));
}

class MyApp extends StatelessWidget {
  final bool skipRestore;

  const MyApp({super.key, this.skipRestore = false});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final provider = WorkspaceProvider();
        if (!skipRestore) {
          provider.init();
        } else {
          provider.skipInit();
        }
        return provider;
      },
      child: MaterialApp(
        title: 'Sunon',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const AppShell(),
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowFocus() {
    context.read<WorkspaceProvider>().refreshProjects();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkspaceProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (provider.hasWorkspace) {
          return const WorkspaceHomeScreen();
        }
        return const WorkspaceSelectionScreen();
      },
    );
  }
}
