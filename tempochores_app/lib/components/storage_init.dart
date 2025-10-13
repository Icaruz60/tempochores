import 'package:hive_flutter/hive_flutter.dart';
import 'package:tempochores_app/models/chore.dart';
import 'package:tempochores_app/models/priority.dart';

class StorageInit {
  static bool _initialized = false;
  static const String choreBoxName = 'chores';

  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;

    await Hive.initFlutter();

    // Register adapters once
    Hive
      ..registerAdapter(ChoreAdapter())
      ..registerAdapter(PriorityAdapter());

    // Open boxes you’ll use across the app
    await Hive.openBox<Chore>(choreBoxName);
  }
}
