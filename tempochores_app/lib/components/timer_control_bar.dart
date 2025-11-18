import 'dart:math' as math;
import 'package:flutter/material.dart';



class TimerControlBar extends StatefulWidget {
  const TimerControlBar({
    super.key,
    required this.onStart,
    required this.onCancel,
    required this.onDone,
    required this.onPause,
  });

  final VoidCallback onStart;
  final VoidCallback onCancel;
  final VoidCallback onDone;
  final VoidCallback onPause;

  @override
  State<TimerControlBar> createState() => _TimerControlBarState();
}

class _TimerControlBarState extends State<TimerControlBar> {
  bool _running = false;

  @override
  Widget build(BuildContext context) {
  final w = MediaQuery.sizeOf(context).width * 0.9;
  final h = math.min(MediaQuery.sizeOf(context).height * 0.14, 140.0);

    return SizedBox(
      width: w,
      height: h,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder:
            (child, anim) => FadeTransition(opacity: anim, child: child),
        child:
            _running
                ? _buildActiveRow(context)
                : _buildStartButton(context), // toggles between these
      ),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return ElevatedButton(
      key: const ValueKey('start'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.greenAccent.shade400,
        foregroundColor: Colors.black,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () {
        widget.onStart();
        setState(() => _running = true);
      },
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Text(
          'Start',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildActiveRow(BuildContext context) {
    return Row(
      key: const ValueKey('controls'),
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _controlButton(
          label: 'Cancel',
          color: Colors.redAccent,
          onPressed: () {
            widget.onCancel();
            setState(() => _running = false);
          },
        ),
        _controlButton(
          label: 'Done!',
          color: Colors.greenAccent.shade400,
          textColor: Colors.black,
          onPressed: () {
            widget.onDone();
            setState(() => _running = false);
          },
        ),
        _controlButton(
          label: _buttonlabel,
          color: Colors.orangeAccent,
          onPressed: () {
            setState(() {
              widget.onPause();
              _buttonlabel = _buttonlabel == 'Pause' ? 'Unpause' : 'Pause';
            });
          },
        ),
      ],
    );
  }

  Widget _controlButton({
    required String label,
    required Color color,
    Color? textColor,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: textColor ?? Colors.white,
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: onPressed,
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

String _buttonlabel = 'Pause';
