import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:tempochores_app/models/chore.dart';
import 'package:tempochores_app/providers/timer_provider.dart';
import 'package:tempochores_app/theme/colors.dart';
import 'package:tempochores_app/components/time_slider.dart';
import 'package:tempochores_app/data/chore_repository.dart';
import 'package:tempochores_app/pages/due_chores_page.dart';

class PlanTempoChorePage extends StatefulWidget {
  const PlanTempoChorePage({super.key});

  @override
  State<PlanTempoChorePage> createState() => _PlanTempoChorePageState();
}

class _PlanTempoChorePageState extends State<PlanTempoChorePage> {
  int minutes = 0;
  List<Chore> _dueChores = [];
  List<Chore> _plannedChores = [];
  late ConfettiController _confettiController;
  late StreamSubscription _watcher;

  final _repo = ChoreRepository();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _loadSelectedChores();

    final settingsBox = Hive.box('settings');
    _watcher = settingsBox.watch(key: 'selectedChores').listen((_) {
      _loadSelectedChores();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _watcher.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  void _loadSelectedChores() {
    final choresBox = Hive.box<Chore>('chores');
    final selectedIds = Hive.box('settings').get('selectedChores') ?? [];
    setState(() {
      _dueChores = choresBox.values
          .where((c) => selectedIds.contains(c.id))
          .toList();
      _plannedChores = [];
    });
  }

  void _planChoresForTime(int minutes) {
    final available = Duration(seconds: minutes * 60);
    final prioritized = _repo.getPrioritizedChores(available);
    final planned = prioritized
        .where((c) => _dueChores.any((d) => d.id == c.id))
        .toList();

    setState(() => _plannedChores = planned);
  }

  void _completeChore(TimerProvider timer, Chore chore) {
    if (timer.completedIds.contains(chore.id)) return;
    timer.completeChore(chore);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.secondary,
        content: Text(
          '✅ ${chore.name} completed!',
          style: const TextStyle(color: Colors.white),
        ),
        duration: const Duration(seconds: 1),
      ),
    );

    if (timer.completedIds.length == timer.plannedIds.length) {
      _triggerCelebration(timer);
    }
  }

  Future<void> _triggerCelebration(TimerProvider timer) async {
    timer.stop();
    _confettiController.play();

    final completedIds = List<String>.from(timer.plannedIds);
    final settingsBox = Hive.box('settings');
    final currentSelected =
        List<String>.from(settingsBox.get('selectedChores', defaultValue: []));
    currentSelected.removeWhere((id) => completedIds.contains(id));
    await settingsBox.put('selectedChores', currentSelected);

    if (!mounted) return;

    setState(() {
      _plannedChores.clear();
      _dueChores.removeWhere((c) => completedIds.contains(c.id));
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          "🎉 All Chores Done!",
          textAlign: TextAlign.center,
        ),
        content: const Text(
          "You finished your Tempo session with time to spare! 👏",
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () {
              _confettiController.stop();
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.greenAccent.shade400,
              foregroundColor: Colors.black,
            ),
            child: const Text("Nice!"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timer = Provider.of<TimerProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        centerTitle: true,
        foregroundColor: AppColors.secondary,
        elevation: 5,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/TempoChoresLogo.png', height: 40),
            const SizedBox(width: 8),
            const Text('Plan Tempo Chore'),
          ],
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            emissionFrequency: 0.05,
            numberOfParticles: 25,
            maxBlastForce: 20,
            minBlastForce: 10,
            gravity: 0.2,
            colors: const [
              Colors.greenAccent,
              Colors.yellow,
              Colors.blueAccent,
              Colors.pinkAccent,
              Colors.orange,
            ],
          ),

          _dueChores.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    // Timer and slider
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            timer.running
                                ? 'Time Remaining'
                                : 'How much time do you have?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.secondary,
                              shadows: const [
                                Shadow(
                                    offset: Offset(3, 3),
                                    blurRadius: 15,
                                    color: Colors.black54),
                                Shadow(
                                    offset: Offset(-3, -3),
                                    blurRadius: 15,
                                    color: Colors.black54),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (timer.running)
                            Text(
                              "${timer.remaining.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(timer.remaining.inSeconds.remainder(60)).toString().padLeft(2, '0')}",
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.greenAccent,
                                shadows: [
                                  Shadow(
                                      offset: Offset(2, 2),
                                      blurRadius: 10,
                                      color: Colors.black54)
                                ],
                              ),
                            )
                          else
                            Column(
                              children: [
                                TimeSlider(
                                  initialValue: minutes,
                                  onChanged: (val) {
                                    _debounce?.cancel();
                                    _debounce = Timer(
                                        const Duration(milliseconds: 150), () {
                                      setState(() => minutes = val);
                                    });
                                  },
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Selected: $minutes minutes',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),

                    // Buttons
                    if (!timer.running)
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                icon: const Icon(Icons.tune),
                                label: const Text('Plan'),
                                onPressed: minutes > 0 && _dueChores.isNotEmpty
                                    ? () => _planChoresForTime(minutes)
                                    : null,
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.orangeAccent,
                                  foregroundColor: Colors.black,
                                  elevation: 5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: FilledButton.icon(
                                icon: const Icon(Icons.timer),
                                label: const Text('Start Timer'),
                                onPressed: minutes > 0 &&
                                        _plannedChores.isNotEmpty
                                    ? () => timer.start(minutes, _plannedChores)
                                    : null,
                                style: FilledButton.styleFrom(
                                  backgroundColor:
                                      Colors.greenAccent.shade400,
                                  foregroundColor: Colors.black,
                                  elevation: 5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 12),

                    // Chore list
                    Expanded(
                      child: ListView.builder(
                        itemCount: _plannedChores.length,
                        itemBuilder: (context, index) {
                          final chore = _plannedChores[index];
                          final isDone =
                              timer.completedIds.contains(chore.id);

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDone
                                  ? Colors.greenAccent.withValues(alpha: 0.2)
                                  : Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                    offset: Offset(3, 3),
                                    blurRadius: 15,
                                    color: Colors.black54),
                                BoxShadow(
                                    offset: Offset(-3, -3),
                                    blurRadius: 15,
                                    color: Colors.black54),
                              ],
                            ),
                            child: ListTile(
                              title: Text(
                                chore.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  decoration: isDone
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: isDone
                                      ? Colors.green.shade700
                                      : AppColors.secondary,
                                ),
                              ),
                              subtitle: Text(
                                'Avg: ${chore.averageDuration.inMinutes} min • ${chore.priority.name}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                              trailing: timer.running && !isDone
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.check_circle_outline,
                                        color: Colors.greenAccent,
                                      ),
                                      onPressed: () =>
                                          _completeChore(timer, chore),
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "No chores marked as due yet.",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DueChoresPage()),
              );
            },
            icon: const Icon(Icons.playlist_add),
            label: const Text("Select Due Chores"),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.greenAccent.shade400,
              foregroundColor: Colors.black,
              elevation: 5,
            ),
          ),
        ],
      ),
    );
  }
}
