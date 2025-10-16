import 'package:flutter/material.dart';
import 'package:tempochores_app/components/boxes.dart';
import 'package:tempochores_app/components/timer_control_bar.dart';
import 'package:tempochores_app/components/timer.dart';
import 'package:tempochores_app/theme/colors.dart';
import 'package:tempochores_app/components/chore_dropdown.dart';

class TimeChorePage extends StatefulWidget {
  const TimeChorePage({super.key});

  @override
  State<TimeChorePage> createState() => _TimeChorePageState();
}

class _TimeChorePageState extends State<TimeChorePage> {
  String? _selectedChoreId;

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
            SizedBox(height: 30),
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
                  // do whatever else you need with the Chore
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
                onStart: () {
                  setState(() {
                    _timerRunning = true;
                    _elapsed = Duration.zero;
                  });
                  _timerCtrl.reset(Duration.zero);
                  _timerCtrl.start();
                },
                onCancel: () {
                  setState(() {
                    _timerRunning = false;
                    _elapsed = Duration.zero;
                    _timerCtrl.reset(Duration.zero);
                  });
                },
                onDone: () async {
                  setState(() => _timerRunning = false);
                  _timerCtrl.pause();
                  final box = Boxes.chores();
                  final chore = box.get(
                    _selectedChoreId,
                  ); // or however you fetch it
                  chore?.addTime(_elapsed);
                },
                onPause: () {
                  setState(() => _timerRunning = _timerRunning ? false : true);
                  _timerCtrl.pause();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

late final TimerController _timerCtrl = TimerController();
bool _timerRunning = false;
Duration _elapsed = Duration.zero;
