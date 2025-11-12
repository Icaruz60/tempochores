import 'package:flutter/material.dart';
import 'package:tempochores_app/pages/edit_chores_page.dart';
import 'package:tempochores_app/pages/plan_tempochore_page.dart';
import 'package:tempochores_app/pages/time_chore_page.dart';
import 'package:tempochores_app/pages/due_chores_page.dart';

class TempoChoresPager extends StatefulWidget {
  const TempoChoresPager({super.key});

  @override
  State<TempoChoresPager> createState() => _TempoChoresPagerState();
}

class _TempoChoresPagerState extends State<TempoChoresPager> {
  final _controller = PageController(initialPage: 1); // middle = Time Chore
  int _index = 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        onPageChanged: (i) => setState(() => _index = i),
        physics: const PageScrollPhysics(), // swipable
        children: const [
          _KeepAlive(child: PlanTempoChorePage()), // left
          _KeepAlive(child: DueChoresPage()),
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
          NavigationDestination(icon: Icon(Icons.assignment), label: 'Due'),
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
