import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tempochores_app/data/chore_repository.dart';
import 'package:tempochores_app/data/settings_repository.dart';
import 'package:tempochores_app/theme/colors.dart';

class DueChoresPage extends StatelessWidget {
  const DueChoresPage({super.key});

  @override
  Widget build(BuildContext context) {
    final choreRepo = context.read<ChoreRepository>();
    final settingsRepo = context.read<SettingsRepository>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: AppColors.secondary,
              size: 40,
            ),
            const SizedBox(width: 8),
            const Text('Due Chores'),
          ],
        ),
        centerTitle: true,
        foregroundColor: AppColors.secondary,
      ),
      body: ValueListenableBuilder(
        valueListenable: settingsRepo.listen(),
        builder: (context, _, __) {
          final selectedIds = settingsRepo.selectedChores;
          return ValueListenableBuilder(
            valueListenable: choreRepo.listen(),
            builder: (context, _, __) {
              final allChores =
                  choreRepo.getAll()..sort(
                    (a, b) =>
                        a.name.toLowerCase().compareTo(b.name.toLowerCase()),
                  );

              if (allChores.isEmpty) {
                return const Center(
                  child: Text(
                    'No chores available.\nAdd some from Edit Chores.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: allChores.length,
                itemBuilder: (context, index) {
                  final chore = allChores[index];
                  final isSelected = selectedIds.contains(chore.id);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Material(
                      elevation: 5,
                      borderRadius: BorderRadius.circular(8),
                      shadowColor: Colors.black54,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => settingsRepo.toggleChore(chore.id),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 18,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.check_circle
                                    : Icons.circle_outlined,
                                color:
                                    isSelected
                                        ? Colors.greenAccent.shade400
                                        : Colors.grey.shade400,
                                size: 30,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      chore.name.isEmpty
                                          ? '(Unnamed chore)'
                                          : chore.name,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                        color:
                                            isSelected
                                                ? Colors.grey.shade500
                                                : AppColors.secondary,
                                        decoration:
                                            isSelected
                                                ? TextDecoration.lineThrough
                                                : null,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        shadows: const [
                                          Shadow(
                                            offset: Offset(3, 3),
                                            blurRadius: 15,
                                            color: Colors.black54,
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (chore.avgSeconds > 0)
                                      Text(
                                        'avg ${chore.averageDuration.inMinutes}m '
                                        '${chore.averageDuration.inSeconds % 60}s',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ); 
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Consumer<SettingsRepository>(
        builder: (context, repo, _) {
          final hasSelections = repo.selectedChores.isNotEmpty;
          return hasSelections
              ? Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: FloatingActionButton(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  tooltip: 'Clear Selections',
                  onPressed: repo.clearSelections,
                  child: const Icon(Icons.refresh, size: 32),
                ),
              )
              : const SizedBox.shrink();
        },
      ),
    );
  }
}
