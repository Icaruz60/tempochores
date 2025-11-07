// lib/boxes.dart
import 'package:hive/hive.dart';
import 'package:tempochores_app/models/chore.dart';
import 'package:tempochores_app/models/priority.dart';

import 'storage_init.dart';

// If you have typed adapters, import them here and expose registerAdapters().
// import 'models/chore.dart';
// import 'models/plan.dart';
// ...

class Boxes {
  // Single source of truth: put EVERY box name here.
  // If you add another box later, add it here and nowhere else.
  static const String settings = 'settings';
  static const String chores = 'chores';
  static const String plans = 'plans';
  static const String timers = 'timers';
  static const String timerState = 'timer_state';

  /// Exported for main.dart to initialize everything without duplicating names.
  static const List<String> allNames = [
    settings,
    chores,
    plans,
    timers,
    timerState,
  ];

  static final Map<String, Future<void> Function()> customOpeners = {
    chores: () => Hive.openBox<Chore>(chores),
  };

  /// If you use generated/typed adapters, register them here.
  static void registerAdapters() {
    final priorityAdapter = PriorityAdapter();
    if (!Hive.isAdapterRegistered(priorityAdapter.typeId)) {
      Hive.registerAdapter(priorityAdapter);
    }

    final choreAdapter = ChoreAdapter();
    if (!Hive.isAdapterRegistered(choreAdapter.typeId)) {
      Hive.registerAdapter(choreAdapter);
    }
  }

  /// Optional: allow legacy code to "ensure" readiness without harming anything.
  static Future<void> ensureReady() async {
    if (!AppStorage.isReady) {
      await AppStorage.init(
        boxes: allNames,
        registerAdapters: registerAdapters,
      );
    }
  }

  // -------------- Legacy async API (kept as no-ops for compatibility) --------------
  static Future<Box> openSettings() async => _ensureOpen<dynamic>(settings);
  static Future<Box<Chore>> openChores() async => _ensureOpen<Chore>(chores);
  static Future<Box> openPlans() async => _ensureOpen<dynamic>(plans);
  static Future<Box> openTimers() async => _ensureOpen<dynamic>(timers);

  static Future<Box<T>> _ensureOpen<T>(String name) async {
    if (!AppStorage.isReady) {
      await AppStorage.init(
        boxes: allNames,
        registerAdapters: registerAdapters,
      );
    }
    return Hive.box<T>(name);
  }

  // -------------- Synchronous getters (preferred) --------------
  static Box get settingsBox => Hive.box(settings);
  static Box<Chore> get choresBox => Hive.box<Chore>(chores);
  static Box get plansBox => Hive.box(plans);
  static Box get timersBox => Hive.box(timers);
  static Box get timerStateBox => Hive.box(timerState);

  // If you use typed boxes, add typed getters too:
  // static Box<Chore> get choresBox => Hive.box<Chore>(chores);
}
