import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tempochores_app/models/chore.dart';
import 'package:tempochores_app/data/chore_repository.dart';
import 'package:tempochores_app/theme/colors.dart';

class EditChoresPage extends StatefulWidget {
  const EditChoresPage({super.key});

  @override
  State<EditChoresPage> createState() => _EditChoresPageState();
}

class _EditChoresPageState extends State<EditChoresPage> {
  @override
  Widget build(BuildContext context) {
    final repo = context.read<ChoreRepository>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit_note_rounded, color: AppColors.secondary, size: 40),
            const SizedBox(width: 8),
            const Text('Edit Chores'),
          ],
        ),
        centerTitle: true,
        foregroundColor: AppColors.secondary,
      ),
      body: StreamBuilder(
        stream: repo.watch(),
        builder: (context, snapshot) {
          final chores = repo.getAll();

          if (chores.isEmpty) {
            return const Center(
              child: Text('No chores yet. Tap the + button to add one.'),
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
                onDismissed: (_) => repo.delete(c.id),
                child: _ChoreTile(
                  chore: c,
                  onEdit: () => _showChoreDialog(context, repo, existing: c),
                  onDelete: () async {
                    final ok = await _confirmDelete(context, c);
                    if (ok) await repo.delete(c.id);
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
        onPressed: () => _showChoreDialog(context, repo),
        child: const Icon(Icons.add, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _deleteBg() => Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      );

  Future<bool> _confirmDelete(BuildContext context, Chore c) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
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

  Future<void> _showChoreDialog(
    BuildContext context,
    ChoreRepository repo, {
    Chore? existing,
  }) async {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(existing == null ? 'Add Chore' : 'Edit Chore'),
              content: SizedBox(
                width: 380,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(labelText: 'Chore name'),
                    ),
                    const SizedBox(height: 16),

                    if (existing != null && existing.timesSeconds.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Recorded Times:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 200),
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: existing.timesSeconds.length,
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final t = existing.timesSeconds[index];
                                final dur = Duration(seconds: t);
                                final formatted =
                                    '${dur.inMinutes}m ${(dur.inSeconds % 60).toString().padLeft(2, '0')}s';

                                return ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(formatted),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    tooltip: 'Delete this time',
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                              title: const Text('Delete Time?'),
                                              content: Text('Remove this recorded time ($formatted)?'),
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

                                      if (confirm) {
                                        existing.removeTimeAt(index);
                                        await repo.upsert(existing);
                                        setStateDialog(() {});
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
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
                      await repo.create(name);
                    } else {
                      existing.name = name;
                      await repo.upsert(existing);
                    }

                    if (context.mounted) Navigator.pop(context);
                  },
                  child: Text(existing == null ? 'Add' : 'Save'),
                ),
              ],
            );
          },
        );
      },
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
    final avg = chore.averageDuration;
    final subtitle = chore.timesSeconds.isEmpty
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chore.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.secondary,
                            fontSize: 20,
                            shadows: const [
                              Shadow(offset: Offset(3, 3), blurRadius: 15, color: Colors.black54),
                            ],
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 32),
                color: Colors.red.shade600,
                onPressed: onDelete,
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
    return '${m}m ${s.toString().padLeft(2, '0')}s';
  }
}
