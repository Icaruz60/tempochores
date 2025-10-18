import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tempochores_app/models/chore.dart';
import 'package:tempochores_app/models/priority.dart';

class StorageInit {
  static bool _initialized = false;
  static const String choreBoxName = 'chores';

  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;

    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);

    Hive
      ..registerAdapter(ChoreAdapter())
      ..registerAdapter(PriorityAdapter());

    await Hive.openBox<Chore>(choreBoxName);
    await Hive.openBox('timer_state');
    await Hive.openBox('plan_state');
  }
}
