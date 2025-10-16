import 'package:flutter/material.dart';
import 'package:tempochores_app/models/chore.dart'; // adjust path if needed
import 'package:tempochores_app/models/priority.dart';

class ChoresSelector extends StatefulWidget {
  const ChoresSelector({
    super.key,
    required this.items,
    required this.selectedIds,
    required this.onChanged,
    this.showSearch = true,
    this.emptyLabel = 'No chores found',
    this.title = 'Select chores',
  });

  final List<Chore> items;
  final Set<String> selectedIds; // ids of selected chores
  final ValueChanged<Set<String>> onChanged; // emits ids
  final bool showSearch;
  final String emptyLabel;
  final String title;

  @override
  State<ChoresSelector> createState() => _ChoresSelectorState();
}

class _ChoresSelectorState extends State<ChoresSelector> {
  late final TextEditingController _searchCtrl;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl =
        TextEditingController()..addListener(() {
          setState(() => _query = _searchCtrl.text.trim().toLowerCase());
        });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered =
        _query.isEmpty
            ? widget.items
            : widget.items
                .where((c) => c.name.toLowerCase().contains(_query))
                .toList();

    final allIds = widget.items.map((c) => c.id).toSet();
    final selected = widget.selectedIds;

    return Column(
      children: [
        if (widget.showSearch)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search chores',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Text(
                '${selected.length} selected',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => widget.onChanged(allIds),
                icon: const Icon(Icons.done_all),
                label: const Text('Select all'),
              ),
              const SizedBox(width: 4),
              TextButton.icon(
                onPressed: () => widget.onChanged(<String>{}),
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear'),
              ),
            ],
          ),
        ),
        const Divider(height: 0),
        Expanded(
          child:
              filtered.isEmpty
                  ? Center(
                    child: Text(
                      widget.emptyLabel,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  )
                  : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 0),
                    itemBuilder: (context, index) {
                      final chore = filtered[index];
                      final isChecked = selected.contains(chore.id);

                      return CheckboxListTile(
                        value: isChecked,
                        onChanged: (checked) {
                          final next = Set<String>.from(selected);
                          if (checked == true) {
                            next.add(chore.id);
                          } else {
                            next.remove(chore.id);
                          }
                          widget.onChanged(next);
                        },
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                chore.name,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 20,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(3, 3),
                                      blurRadius: 5,
                                      color: Colors.black54,
                                    ),
                                    Shadow(
                                      offset: Offset(-3, -3),
                                      blurRadius: 5,
                                      color: Colors.black54,
                                    ),
                                    Shadow(
                                      offset: Offset(3, -3),
                                      blurRadius: 5,
                                      color: Colors.black54,
                                    ),
                                    Shadow(
                                      offset: Offset(-3, 3),
                                      blurRadius: 5,
                                      color: Colors.black54,
                                    ),
                                  ],
                                  fontWeight:
                                      isChecked
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _PriorityPill(priority: chore.priority),
                          ],
                        ),
                        subtitle: Text(
                          _fmtDurationShort(chore.averageDuration),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: Theme.of(context).hintColor),
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }
}

class _PriorityPill extends StatelessWidget {
  const _PriorityPill({required this.priority});
  final Priority priority;

  @override
  Widget build(BuildContext context) {
    final label = switch (priority) {
      Priority.low => 'Low',
      Priority.medium => 'Medium',
      Priority.high => 'High',
    };
    final color = switch (priority) {
      Priority.low => Colors.green,
      Priority.medium => Colors.orange,
      Priority.high => Colors.red,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: ShapeDecoration(
        color: color.withOpacity(0.12),
        shape: StadiumBorder(side: BorderSide(color: color.withOpacity(0.6))),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

String _fmtDurationShort(Duration d) {
  if (d.inSeconds <= 0) return 'no time recorded';
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  if (h >= 1) return '${h}h ${m}m avg';
  return '${m}m avg';
}
