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
            gradient: kHeaderGradient,
            borderRadius: BorderRadius.circular(size * 0.3),
            boxShadow: [
              BoxShadow(color: kPrimary.withValues(alpha: 0.3), blurRadius: 18, offset: const Offset(0, 8)),
            ],
          ),
          child: Icon(Icons.task_alt_rounded, color: Colors.white, size: size * 0.55),
        ),
        const SizedBox(height: 16),
        Text(
          'Questly',
          style: TextStyle(fontSize: size * 0.4, fontWeight: FontWeight.w800, letterSpacing: -0.5),
        ),
      ],
    );
  }
}
