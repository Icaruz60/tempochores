import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:tempochores_app/models/chore.dart';
import 'package:tempochores_app/pages/plan_tempochore_page.dart';
import 'package:tempochores_app/theme/colors.dart'; // ✅ for AppColors.secondary

class DueChoresPage extends StatefulWidget {
  const DueChoresPage({super.key});

  @override
  State<DueChoresPage> createState() => _DueChoresPageState();
}

class _DueChoresPageState extends State<DueChoresPage> {
  Set<String> _selectedIds = {};
  List<Chore> _allChores = [];

  @override
  void initState() {
    super.initState();
    _loadChores();
  }

  void _loadChores() {
    final choresBox = Hive.box<Chore>('chores');
    final storedSelected = Hive.box('settings').get('selectedChores') ?? [];
    setState(() {
      _allChores = choresBox.values.toList();
      _selectedIds = Set<String>.from(storedSelected);
      _sortChores();
    });
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
      _sortChores();
    });

    Hive.box('settings').put('selectedChores', _selectedIds.toList());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.secondary,
        duration: const Duration(milliseconds: 600),
        content: Text(
          _selectedIds.contains(id)
              ? 'Marked as due'
              : 'Removed from due list',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _sortChores() {
    _allChores.sort((a, b) {
      final aSelected = _selectedIds.contains(a.id);
      final bSelected = _selectedIds.contains(b.id);
      if (aSelected == bSelected) return 0;
      return aSelected ? 1 : -1;
    });
  }

  void _goToPlanningPage() {
    Hive.box('settings').put('selectedChores', _selectedIds.toList());
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PlanTempoChorePage()),
    );
  }

  void _clearSelections() {
    setState(() {
      _selectedIds.clear();
      _sortChores();
    });
    Hive.box('settings').put('selectedChores', []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/TempoChoresLogo.png', height: 40),
            const SizedBox(width: 8),
            const Text('Due Chores'),
          ],
        ),
        centerTitle: true,
        foregroundColor: AppColors.secondary,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 5,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _allChores.length,
              itemBuilder: (context, index) {
                final chore = _allChores[index];
                final isSelected = _selectedIds.contains(chore.id);

                return Card(
                  color: Theme.of(context).colorScheme.surface,
                  elevation: 5,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    title: Text(
                      chore.name.isEmpty ? '(Unnamed chore)' : chore.name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.grey.shade600
                            : AppColors.secondary,
                        decoration:
                            isSelected ? TextDecoration.lineThrough : null,
                        fontSize: 18,
                        fontWeight:
                            isSelected ? FontWeight.w400 : FontWeight.w600,
                        shadows: const [
                          Shadow(offset: Offset(3, 3), blurRadius: 15, color: Colors.black54),
                          Shadow(offset: Offset(-3, -3), blurRadius: 15, color: Colors.black54),
                          Shadow(offset: Offset(3, -3), blurRadius: 15, color: Colors.black54),
                          Shadow(offset: Offset(-3, 3), blurRadius: 15, color: Colors.black54),
                        ],
                      ),
                    ),
                    subtitle: chore.avgSeconds > 0
                        ? Text(
                            'Avg: ${chore.averageDuration.inMinutes} min',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              shadows: const [
                                Shadow(offset: Offset(3, 3), blurRadius: 15, color: Colors.black54),
                                Shadow(offset: Offset(-3, -3), blurRadius: 15, color: Colors.black54),
                                Shadow(offset: Offset(3, -3), blurRadius: 15, color: Colors.black54),
                                Shadow(offset: Offset(-3, 3), blurRadius: 15, color: Colors.black54),
                              ],
                            ),
                          )
                        : null,
                    trailing: Icon(
                      isSelected ? Icons.check_circle : Icons.circle_outlined,
                      color: isSelected
                          ? Colors.greenAccent.shade400
                          : Colors.grey.shade400,
                      size: 30,
                      shadows: const [
                        Shadow(offset: Offset(3, 3), blurRadius: 15, color: Colors.black54),
                        Shadow(offset: Offset(-3, -3), blurRadius: 15, color: Colors.black54),
                        Shadow(offset: Offset(3, -3), blurRadius: 15, color: Colors.black54),
                        Shadow(offset: Offset(-3, 3), blurRadius: 15, color: Colors.black54),
                      ],
                    ),
                    onTap: () => _toggleSelection(chore.id),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: FilledButton.icon(
              onPressed: _selectedIds.isEmpty ? null : _goToPlanningPage,
              icon: const Icon(Icons.arrow_forward, size: 26),
              label: const Text(
                'Next → Plan Tempo Chore',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.greenAccent.shade400,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 55),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedIds.isNotEmpty
          ? FloatingActionButton(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              onPressed: _clearSelections,
              tooltip: 'Clear Selections',
              child: const Icon(Icons.refresh, size: 32),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
