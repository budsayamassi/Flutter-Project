import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// โลโก้ Questly
class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: kPrimary,
            borderRadius: BorderRadius.circular(size * 0.28),
          ),
          child: Icon(Icons.task_alt, color: Colors.white, size: size * 0.55),
        ),
        const SizedBox(height: 14),
        Text(
          'Questly',
          style: TextStyle(fontSize: size * 0.4, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
