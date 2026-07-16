// هذا الويدجت يمثل بطاقة الدعم للمطور.
// دوره تشجيع المستخدم على دعم التطبيق وإظهار رسالة واضحة عن أهمية الدعم.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';

class SupportCard extends StatelessWidget {
  const SupportCard({super.key});

  void _openSupportBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return const _SupportSheetContent();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.primary.withValues(alpha: 0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(
              Icons.coffee_outlined,
              size: 32,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              "مساهمتك تساعد في استمرار التطبيق مجاناً وبدون إعلانات، ليبقى عوناً للجميع، وصدقة جارية بإذن الله.",
              style: GoogleFonts.tajawal(
                fontSize: 13,
                height: 1.5,
                color: theme.textTheme.bodyMedium?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width:
                  MediaQuery.of(context).size.width *
                  0.8, // هنا حددنا 80% من عرض الشاشة بالكامل
              child: Bounceable(
                scaleFactor: 0.9,
                duration: const Duration(milliseconds: 100),
                reverseDuration: const Duration(milliseconds: 100),
                onTap: () {
                  _openSupportBottomSheet(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.25,
                        ),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "دعم المطور",
                      style: GoogleFonts.tajawal(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =================================================================
// محتويات وإدارة حالة نافذة الدعم السفلية
// =================================================================
class _SupportSheetContent extends StatefulWidget {
  const _SupportSheetContent();

  @override
  State<_SupportSheetContent> createState() => _SupportSheetContentState();
}

class _SupportSheetContentState extends State<_SupportSheetContent> {
  bool _isMonthly = false;
  int _selectedTierIndex = 0;

  final List<Map<String, dynamic>> _hospitalityTiers = [
    {
      'title': 'كوب قهوة',
      'price': 12,
      'icon': Icons.coffee_outlined,
      'index': 0,
    },
    {
      'title': 'قهوة وحلى',
      'price': 24,
      'icon': Icons.cake_outlined,
      'index': 1,
    },
  ];

  final List<Map<String, dynamic>> _premiumTiers = [
    {
      'title': 'داعم مميز',
      'price': 50,
      'icon': Icons.restaurant_outlined,
      'index': 2,
    },
    {
      'title': 'داعم قوي',
      'price': 100,
      'icon': Icons.yard_outlined,
      'index': 3,
    },
    {
      'title': 'داعم أسطوري',
      'price': 200,
      'icon': Icons.menu_book_outlined,
      'index': 4,
    },
    {
      'title': 'داعم خارق',
      'price': 500,
      'icon': Icons.military_tech_outlined,
      'index': 5,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "دعم استمرار التطبيق ✨",
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              "مساهمتك تساعد في استمرار التطبيق مجاناً وبدون إعلانات، ليبقى عوناً للجميع، وصدقة جارية بإذن الله.",
              style: GoogleFonts.tajawal(
                fontSize: 13,
                height: 1.5,
                color: theme.textTheme.bodyMedium?.color,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 20),

            // تابس التبديل (مرة واحدة / شهرياً)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.dividerColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _buildTabButton("مرة واحدة", !_isMonthly, () {
                    setState(() {
                      _isMonthly = false;
                      _selectedTierIndex = 0;
                    });
                  }),
                  _buildTabButton("شهرياً", _isMonthly, () {
                    setState(() {
                      _isMonthly = true;
                      _selectedTierIndex = 0;
                    });
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(
              "اعزم المطور على:",
              style: GoogleFonts.tajawal(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.3,
              children: _hospitalityTiers
                  .map((tier) => _buildTierCard(tier, theme))
                  .toList(),
            ),
            const SizedBox(height: 20),

            Text(
              "باقات الدعم المميزة:",
              style: GoogleFonts.tajawal(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.3,
              children: _premiumTiers
                  .map((tier) => _buildTierCard(tier, theme))
                  .toList(),
            ),
            const SizedBox(height: 28),

            // زر تأكيد وإرسال التبرع
            Bounceable(
              scaleFactor: 0.9,
              duration: const Duration(milliseconds: 100),
              reverseDuration: const Duration(milliseconds: 100),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: theme.colorScheme.primary,
                    content: Text(
                      "سيتم فتح نافذة الدفع الإلكتروني الآمن للمتجر... 💳",
                      style: GoogleFonts.tajawal(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    "تأكيد وإرسال المساهمة 🤍",
                    style: GoogleFonts.tajawal(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // بناء أزرار التبديل الفاتحة بتأثير انكماش فوري
  Widget _buildTabButton(String label, bool isActive, VoidCallback onTap) {
    final theme = Theme.of(context);
    return Expanded(
      child: Bounceable(
        scaleFactor: 0.90,
        duration: const Duration(milliseconds: 100),
        reverseDuration: const Duration(milliseconds: 100),
        onTap: () {
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? theme.cardColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.tajawal(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.textTheme.bodyMedium?.color,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // بناء كروت الباقات الفردية بتأثير انكماش فوري واهتزاز خفيف
  Widget _buildTierCard(Map<String, dynamic> tier, ThemeData theme) {
    final int index = tier['index'];
    final bool isActive = _selectedTierIndex == index;
    final String priceLabel = _isMonthly
        ? "${tier['price']} ريال/شهرياً"
        : "${tier['price']} ريال";

    return Bounceable(
      scaleFactor: 0.90,
      duration: const Duration(
        milliseconds: 100,
      ), // تسريع فوري 50ms لارتداد خاطف
      reverseDuration: const Duration(milliseconds: 100),
      onTap: () {
        setState(() {
          _selectedTierIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive
              ? theme.colorScheme.primary.withValues(alpha: 0.08)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? theme.colorScheme.primary : theme.dividerColor,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              tier['icon'],
              size: 24,
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.textTheme.bodyMedium?.color,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tier['title'],
                    style: GoogleFonts.tajawal(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    priceLabel,
                    style: GoogleFonts.tajawal(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: isActive
                          ? theme.colorScheme.primary
                          : theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
