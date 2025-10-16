import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:tempochores_app/components/chores_selector.dart';
import 'package:tempochores_app/components/time_slider.dart';
import 'package:tempochores_app/models/chore.dart';
import 'package:tempochores_app/theme/colors.dart';

class PlanTempoChorePage extends StatefulWidget {
  const PlanTempoChorePage({super.key});

  @override
  State<PlanTempoChorePage> createState() => _PlanTempoChorePageState();
}

class _PlanTempoChorePageState extends State<PlanTempoChorePage> {
  int minutes = 0;
  Set<String> _selectedIds = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // back button appears automatically if this page was pushed
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/TempoChoresLogo.png', height: 40),
            const SizedBox(width: 8),
            const Text('Plan TempoChore'),
          ],
        ),
        centerTitle: true,
        foregroundColor: AppColors.secondary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.9,
              height: MediaQuery.sizeOf(context).height * 0.15,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'I have ',
                    style: TextStyle(
                      fontSize: 30,
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
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Not const: it depends on state and calls setState
                  TimeSlider(
                    initialValue: minutes,
                    onChanged: (v) => setState(() => minutes = v),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    ' Minutes',
                    style: TextStyle(
                      fontSize: 30,
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
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.9,
              height: MediaQuery.sizeOf(context).height * 0.4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('These Chores are due: '),
                  const SizedBox(width: 8),
                  // Not const: it depends on state and calls setState
                  Expanded(
                    child: ChoresSelector(
                      items: Hive.box<Chore>('chores').values.toList(),
                      selectedIds: _selectedIds,
                      onChanged: (ids) => setState(() => _selectedIds = ids),
                      showSearch: false,
                      emptyLabel: 'No chores found',
                      title: 'Select chores',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    offset: Offset(5, 5),
                  ),
                ],
              ),
              child: SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.4,
                height: MediaQuery.sizeOf(context).height * 0.1,
                child: ElevatedButton(
                  onPressed: () {
                    // Plan the TempoChore with the selected chores and time CHRIS YOUR PART HERE
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: const Text(
                    'Go!',
                    style: const TextStyle(
                      fontSize: 24,
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
                ),
              ),
            ),
            SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}
