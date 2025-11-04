import 'package:flutter/material.dart';
import 'package:tempochores_app/tempochorespager.dart';

void main() => runApp(const TempoChoresApp());

class TempoChoresApp extends StatelessWidget {
  const TempoChoresApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TempoChores',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00E676)),
        useMaterial3: true,
      ),
      home: const TempoChoresPager(),
    );
  }
}
