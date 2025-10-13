import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:tempochores_app/components/boxes.dart';
import 'package:tempochores_app/models/chore.dart';
import 'package:tempochores_app/models/priority.dart';
import 'package:tempochores_app/theme/colors.dart';

class EditChoresPage extends StatefulWidget {
  const EditChoresPage({super.key});

  @override
  State<EditChoresPage> createState() => _EditChoresPageState();
}

class _EditChoresPageState extends State<EditChoresPage> {
  @override
  Widget build(BuildContext context) {
    final box = Boxes.chores();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/TempoChoresLogo.png', height: 40),
            const SizedBox(width: 8),
            const Text('Edit Chores'),
          ],
        ),
        centerTitle: true,
        foregroundColor: AppColors.secondary,
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, _, __) {
          final chores =
              box.values.toList()..sort((a, b) {
                int rank(Priority p) =>
                    p == Priority.high
                        ? 3
                        : p == Priority.medium
                        ? 2
                        : 1;
                final r = rank(b.priority).compareTo(rank(a.priority));
                return r != 0
                    ? r
                    : a.name.toLowerCase().compareTo(b.name.toLowerCase());
              });

          if (chores.isEmpty) {
            return const Center(
              child: Text('No chores yet. Tap the big + to add one.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 160),
            itemCount: chores.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final c = chores[i];

              return Dismissible(
                key: ValueKey(c.id),
                direction: DismissDirection.endToStart,
                background: _deleteBg(),
                confirmDismiss: (_) => _confirmDelete(context, c),
                onDismissed: (_) => box.delete(c.id),
                child: _ChoreTile(
                  chore: c,
                  onEdit: () => _showChoreDialog(context, existing: c),
                  onDelete: () async {
                    final ok = await _confirmDelete(context, c);
                    if (ok) await box.delete(c.id);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.large(
        backgroundColor: Colors.greenAccent.shade400,
        foregroundColor: Colors.black,
        elevation: 5,
        onPressed: () => _showChoreDialog(context),
        child: const Icon(Icons.add, size: 70),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _deleteBg() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.red.shade600,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.delete, color: Colors.white, size: 28),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, Chore c) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text('Delete chore?'),
                content: Text('Remove "${c.name}" permanently?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton.tonal(
                    onPressed: () => Navigator.pop(context, true),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Delete'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  Future<void> _showChoreDialog(BuildContext context, {Chore? existing}) async {
    final box = Boxes.chores();

    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    var priority = existing?.priority ?? Priority.medium;

    await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(existing == null ? 'Add Chore' : 'Edit Chore'),
            content: SizedBox(
              width: 380,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(labelText: 'Chore name'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<Priority>(
                    value: priority,
                    decoration: const InputDecoration(labelText: 'Priority'),
                    items:
                        Priority.values
                            .map(
                              (p) => DropdownMenuItem(
                                value: p,
                                child: Text(
                                  p.name[0].toUpperCase() + p.name.substring(1),
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (p) => priority = p ?? priority,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  final name = nameCtrl.text.trim();
                  if (name.isEmpty) return;

                  if (existing == null) {
                    // create
                    final id = DateTime.now().microsecondsSinceEpoch.toString();
                    await box.put(
                      id,
                      Chore(id: id, name: name, priority: priority),
                    );
                  } else {
                    // update
                    existing
                      ..name = name
                      ..priority = priority;
                    await existing.save();
                  }

                  if (context.mounted) Navigator.pop(context);
                },
                child: Text(existing == null ? 'Add' : 'Save'),
              ),
            ],
          ),
    );
  }
}

class _ChoreTile extends StatelessWidget {
  const _ChoreTile({
    required this.chore,
    required this.onEdit,
    required this.onDelete,
  });

  final Chore chore;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final avg = Duration(seconds: chore.avgSeconds);
    final subtitle =
        chore.timesSeconds.isEmpty
            ? 'no runs yet'
            : 'avg ${_mmss(avg)} • ${chore.timesSeconds.length} runs';

    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(5),
      elevation: 5,
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),

          child: Row(
            children: [
              _PriorityPill(priority: chore.priority),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chore.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.secondary,
                        shadows: [
                          Shadow(
                            offset: Offset(3, 3),
                            blurRadius: 15,
                            color: Colors.black54,
                          ),
                          Shadow(
                            offset: Offset(-3, -3),
                            blurRadius: 15,
                            color: Colors.black54,
                          ),
                          Shadow(
                            offset: Offset(3, -3),
                            blurRadius: 15,
                            color: Colors.black54,
                          ),
                          Shadow(
                            offset: Offset(-3, 3),
                            blurRadius: 15,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        shadows: [
                          Shadow(
                            offset: Offset(3, 3),
                            blurRadius: 15,
                            color: Colors.black54,
                          ),
                          Shadow(
                            offset: Offset(-3, -3),
                            blurRadius: 15,
                            color: Colors.black54,
                          ),
                          Shadow(
                            offset: Offset(3, -3),
                            blurRadius: 15,
                            color: Colors.black54,
                          ),
                          Shadow(
                            offset: Offset(-3, 3),
                            blurRadius: 15,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  size: 32,
                  shadows: [
                    Shadow(
                      offset: Offset(3, 3),
                      blurRadius: 15,
                      color: Colors.black54,
                    ),
                    Shadow(
                      offset: Offset(-3, -3),
                      blurRadius: 15,
                      color: Colors.black54,
                    ),
                    Shadow(
                      offset: Offset(3, -3),
                      blurRadius: 15,
                      color: Colors.black54,
                    ),
                    Shadow(
                      offset: Offset(-3, 3),
                      blurRadius: 15,
                      color: Colors.black54,
                    ),
                  ],
                ),
                color: Colors.red.shade600,
                onPressed: onDelete,
                tooltip: 'Delete',
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _mmss(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '${m}m${s.toString().padLeft(2, '0')}s';
  }
}

class _PriorityPill extends StatelessWidget {
  const _PriorityPill({required this.priority});
  final Priority priority;

  @override
  Widget build(BuildContext context) {
    final label = switch (priority) {
      Priority.high => 'High',
      Priority.medium => 'Med',
      Priority.low => 'Low',
    };

    final color = switch (priority) {
      Priority.high => Colors.redAccent,
      Priority.medium => Colors.orangeAccent,
      Priority.low => Colors.greenAccent,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          shadows: [
            Shadow(offset: Offset(3, 3), blurRadius: 15, color: Colors.black54),
            Shadow(
              offset: Offset(-3, -3),
              blurRadius: 15,
              color: Colors.black54,
            ),
            Shadow(
              offset: Offset(3, -3),
              blurRadius: 15,
              color: Colors.black54,
            ),
            Shadow(
              offset: Offset(-3, 3),
              blurRadius: 15,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
}
