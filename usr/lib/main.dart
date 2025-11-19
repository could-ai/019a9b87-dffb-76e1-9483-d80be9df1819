import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:couldai_user_app/screens/translation_screen.dart';
import 'package:couldai_user_app/screens/history_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 在这里替换为你的Supabase URL和Anon Key
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const TranslationScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'history',
          builder: (BuildContext context, GoRouterState state) {
            return const HistoryScreen();
          },
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '实时翻译',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}
