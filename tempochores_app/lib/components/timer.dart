// lib/components/timer.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tempochores_app/theme/colors.dart';

class TimerController {
  void Function()? _start;
  void Function()? _pause;
  void Function([Duration])? _reset;

  void _attach({
    required void Function() start,
    required void Function() pause,
    required void Function([Duration]) reset,
  }) {
    _start = start;
    _pause = pause;
    _reset = reset;
  }

  void start() => _start?.call();
  void pause() => _pause?.call();
  void reset([Duration d = Duration.zero]) => _reset?.call(d);
}

class TimerDisplay extends StatefulWidget {
  const TimerDisplay({
    super.key,
    this.controller,
    this.running = false,
    this.startFrom = Duration.zero,
    this.onTick,
  });

  final TimerController? controller; // NEW
  final bool running;
  final Duration startFrom;
  final ValueChanged<Duration>? onTick;

  @override
  State<TimerDisplay> createState() => _TimerDisplayState();
}

class _TimerDisplayState extends State<TimerDisplay> {
  late Duration _elapsed;
  Timer? _timer;

  bool get _timerActive => _timer?.isActive ?? false;

  @override
  void initState() {
    super.initState();
    _elapsed = widget.startFrom;
    widget.controller?._attach(
      start: _start,
      pause: _stop,
      reset: ([_d = Duration.zero]) {
        _stop();
        setState(() => _elapsed = _d);
      },
    );
    if (widget.running) _start();
  }

  @override
  void didUpdateWidget(TimerDisplay old) {
    super.didUpdateWidget(old);
    // respond to running prop
    if (widget.running && !_timerActive) _start();
    if (!widget.running && _timerActive) _stop();
    // respond to startFrom changes too
    if (widget.startFrom != old.startFrom) {
      setState(() => _elapsed = widget.startFrom);
    }
    // re-attach controller if it changed
    if (widget.controller != old.controller && widget.controller != null) {
      widget.controller!._attach(
        start: _start,
        pause: _stop,
        reset: ([_d = Duration.zero]) {
          _stop();
          setState(() => _elapsed = _d);
        },
      );
    }
  }

  void _start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed += const Duration(seconds: 1));
      widget.onTick?.call(_elapsed);
    });
  }

  void _stop() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final h = d.inHours;
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        _format(_elapsed),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'ChakraPetch',
          fontSize: 72,
          letterSpacing: 2,
          color: AppColors.secondary,
          shadows: const [
            Shadow(offset: Offset(0, 0), blurRadius: 20, color: Colors.black54),
            Shadow(
              offset: Offset(0, 0),
              blurRadius: 40,
              color: Colors.greenAccent,
            ),
          ],
        ),
      ),
    );
  }
}
