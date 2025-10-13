import 'package:flutter/material.dart';
import 'package:tempochores_app/theme/app_theme.dart';
import 'package:tempochores_app/theme/colors.dart';
import 'package:tempochores_app/components/menu_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/TempoChoresLogo.png', height: 40),
            const SizedBox(width: 2),
            const Text('TempoChores'),
          ],
        ),
        centerTitle: true,
        foregroundColor: AppColors.secondary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            MenuButton(
              title: 'Time a Chore',
              imageAsset: 'assets/images/timechore_bg.jpg', // no leading slash
              onPressed: () => Navigator.pushNamed(context, '/time'),
            ),
            MenuButton(
              title: 'Plan a TempoChore',
              imageAsset: 'assets/images/tempochore_bg.jpg',
              onPressed: () => Navigator.pushNamed(context, '/plan'),
            ),
            MenuButton(
              title: 'Add/Edit Chores',
              imageAsset: 'assets/images/editchore_bg.jpg',
              onPressed: () => Navigator.pushNamed(context, '/edit'),
            ),
          ],
        ),
      ),
    );
  }
}
