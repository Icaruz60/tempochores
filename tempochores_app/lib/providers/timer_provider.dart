import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:tempochores_app/models/chore.dart';

class TimerProvider extends ChangeNotifier {
  Timer? _timer;
  Duration _remaining = Duration.zero;
  Duration _elapsed = Duration.zero; // true elapsed time tracker
  Duration? _initialRemaining;
  DateTime? _startTime;
  DateTime? _lastMark; // for per-chore elapsed differences
  bool _running = false;

  List<String> _plannedIds = []; // chores planned for current session
  Set<String> _completedIds = {}; // chores completed in current session

  // getters
  Duration get remaining => _remaining;
  Duration get elapsed => _elapsed;
  bool get running => _running;
  DateTime? get startTime => _startTime;
  List<String> get plannedIds => _plannedIds;
  Set<String> get completedIds => _completedIds;

  // start timer (countdown + elapsed tracking)
  void start(int minutes, [List<Chore>? planned]) {
    _remaining = Duration(minutes: minutes);
    _elapsed = Duration.zero;
    _initialRemaining = _remaining;
    _startTime = DateTime.now();
    _lastMark = DateTime.now();
    _running = true;

    if (planned != null) {
      _plannedIds = planned.map((c) => c.id).toList();
      _completedIds.clear();
    }

    notifyListeners();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remaining > Duration.zero) {
        _remaining -= const Duration(seconds: 1);
        _elapsed += const Duration(seconds: 1);
        _saveState();
        notifyListeners();
      } else {
        stop();
      }
    });
  }

  // stop timer
  void stop() {
    _timer?.cancel();
    _timer = null;
    _running = false;
    _saveState(clear: true);
    notifyListeners();
  }

  /// Stopwatch-style elapsed time since last mark
  Duration consumeElapsed() {
    if (!_running) return Duration.zero;
    final now = DateTime.now();
    if (_lastMark == null) {
      _lastMark = now;
      return Duration.zero;
    }
    final diff = now.difference(_lastMark!);
    _lastMark = now;
    _saveState();
    return diff;
  }

  /// Called when user marks a chore complete
  void completeChore(Chore chore) {
    final diff = consumeElapsed();
    if (diff <= Duration.zero) return;
    final box = Hive.box<Chore>('chores');
    chore.addTime(diff);
    box.put(chore.id, chore);

    _completedIds.add(chore.id);
    _saveState();
    notifyListeners();
  }

  /// Reset completion tracking
  void resetCompletionTracking() {
    _lastMark = DateTime.now();
    _saveState();
  }

  // Save page state
  Future<void> _saveState({bool clear = false}) async {
    final box = await Hive.openBox('timer_state');
    if (clear) {
      await box.clear();
      return;
    }

    await box.putAll({
      'remaining': _remaining.inSeconds,
      'elapsed': _elapsed.inSeconds,
      'initialRemaining': _initialRemaining?.inSeconds ?? 0,
      'running': _running,
      'startTime': _startTime?.millisecondsSinceEpoch,
      'lastMark': _lastMark?.millisecondsSinceEpoch,
      'plannedIds': _plannedIds,
      'completedIds': _completedIds.toList(),
    });
  }

  // Restore page state
  Future<void> restoreState() async {
    final box = await Hive.openBox('timer_state');
    final running = box.get('running', defaultValue: false);
    final remainingSeconds = box.get('remaining', defaultValue: 0);
    final elapsedSeconds = box.get('elapsed', defaultValue: 0);
    final initialSeconds = box.get('initialRemaining', defaultValue: 0);
    final startMillis = box.get('startTime');
    final lastMarkMillis = box.get('lastMark');
    final plannedIds = box.get('plannedIds', defaultValue: <String>[]);
    final completedIds = box.get('completedIds', defaultValue: <String>[]);

    _remaining = Duration(seconds: remainingSeconds);
    _elapsed = Duration(seconds: elapsedSeconds);
    _initialRemaining = Duration(seconds: initialSeconds);
    _plannedIds = List<String>.from(plannedIds);
    _completedIds = Set<String>.from(completedIds);

    if (startMillis != null) {
      _startTime = DateTime.fromMillisecondsSinceEpoch(startMillis);
    }
    if (lastMarkMillis != null) {
      _lastMark = DateTime.fromMillisecondsSinceEpoch(lastMarkMillis);
    }

    if (running) {
      _running = true;
      _resume();
    }
    notifyListeners();
  }

  // Resume the timer after restoring page
  void _resume() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remaining > Duration.zero) {
        _remaining -= const Duration(seconds: 1);
        _elapsed += const Duration(seconds: 1);
        _saveState();
        notifyListeners();
      } else {
        stop();
      }
    });
  }
}
