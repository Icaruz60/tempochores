import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:tempochores_app/models/chore.dart';
import 'package:tempochores_app/models/priority.dart';
import 'package:tempochores_app/providers/timer_provider.dart';
import 'package:tempochores_app/theme/colors.dart';
import 'package:tempochores_app/components/chores_selector.dart';
import 'package:tempochores_app/components/time_slider.dart';

class PlanTempoChorePage extends StatefulWidget {
  const PlanTempoChorePage({super.key});

  @override
  State<PlanTempoChorePage> createState() => _PlanTempoChorePageState();
}

class _PlanTempoChorePageState extends State<PlanTempoChorePage> {
  int minutes = 0;
  bool _timerRunning = false;
  bool _hasLoaded = false;

  Set<String> _selectedIds = {};
  List<Chore> _allChores = [];
  List<Chore> _displayChores = [];

  @override
  void initState() {
    super.initState();
    _loadAllChores();
  }

  void _loadAllChores() {
    final box = Hive.box<Chore>('chores');
    final chores = box.values.toList();

    chores.sort((a, b) {
      final pComp = b.priority.index.compareTo(a.priority.index);
      if (pComp != 0) return pComp;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    setState(() {
      _allChores = chores;
      _displayChores = chores;
      _selectedIds.clear();
      _timerRunning = false;
      _hasLoaded = false;
      minutes = 0;
    });
  }

  void _loadChores() {
    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select chores first.')),
      );
      return;
    }

    final selected = _allChores
        .where((c) => _selectedIds.contains(c.id))
        .toList();

    selected.sort((a, b) => b.priority.index.compareTo(a.priority.index));

    final high = selected.where((c) => c.priority == Priority.high).toList();
    final med = selected.where((c) => c.priority == Priority.medium).toList();
    final low = selected.where((c) => c.priority == Priority.low).toList();

    for (final list in [high, med, low]) {
      list.sort((a, b) => a.averageDuration.compareTo(b.averageDuration));
    }

    List<Chore> chosen = [];
    var remaining = Duration(minutes: minutes);

    for (final c in [...high, ...med, ...low]) {
      final dur = c.averageDuration;
      if (dur.inSeconds > 0 && dur <= remaining) {
        chosen.add(c);
        remaining -= dur;
      }
    }

    if (chosen.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No chores fit in that time window.')),
      );
      return;
    }

    setState(() {
      _displayChores = chosen;
      _hasLoaded = true;
      _selectedIds.clear();
    });
  }

  void _startTimer(BuildContext context) {
    final timer = context.read<TimerProvider>();
    timer.start(minutes);
    timer.resetCompletionTracking();
    setState(() => _timerRunning = true);

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));

      if (_selectedIds.length == _displayChores.length &&
          _displayChores.isNotEmpty) {
        timer.stop();
        timer.resetCompletionTracking();

        if (context.mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('TempoChore Complete!'),
              content: const Text('You finished all your chores within the time limit!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _resetAll();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
        return false;
      }

      // stop loop if time runs out
      if (!timer.running && timer.remaining == Duration.zero) {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Time’s up!'),
              content: const Text('You ran out of time. Try again next session!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _resetAll();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
        return false;
      }

      return true;
    });
  }

  void _resetAll() {
    final timer = context.read<TimerProvider>();
    timer.stop();
    timer.resetCompletionTracking();
    _loadAllChores();
  }

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<TimerProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/TempoChoresLogo.png', height: 40),
            const SizedBox(width: 8),
            const Text('Plan TempoChore'),
          ],
        ),
        centerTitle: true,
        foregroundColor: AppColors.secondary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // TIME SLIDER
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.9,
              height: MediaQuery.sizeOf(context).height * 0.15,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'I have ',
                    style: TextStyle(
                      fontSize: 30,
                      shadows: [
                        Shadow(offset: Offset(3, 3), blurRadius: 5, color: Colors.black54),
                        Shadow(offset: Offset(-3, -3), blurRadius: 5, color: Colors.black54),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IgnorePointer(
                    ignoring: _timerRunning,
                    child: Opacity(
                      opacity: _timerRunning ? 0.5 : 1,
                      child: TimeSlider(
                        initialValue: minutes,
                        onChanged: (v) => setState(() => minutes = v),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    ' minutes',
                    style: TextStyle(
                      fontSize: 30,
                      shadows: [
                        Shadow(offset: Offset(3, 3), blurRadius: 5, color: Colors.black54),
                        Shadow(offset: Offset(-3, -3), blurRadius: 5, color: Colors.black54),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // TIMER DISPLAY
            Text(
              timer.running
                  ? '${timer.remaining.inMinutes}:${(timer.remaining.inSeconds % 60).toString().padLeft(2, '0')} left'
                  : (timer.remaining > Duration.zero
                      ? ''
                      : 'Timer stopped'),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            // CHORES LIST
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.9,
              height: MediaQuery.sizeOf(context).height * 0.4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_hasLoaded
                      ? 'Chores for this session:'
                      : 'Select chores to consider:'),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ChoresSelector(
                      items: _displayChores,
                      selectedIds: _selectedIds,
                      onChanged: (ids) => setState(() => _selectedIds = ids),
                      showSearch: true,
                      emptyLabel: 'No chores available',
                      title: 'Available chores',
                    ),
                  ),
                ],
              ),
            ),

            // ACTION BUTTONS
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (!_timerRunning && !_hasLoaded)
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        height: MediaQuery.sizeOf(context).height * 0.08,
                        child: ElevatedButton(
                          onPressed: _loadChores,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 6,
                          ),
                          child: const Text(
                            'Load',
                            style: TextStyle(
                              fontSize: 22,
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (!_timerRunning)
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        height: MediaQuery.sizeOf(context).height * 0.08,
                        child: ElevatedButton(
                          onPressed: _displayChores.isNotEmpty
                              ? () => _startTimer(context)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _displayChores.isNotEmpty
                                ? AppColors.primary
                                : Colors.grey[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 6,
                          ),
                          child: Text(
                            'Go!',
                            style: TextStyle(
                              fontSize: 22,
                              color: _displayChores.isNotEmpty
                                  ? AppColors.secondary
                                  : Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        height: MediaQuery.sizeOf(context).height * 0.08,
                        child: ElevatedButton(
                          onPressed: _resetAll,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 6,
                          ),
                          child: const Text(
                            'Reset',
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
