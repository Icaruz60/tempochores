import 'package:flutter/material.dart';
import '/pages/plan_tempochore_page.dart';
import '/pages/time_chore_page.dart';
import '/pages/edit_chores_page.dart';

class TempoChoresPager extends StatefulWidget {
  const TempoChoresPager({super.key});

  @override
  State<TempoChoresPager> createState() => _TempoChoresPagerState();
}

class _TempoChoresPagerState extends State<TempoChoresPager> {
  final _controller = PageController(initialPage: 1); // middle = Time Chore
  int _index = 1;

  static const _titles = <String>[
    'Plan TempoChore',
    'Time Chore',
    'Edit Chores',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_index]), centerTitle: true),
      body: PageView(
        controller: _controller,
        onPageChanged: (i) => setState(() => _index = i),
        physics: const PageScrollPhysics(), // swipable
        children: const [
          _KeepAlive(child: PlanTempoChorePage()), // left
          _KeepAlive(child: TimeChorePage()), // middle
          _KeepAlive(child: EditChoresPage()), // right
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          _controller.animateToPage(
            i,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
          );
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.event_note), label: 'Plan'),
          NavigationDestination(icon: Icon(Icons.timer), label: 'Time'),
          NavigationDestination(icon: Icon(Icons.edit), label: 'Edit'),
        ],
      ),
    );
  }
}

class _KeepAlive extends StatefulWidget {
  final Widget child;
  const _KeepAlive({required this.child});

  @override
  State<_KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<_KeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
