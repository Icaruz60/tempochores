import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tempochores_app/data/chore_repository.dart';
import 'package:tempochores_app/theme/colors.dart';
import 'package:tempochores_app/components/timer.dart';
import 'package:tempochores_app/components/timer_control_bar.dart';
import 'package:tempochores_app/components/chores_selector.dart';
import 'package:tempochores_app/models/chore.dart';

class TimeChorePage extends StatefulWidget {
  const TimeChorePage({super.key});

  @override
  State<TimeChorePage> createState() => _TimeChorePageState();
}

class _TimeChorePageState extends State<TimeChorePage> {
  Set<String> _selectedIds = {};
  final Set<String> _completedIds = {};
  bool _timerRunning = false;
  Duration _elapsed = Duration.zero;
  Duration _lastMark = Duration.zero;
  final TimerController _timerCtrl = TimerController();

  void _start() {
    setState(() {
      _timerRunning = true;
      _elapsed = Duration.zero;
      _lastMark = Duration.zero;
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
      _lastMark = Duration.zero;
    });
    _timerCtrl.reset(Duration.zero);
  }

  Future<void> _done(BuildContext context) async {
    setState(() => _timerRunning = false);
    _timerCtrl.pause();

    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No chores were selected.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stopped timing. ${_selectedIds.length} chores selected.'),
          backgroundColor: Colors.green[700],
          duration: const Duration(seconds: 2),
        ),
      );
    }

    setState(() {
      _elapsed = Duration.zero;
      _lastMark = Duration.zero;
      _selectedIds = {};
      _completedIds.clear();
    });
  }


  @override
  Widget build(BuildContext context) {
    final repo = context.read<ChoreRepository>();

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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                // Dropdown-style opener
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Chores',
                    hintText: 'Select chores',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                  child: InkWell(
                    onTap: () async {
                      final items = repo.getAll();
                      Set<String> local = Set.from(_selectedIds);

                      final result = await showDialog<Set<String>>(
                        context: context,
                        builder: (ctx) => StatefulBuilder(
                          builder: (ctx2, setStateDialog) => AlertDialog(
                            title: const Text('Select chores'),
                            content: SizedBox(
                              width: double.maxFinite,
                              height: MediaQuery.of(ctx2).size.height * 0.6,
                              child: ChoresSelector(
                                items: items,
                                selectedIds: local,
                                showSearch: true,
                                autoRecordTime: false,
                                onChanged: (next) => setStateDialog(() => local = next),
                              ),
                            ),
                            actions: [
                              TextButton(onPressed: () => Navigator.of(ctx2).pop(null), child: const Text('Cancel')),
                              TextButton(onPressed: () => Navigator.of(ctx2).pop(local), child: const Text('Done')),
                            ],
                          ),
                        ),
                      );

                      if (result != null) setState(() => _selectedIds = result);
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(_selectedIds.isEmpty ? 'Tap to select chores' : '${_selectedIds.length} selected',
                              style: Theme.of(context).textTheme.bodyMedium),
                        ),
                        const Icon(Icons.keyboard_arrow_down_rounded),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Selected list area
                Expanded(
                  child: Builder(builder: (ctx) {
                    try {
                      final selectedList = _selectedIds.map((id) => repo.getById(id)).whereType<Chore>().toList();

                      if (selectedList.isEmpty) {
                        return Center(
                          child: Text('No chores selected.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        itemCount: selectedList.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 6),
                        itemBuilder: (context, index) {
                          final chore = selectedList[index];
                          final isCompleted = _completedIds.contains(chore.id);

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Material(
                              elevation: 5,
                              borderRadius: BorderRadius.circular(8),
                              shadowColor: Colors.black54,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () async {
                                  if (isCompleted) return;

                                  if (!_timerRunning) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                      content: Text('Start the timer before recording a chore.'),
                                      backgroundColor: Colors.orangeAccent,
                                      duration: Duration(seconds: 2),
                                    ));
                                    return;
                                  }

                                  final delta = _elapsed - _lastMark;
                                  if (delta <= Duration.zero) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                      content: Text('Wait a moment before recording the next chore.'),
                                      backgroundColor: Colors.orangeAccent,
                                      duration: Duration(seconds: 2),
                                    ));
                                    return;
                                  }

                                  final messenger = ScaffoldMessenger.of(context);
                                  final wasMounted = mounted;
                                  await repo.addTime(chore.id, delta);

                                  if (wasMounted) {
                                    messenger.showSnackBar(SnackBar(
                                      content: Text('Recorded ${delta.inMinutes}m ${delta.inSeconds % 60}s for "${chore.name}"'),
                                      backgroundColor: Colors.green[700],
                                      duration: const Duration(seconds: 2),
                                    ));
                                  }

                                  setState(() {
                                    _completedIds.add(chore.id);
                                    _lastMark = _elapsed;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(isCompleted ? Icons.check_circle : Icons.circle_outlined,
                                          color: isCompleted ? Colors.greenAccent.shade400 : Colors.grey.shade400, size: 30),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(chore.name.isEmpty ? '(Unnamed chore)' : chore.name,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: TextStyle(
                                                  color: isCompleted ? Colors.grey.shade500 : AppColors.secondary,
                                                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w600,
                                                  shadows: const [Shadow(offset: Offset(3, 3), blurRadius: 15, color: Colors.black54)],
                                                )),
                                            if (chore.avgSeconds > 0)
                                              Text('avg ${chore.averageDuration.inMinutes}m ${chore.averageDuration.inSeconds % 60}s',
                                                  style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    } catch (e, st) {
                      debugPrint('Error building selected list: $e\n$st');
                      return Center(child: Text('Error showing selected chores: $e'));
                    }
                  }),
                ),

                const SizedBox(height: 12),

                // Timer display
                SizedBox(
                  height: 64,
                  child: Align(
                    alignment: Alignment.center,
                    child: TimerDisplay(
                      controller: _timerCtrl,
                      running: _timerRunning,
                      startFrom: _elapsed,
                      onTick: (d) => setState(() => _elapsed = d),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Controls
                TimerControlBar(onStart: _start, onCancel: _cancel, onDone: () => _done(context), onPause: _pause),
              ],
            ),
          ),
        ),
    );
  }
}
