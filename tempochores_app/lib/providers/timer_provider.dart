import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class TimerProvider extends ChangeNotifier {
  static const _timerStateBox = 'timer_state';

  Timer? _timer;
  Duration _remaining = Duration.zero;
  Duration _elapsed = Duration.zero; //  true elapsed time tracker
  Duration? _initialRemaining;
  DateTime? _startTime;
  DateTime? _lastMark; // for per-chore elapsed differences
  bool _running = false;

  Duration get remaining => _remaining;
  Duration get elapsed => _elapsed;
  bool get running => _running;
  DateTime? get startTime => _startTime;

  // START TIMER (countdown + elapsed tracking)
  void start(int minutes) {
    _remaining = Duration(minutes: minutes);
    _elapsed = Duration.zero;
    _initialRemaining = _remaining;
    _startTime = DateTime.now();
    _lastMark = DateTime.now();
    _running = true;
    notifyListeners();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remaining > Duration.zero) {
        _remaining -= const Duration(seconds: 1);
        _elapsed += const Duration(seconds: 1);
        notifyListeners();
      } else {
        stop();
      }
    });
  }

  // STOP TIMER
  void stop() {
    _timer?.cancel();
    _timer = null;
    _running = false;
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
    return diff;
  }

  /// Reset completion tracking 
  void resetCompletionTracking() {
    _lastMark = DateTime.now();
  }

  // SAVE STATE 
  Future<void> saveState() async {
    final box = Hive.box(_timerStateBox);
    await box.put('remaining', _remaining.inSeconds);
    await box.put('elapsed', _elapsed.inSeconds);
    await box.put('initialRemaining', _initialRemaining?.inSeconds ?? 0);
    await box.put('running', _running);
    await box.put('startTime', _startTime?.millisecondsSinceEpoch);
  }

  // RESTORE STATE
  Future<void> restoreState() async {
    final box = Hive.box(_timerStateBox);
    final running = box.get('running', defaultValue: false);
    final remainingSeconds = box.get('remaining', defaultValue: 0);
    final elapsedSeconds = box.get('elapsed', defaultValue: 0);
    final initialSeconds = box.get('initialRemaining', defaultValue: 0);
    final startMillis = box.get('startTime');

    _remaining = Duration(seconds: remainingSeconds);
    _elapsed = Duration(seconds: elapsedSeconds);
    _initialRemaining = Duration(seconds: initialSeconds);
    if (startMillis != null) {
      _startTime = DateTime.fromMillisecondsSinceEpoch(startMillis);
    }

    if (running) {
      _running = true;
      _resume();
    }
    notifyListeners();
  }

  // RESUME TIMER AFTER RESTORE
  void _resume() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remaining > Duration.zero) {
        _remaining -= const Duration(seconds: 1);
        _elapsed += const Duration(seconds: 1);
        notifyListeners();
      } else {
        stop();
      }
    });
  }
}
