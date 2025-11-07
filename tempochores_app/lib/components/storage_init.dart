// lib/components/storage_init.dart
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';

typedef AdapterRegistrar = void Function();

class AppStorage {
  static bool _ready = false;
  static Future<void>? _boot;

  /// Call once at app start. Safe to call multiple times.
  static Future<void> init({
    required List<String> boxes,
    AdapterRegistrar? registerAdapters,
    Map<String, Future<void> Function()>? customOpeners,
  }) {
    return _boot ??= _initImpl(
      boxes: boxes,
      registerAdapters: registerAdapters,
      customOpeners: customOpeners,
    );
  }

  static Future<void> _initImpl({
    required List<String> boxes,
    AdapterRegistrar? registerAdapters,
    Map<String, Future<void> Function()>? customOpeners,
  }) async {
    WidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter();

    // Optional hook so you can register adapters in main.dart without coupling.
    if (registerAdapters != null) {
      registerAdapters();
    }

    for (final name in boxes) {
      if (Hive.isBoxOpen(name)) continue;
      final opener = customOpeners?[name];
      if (opener != null) {
        await opener();
        continue;
      }
      await Hive.openBox(name);
    }
    _ready = true;
  }

  static bool get isReady => _ready;

  /// Use AFTER init. Synchronous access to already-opened boxes.
  static Box<T> box<T>(String name) => Hive.box<T>(name);
}
