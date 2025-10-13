import 'package:flutter/material.dart';
import 'package:tempochores_app/theme/colors.dart';

class TimeChorePage extends StatelessWidget {
  const TimeChorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/TempoChoresLogo.png', height: 40),
            const SizedBox(width: 2),
            const Text('Time Chore'),
          ],
        ),
        centerTitle: true,
        foregroundColor: AppColors.secondary,
      ),
      body: const Center(child: Text('Time Chore Page Content')),
    );
  }
}
