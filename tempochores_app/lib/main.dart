import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tempochores_app/components/boxes.dart';
import 'package:tempochores_app/components/storage_init.dart';
import 'package:tempochores_app/providers/timer_provider.dart';
import 'package:tempochores_app/tempochorespager.dart';
import 'package:tempochores_app/theme/app_theme.dart';

Future<void> main() async {
  await AppStorage.init(
    boxes: Boxes.allNames,
    registerAdapters: Boxes.registerAdapters,
    customOpeners: Boxes.customOpeners,
  );
  runApp(const TempoChoresApp());
}

class TempoChoresApp extends StatelessWidget {
  const TempoChoresApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TimerProvider>(
          create: (_) {
            final provider = TimerProvider();
            unawaited(provider.restoreState());
            return provider;
          },
        ),
      ],
      child: MaterialApp(
        title: 'TempoChores',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const TempoChoresPager(),
      ),
    );
  }
}
