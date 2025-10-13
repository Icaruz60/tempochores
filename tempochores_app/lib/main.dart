import 'package:flutter/material.dart';
import 'package:tempochores_app/pages/home_page.dart';
import 'package:tempochores_app/pages/time_chore_page.dart';
import 'package:tempochores_app/pages/plan_tempochore_page.dart';
import 'package:tempochores_app/pages/edit_chores_page.dart';
import 'package:tempochores_app/theme/app_theme.dart';
import 'package:tempochores_app/components/storage_init.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageInit.ensureInitialized();
  runApp(const TempoChoresApp());
}

class TempoChoresApp extends StatelessWidget {
  const TempoChoresApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TempoChores',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/home_page': (context) => const HomePage(),
        '/time': (context) => const TimeChorePage(),
        '/plan': (context) => const PlanTempoChorePage(),
        '/edit': (context) => const EditChoresPage(),
      },
    );
  }
}
