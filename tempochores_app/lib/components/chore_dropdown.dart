// lib/components/chore_dropdown.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:tempochores_app/components/boxes.dart';
import 'package:tempochores_app/models/chore.dart';
import 'package:tempochores_app/models/priority.dart';
import 'package:tempochores_app/theme/colors.dart';

class ChoreDropdown extends StatelessWidget {
  const ChoreDropdown({
    super.key,
    this.label = 'Choose a chore',
    this.hintText = 'Select chore',
    this.selectedChoreId,
    required this.onChanged,
    this.enabled = true,
    this.showLabel = true, // turn off if you render your own header above
  });

  final String label;
  final String hintText;
  final String? selectedChoreId;
  final ValueChanged<Chore?> onChanged;
  final bool enabled;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final box = Boxes.chores();

    return ValueListenableBuilder(
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

        // resolve selection, auto-select first if nothing set
        Chore? selected;
        if (selectedChoreId != null) {
          selected = chores.where((c) => c.id == selectedChoreId).firstOrNull;
        }
        selected ??= chores.isNotEmpty ? chores.first : null;

        if (selectedChoreId == null && selected != null) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => onChanged(selected),
          );
        }

        final border = OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(
            color: AppColors.secondary.withOpacity(0.4),
            width: 1,
          ),
        );
        final focusedBorder = OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: AppColors.secondary, width: 1.6),
        );

        // empty state
        if (chores.isEmpty) {
          return InputDecorator(
            isFocused: false,
            isEmpty: true,
            decoration: InputDecoration(
              labelText: showLabel ? label : null,
              hintText: hintText,
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              enabled: false,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: border,
              enabledBorder: border,
              focusedBorder: focusedBorder,
            ),
            child: Text(
              'No chores available',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            ),
          );
        }

        // one decorator, no nesting
        final fieldKey = GlobalKey();
        return InputDecorator(
          isFocused: false,
          isEmpty: selected == null,
          decoration: InputDecoration(
            labelText: showLabel ? label : null, // avoid double label
            hintText: hintText,
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            enabled: enabled,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: border,
            enabledBorder: border,
            focusedBorder: focusedBorder,
          ),
          child: InkWell(
            key: fieldKey,
            onTap:
                !enabled
                    ? null
                    : () async {
                      // anchor menu BELOW the field
                      final ro =
                          fieldKey.currentContext!.findRenderObject()
                              as RenderBox;
                      final overlay =
                          Overlay.of(context).context.findRenderObject()
                              as RenderBox;
                      final topLeft = ro.localToGlobal(Offset.zero);
                      final target = Rect.fromLTWH(
                        topLeft.dx,
                        topLeft.dy + ro.size.height + 6, // small gap
                        ro.size.width,
                        0,
                      );

                      final chosen = await showMenu<Chore>(
                        context: context,
                        position: RelativeRect.fromRect(
                          target,
                          Offset.zero & overlay.size,
                        ),
                        color: Theme.of(context).colorScheme.surface,
                        elevation: 6,
                        constraints: const BoxConstraints(
                          minWidth: 280,
                          maxWidth: 420,
                          maxHeight: 360,
                        ),
                        items:
                            chores.map((c) {
                              final isSel = selected?.id == c.id;
                              return PopupMenuItem<Chore>(
                                value: c,
                                child: Row(
                                  children: [
                                    _PriorityPillMini(priority: c.priority),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        c.name,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.copyWith(
                                          color: AppColors.secondary,
                                          shadows: const [
                                            Shadow(
                                              offset: Offset(1, 1),
                                              blurRadius: 6,
                                              color: Colors.black54,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    _StatsBadge(chore: c),
                                    if (isSel) ...[
                                      const SizedBox(width: 8),
                                      const Icon(Icons.check, size: 18),
                                    ],
                                  ],
                                ),
                              );
                            }).toList(),
                      );

                      if (chosen != null) onChanged(chosen);
                    },
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selected?.name ?? '',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.secondary,
                      shadows: const [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 6,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.secondary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

// --- helpers used by the menu rows ---

class _PriorityPillMini extends StatelessWidget {
  const _PriorityPillMini({required this.priority});
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
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          shadows: const [
            Shadow(offset: Offset(1, 1), blurRadius: 6, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}

class _StatsBadge extends StatelessWidget {
  const _StatsBadge({required this.chore});
  final Chore chore;

  @override
  Widget build(BuildContext context) {
    final avg = Duration(seconds: chore.avgSeconds);
    final runs = chore.timesSeconds.length;
    final text = runs == 0 ? 'no runs' : '${_mmss(avg)} • $runs';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.grey[300],
          shadows: const [
            Shadow(offset: Offset(1, 1), blurRadius: 6, color: Colors.black54),
          ],
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
