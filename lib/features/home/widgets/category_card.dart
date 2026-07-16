// هذا الويدجت يمثل بطاقة القسم الرئيسي داخل الصفحة الرئيسية.
// دوره عرض اسم القسم وأيقونته مع معرفة ما إذا كان هذا القسم مكتملًا بالفعل.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:adhkar/core/database/db_helper.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String categoryKey;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.title,
    required this.icon,
    required this.categoryKey,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<bool>(
      future: DBHelper.isCategoryCompleted(categoryKey),
      builder: (context, snapshot) {
        final isCompleted = snapshot.data ?? false;

        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCompleted
                  ? theme.colorScheme.primary.withValues(alpha: 0.08)
                  : theme.cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isCompleted
                    ? theme.colorScheme.primary
                    : theme.dividerColor,
                width: isCompleted ? 1.5 : 1,
              ),
            ),
            child: Stack(
              children: [
                if (isCompleted)
                  const Positioned(
                    top: 0,
                    left: 0,
                    child: CircleAvatar(
                      radius: 9,
                      backgroundColor: Colors.teal,
                      child: Icon(Icons.check, size: 10, color: Colors.white),
                    ),
                  ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 30, color: theme.colorScheme.primary),
                      const SizedBox(height: 10),
                      Text(
                        title,
                        style: GoogleFonts.tajawal(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
