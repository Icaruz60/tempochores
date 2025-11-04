import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:tempochores_app/components/boxes.dart';
import 'package:tempochores_app/components/timer_control_bar.dart';
import 'package:tempochores_app/components/timer.dart';
import 'package:tempochores_app/theme/colors.dart';
import 'package:tempochores_app/components/chore_dropdown.dart';
import 'package:tempochores_app/models/chore.dart';

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

  void _handleStart() {
    setState(() {
      _timerRunning = true;
      _elapsed = Duration.zero;
    });
    _timerCtrl.reset(Duration.zero);
    _timerCtrl.start();
  }

  void _handleCancel() {
    setState(() {
      _timerRunning = false;
      _elapsed = Duration.zero;
    });
    _timerCtrl.reset(Duration.zero);
  }

  Future<void> _handleDone() async {
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

    final box = Boxes.chores();
    final chore = box.get(_selectedChoreId);

    if (chore != null) {
      chore.addTime(_elapsed);
      await chore.save();

      final mins = _elapsed.inMinutes;
      final secs = _elapsed.inSeconds % 60;

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Recorded ${mins}m ${secs}s for "${chore.name}"!',
              style: const TextStyle(fontSize: 16),
            ),
            backgroundColor: Colors.green[700],
            duration: const Duration(seconds: 2),
          ),
        );
      }

      setState(() {}); // Refresh manually if needed
    }
  }

  void _handlePause() {
    setState(() => _timerRunning = !_timerRunning);
    _timerCtrl.pause();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/TempoChoresLogo.png', height: 40),
            const SizedBox(width: 2),
            const Text('Time Chore'),
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
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.90,
              height: MediaQuery.sizeOf(context).height * 0.20,
              child: ChoreDropdown(
                label: 'Chore',
                hintText: 'Select chore',
                selectedChoreId: _selectedChoreId,
                onChanged: (chore) {
                  setState(() {
                    _selectedChoreId = chore?.id;
                  });
                },
              ),
            ), 
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.9,
              height: MediaQuery.sizeOf(context).height * 0.2,
              child: TimerDisplay(
                controller: _timerCtrl,
                running: _timerRunning,
                startFrom: _elapsed,
                onTick: (d) => _elapsed = d,
              ),
            ),
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.9,
              height: MediaQuery.sizeOf(context).height * 0.2,
              child: TimerControlBar(
                onStart: _handleStart,
                onCancel: _handleCancel,
                onDone: _handleDone,
                onPause: _handlePause,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
