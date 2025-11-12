import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tempochores_app/data/chore_repository.dart';
import 'package:tempochores_app/theme/colors.dart';
import 'package:tempochores_app/components/timer.dart';
import 'package:tempochores_app/components/timer_control_bar.dart';
import 'package:tempochores_app/components/chore_dropdown.dart';


class TimeChorePage extends StatefulWidget {
  const TimeChorePage({super.key});

  @override
  State<TimeChorePage> createState() => _TimeChorePageState();
}

class _TimeChorePageState extends State<TimeChorePage> {
  String? _selectedChoreId;
  bool _timerRunning = false;
  Duration _elapsed = Duration.zero;
  final TimerController _timerCtrl = TimerController();

  void _start() {
    setState(() {
      _timerRunning = true;
      _elapsed = Duration.zero;
    });
    _timerCtrl.reset(Duration.zero);
    _timerCtrl.start();
  }

  void _pause() {
    setState(() => _timerRunning = !_timerRunning);
    _timerCtrl.pause();
  }

  void _cancel() {
    setState(() {
      _timerRunning = false;
      _elapsed = Duration.zero;
    });
    _timerCtrl.reset(Duration.zero);
  }

  Future<void> _done(BuildContext context) async {
    setState(() => _timerRunning = false);
    _timerCtrl.pause();

    if (_selectedChoreId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a chore first.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final repo = context.read<ChoreRepository>();
    final chore = repo.getById(_selectedChoreId!);

    if (chore == null) return;

    await repo.addTime(chore.id, _elapsed);

    if (!mounted) return;
    
    final m = _elapsed.inMinutes;
    final s = _elapsed.inSeconds % 60;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Recorded ${m}m ${s}s for "${chore.name}"!'),
        backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 2),
      ),
    );

    setState(() => _elapsed = Duration.zero);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_outlined, color: AppColors.secondary, size: 40),
            const SizedBox(width: 8),
            const Text('Time a Chore'),
          ],
        ),
        centerTitle: true,
        foregroundColor: AppColors.secondary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const SizedBox(height: 30),

            // --- Chore selection ---
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.90,
              height: MediaQuery.sizeOf(context).height * 0.20,
              child: ChoreDropdown(
                label: 'Chore',
                hintText: 'Select chore',
                selectedChoreId: _selectedChoreId,
                onChanged: (chore) =>
                    setState(() => _selectedChoreId = chore?.id),
              ),
            ),

            // --- Timer Display ---
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.9,
              height: MediaQuery.sizeOf(context).height * 0.2,
              child: TimerDisplay(
                controller: _timerCtrl,
                running: _timerRunning,
                startFrom: _elapsed,
                onTick: (d) => setState(() => _elapsed = d),
              ),
            ),

            // --- Control Buttons ---
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.9,
              height: MediaQuery.sizeOf(context).height * 0.2,
              child: TimerControlBar(
                onStart: _start,
                onCancel: _cancel,
                onDone: () => _done(context),
                onPause: _pause,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
