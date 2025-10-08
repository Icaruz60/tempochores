import 'package:flutter/material.dart';
import 'package:tempochores_app/pages/home_page.dart';
import 'package:tempochores_app/pages/time_chore_page.dart';
import 'package:tempochores_app/pages/plan_tempochore_page.dart';
import 'package:tempochores_app/pages/edit_chores_page.dart';

void main() {
  runApp(const TempoChoresApp());
}

class TempoChoresApp extends StatelessWidget {
  const TempoChoresApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TempoChores',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Poppins', primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/pages/home_page': (context) => const HomePage(),
        '/time': (context) => const TimeChorePage(),
        '/plan': (context) => const PlanTempoChorePage(),
        '/edit': (context) => const EditChoresPage(),
      },
    );
  }
}
