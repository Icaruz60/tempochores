import 'package:flutter/material.dart';
import 'package:tempochores_app/theme/colors.dart';

class MenuButton extends StatelessWidget {
  final String title;
  final String imageAsset;
  final VoidCallback onPressed;

  const MenuButton({
    super.key,
    required this.title,
    required this.imageAsset,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(5, 5),
          ),
        ],
      ),
      child: SizedBox(
        width: w * 0.9,
        height: w * 0.4,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero, // let image fill
            backgroundColor: Colors.transparent, // show image
            shadowColor: Colors.black54,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          onPressed: onPressed,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              image: DecorationImage(
                image: AssetImage(imageAsset),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 40,
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
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
        ),
      ),
    );
  }
}
