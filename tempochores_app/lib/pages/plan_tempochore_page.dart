import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:tempochores_app/models/chore.dart';
import 'package:tempochores_app/providers/timer_provider.dart';
import 'package:tempochores_app/data/chore_repository.dart';
import 'package:tempochores_app/data/settings_repository.dart';
import 'package:tempochores_app/theme/colors.dart';
import 'package:tempochores_app/components/time_slider.dart';

class PlanTempoChorePage extends StatefulWidget {
  const PlanTempoChorePage({super.key});

  @override
  State<PlanTempoChorePage> createState() => _PlanTempoChorePageState();
}

class _PlanTempoChorePageState extends State<PlanTempoChorePage> {
  int _minutes = 0;
  String _selectedFilter = 'Mixed Chores';
  bool _timerRunning = false;
  late ConfettiController _confetti;

  List<Chore> _planned = [];
  final Set<String> _completed = {};

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }


  void _generatePlan(BuildContext context) {
    final repo = context.read<ChoreRepository>();
    final settings = context.read<SettingsRepository>();

    final selectedIds = settings.selectedChores;
    final selectedChores =
        repo.getAll().where((c) => selectedIds.contains(c.id)).toList();

    if (_minutes == 0 || selectedChores.isEmpty) {
      setState(() => _planned = []);
      return;
    }

    final plan = repo.planChores(
      Duration(minutes: _minutes),
      filter: _selectedFilter,
      source: selectedChores, // only plan from selected chores
    );


    setState(() {
      _planned = plan;
      _completed.clear();
    });
  }

  void _startTempo(BuildContext context) {
    final timer = context.read<TimerProvider>();
    timer.start(_minutes, _planned);
    timer.resetCompletionTracking();
    setState(() => _timerRunning = true);
  }

  Future<void> _endTempo({bool success = false}) async {
    final timer = context.read<TimerProvider>();
    final settings = context.read<SettingsRepository>();

    timer.stop();
    await settings.clearSelections();

    if (!mounted) return; 

    if (success) _confetti.play();

    final message = success
        ? 'All chores completed in ${timer.elapsed.inMinutes}m '
          '${(timer.elapsed.inSeconds % 60).toString().padLeft(2, '0')}s!'
        : 'TempoChore session ended early.';

    _showDialog(
      context,
      success ? '🎉 Completed!' : '🛑 Ended',
      message,
    );

    setState(() {
      _timerRunning = false;
      _completed.clear();
      _planned.clear();
      _minutes = 0;
      _selectedFilter = 'Mixed Chores';
    });
  }

  void _completeChore(Chore chore) {
    if (_completed.contains(chore.id)) return;

    final timer = context.read<TimerProvider>();
    timer.completeChore(chore);
    setState(() => _completed.add(chore.id));

    final diff = timer.consumeElapsed();
    final m = diff.inMinutes;
    final s = diff.inSeconds % 60;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Recorded ${m}m ${s}s for "${chore.name}"'),
        backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 2),
      ),
    );

    
    if (_completed.length == _planned.length && _planned.isNotEmpty) {
      _endTempo(success: true);
    }
  }


  void _showDialog(BuildContext ctx, String title, String message) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text(title, textAlign: TextAlign.center),
        content: Text(message, textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () {
              _confetti.stop();
              Navigator.of(ctx).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
      body: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 30,
              gravity: 0.4,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              children: [
                if (!_timerRunning)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('I have ', style: TextStyle(fontSize: 26)),
                      TimeSlider(
                        initialValue: _minutes,
                        onChanged: (v) {
                          setState(() => _minutes = v);
                          _generatePlan(context);
                        },
                      ),
                      const Text(' minutes', style: TextStyle(fontSize: 26)),
                    ],
                  )
                else
                  Text(
                    'Tempo Session Active',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                const SizedBox(height: 12),
                if (_timerRunning)
                  Column(
                    children: [
                      Text(
                        '${timer.remaining.inMinutes}:${(timer.remaining.inSeconds % 60).toString().padLeft(2, '0')} left',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_completed.length} of ${_planned.length} chores done',
                        style: const TextStyle(
                            fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),

                Expanded(
                  child: _planned.isEmpty
                      ? const Center(
                          child: Text(
                            'No chores fit that time.',
                            style: TextStyle(
                              fontSize: 20,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _planned.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            final chore = _planned[i];
                            final done = _completed.contains(chore.id);

                            return Material(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(5),
                              elevation: 5,
                              child: ListTile(
                                title: Text(
                                  chore.name,
                                  style: TextStyle(
                                    color: done
                                        ? Colors.grey
                                        : AppColors.secondary,
                                    decoration: done
                                        ? TextDecoration.lineThrough
                                        : null,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  'avg ${chore.averageDuration.inMinutes}m '
                                  '${chore.averageDuration.inSeconds % 60}s',
                                  style: TextStyle(
                                    color: done
                                        ? Colors.grey
                                        : Colors.grey[600],
                                  ),
                                ),
                                trailing: _timerRunning
                                    ? Checkbox(
                                        value: done,
                                        onChanged: done
                                            ? null
                                            : (_) => _completeChore(chore),
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                ),

                // --- Controls ---
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (!_timerRunning)
                        DropdownMenu<String>(
                          initialSelection: _selectedFilter,
                          dropdownMenuEntries: const [
                            DropdownMenuEntry(
                                value: 'Longest Chores',
                                label: 'Longest Chores'),
                            DropdownMenuEntry(
                                value: 'Shortest Chores',
                                label: 'Shortest Chores'),
                            DropdownMenuEntry(
                                value: 'Mixed Chores', label: 'Mixed Chores'),
                          ],
                          onSelected: (v) {
                            if (v != null) {
                              setState(() => _selectedFilter = v);
                              _generatePlan(context);
                            }
                          },
                          menuHeight: 150,
                          textStyle:
                              const TextStyle(color: Colors.white),
                        ),
                      if (!_timerRunning)
                        ElevatedButton(
                          onPressed: _planned.isNotEmpty
                              ? () => _startTempo(context)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.greenAccent.shade400,
                            foregroundColor: Colors.black,
                            minimumSize: const Size(140, 55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Go!',
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold)),
                        ),
                      if (_timerRunning)
                        ElevatedButton(
                          onPressed: _endTempo, 
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(180, 55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('End TempoChore',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
