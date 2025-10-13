import 'package:flutter/material.dart';
import 'package:tempochores_app/theme/colors.dart';

class PlanTempoChorePage extends StatelessWidget {
  const PlanTempoChorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/TempoTaskLogo.png', height: 40),
            const SizedBox(width: 2),
            const Text('Plan TempoChore'),
          ],
        ),
        centerTitle: true,
        foregroundColor: AppColors.secondary,
      ),
      body: const Center(child: Text('Plan TempoChore Page Content')),
    );
  }
}
