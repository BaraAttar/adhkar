// هذا الويدجت يمثل رأس الصفحة الرئيسية.
// دوره عرض التحية المؤقتة والآية المختارة بشكل جميل في أعلى الشاشة.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeHeader extends StatelessWidget {
  final String greeting;

  const HomeHeader({super.key, required this.greeting});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          greeting,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          '"ألا بذكر الله تطمئن القلوب" [الرعد: 28]',
          style: GoogleFonts.tajawal(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: theme.textTheme.bodyMedium?.color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
