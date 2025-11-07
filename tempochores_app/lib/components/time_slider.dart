// time_slider.dart
import 'package:flutter/material.dart';

class TimeSlider extends StatefulWidget {
  const TimeSlider({
    super.key,
    this.min = 0,
    this.max = 120,
    this.initialValue = 5,
    required this.onChanged,
    this.height = 220,
    this.width = 72,
  }) : assert(initialValue >= 0);

  final int min;
  final int max;
  final int initialValue;
  final ValueChanged<int> onChanged;
  final double height;
  final double width;

  @override
  State<TimeSlider> createState() => _TimeSliderState();
}

class _TimeSliderState extends State<TimeSlider> {
  late final FixedExtentScrollController _controller;
  late int _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialValue.clamp(widget.min, widget.max);
    _controller = FixedExtentScrollController(
      initialItem: _selected - widget.min,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = widget.max - widget.min + 1;

    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // subtle center highlight
          IgnorePointer(
            child: Container(
              height: 40,
              width: widget.width,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          ListWheelScrollView.useDelegate(
            controller: _controller,
            physics: const FixedExtentScrollPhysics(),
            itemExtent: 32,
            diameterRatio: 1.8,
            perspective: 0.002,
            overAndUnderCenterOpacity: 0.35,
            onSelectedItemChanged: (idx) {
              final v = widget.min + idx;
              setState(() => _selected = v);
              widget.onChanged(v);
            },
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: itemCount,
              builder: (context, index) {
                final value = widget.min + index;
                final isSelected = value == _selected;
                return Center(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 120),
                    curve: Curves.easeOut,
                    style: TextStyle(
                      fontSize: isSelected ? 30 : 20,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 5,
                          color: Colors.black54,
                        ),
                        Shadow(
                          offset: Offset(-1, -1),
                          blurRadius: 5,
                          color: Colors.black54,
                        ),
                        Shadow(
                          offset: Offset(1, -1),
                          blurRadius: 5,
                          color: Colors.black54,
                        ),
                        Shadow(
                          offset: Offset(-1, 1),
                          blurRadius: 5,
                          color: Colors.black54,
                        ),
                      ],
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color:
                          isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    child: Text('$value'),
                  ),
                );
              },
            ),
          ),

          // minute marker on top, because humans forget units
        ],
      ),
    );
  }
}
