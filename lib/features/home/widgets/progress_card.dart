// هذا الويدجت يمثل بطاقة التقدم اليومي.
// دوره إظهار نسبة الإنجاز للمستخدم وتشجيعه على إكمال بقية الأذكار.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProgressCard extends StatelessWidget {
  final int completedCategories;
  final double progressPercent;

  const ProgressCard({
    super.key,
    required this.completedCategories,
    required this.progressPercent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  progressPercent == 1.0
                      ? "تقبل الله طاعتك 🎉"
                      : "متبقي ${4 - completedCategories} أوراد لليوم",
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: progressPercent == 1.0
                        ? theme.colorScheme.secondary
                        : theme.textTheme.bodyMedium?.color,
                  ),
                ),
                Text(
                  "${(progressPercent * 100).toInt()}%",
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progressPercent,
                minHeight: 8,
                backgroundColor: theme.dividerColor,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progressPercent == 1.0
                      ? theme.colorScheme.secondary
                      : theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
