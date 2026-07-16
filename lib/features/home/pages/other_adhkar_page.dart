// هذا الملف يمثل صفحة "الأذكار الأخرى".
// دوره عرض الأقسام الفرعية مثل التسابيح والأدعية النبوية وتوجيه المستخدم إلى تفاصيلها.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class OtherAdhkarPage extends StatelessWidget {
  const OtherAdhkarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // هنا يمكنك إضافة أو تعديل الأقسام الفرعية مستقبلاً بكل سهولة
    final List<Map<String, dynamic>> subcategories = [
      {
        'title': 'تسابيح منوعة',
        'icon': Icons.all_inclusive_outlined,
        'subcategoryKey': 'tasbih',
      },
      {
        'title': 'أدعية نبوية مأثورة',
        'icon': Icons.volunteer_activism_outlined,
        'subcategoryKey': 'prophetic_duaa',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "أذكار أخرى",
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.2,
        ),
        itemCount: subcategories.length,
        itemBuilder: (context, index) {
          final sub = subcategories[index];
          return InkWell(
            onTap: () {
              // ننتقل لصفحة التفاصيل مع تمرير القسم الرئيسي (other) والقسم الفرعي المحدد
              context.push(
                '/home/dhikr-detail/other?subcategory=${sub['subcategoryKey']}',
              );
            },
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      sub['icon'],
                      size: 30,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      sub['title'],
                      style: GoogleFonts.tajawal(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
