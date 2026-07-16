// هذا الملف يمثل صفحة تفاصيل الأذكار التقليدية.
// دوره عرض قائمة الأذكار مع عداد التقدم وإمكانية زيادة العد أو إعادة تصفيره.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:adhkar/core/database/db_helper.dart';

class DhikrDetailPage extends StatefulWidget {
  final String category;
  final String? subcategory; // إضافة المتغير الاختياري هنا

  const DhikrDetailPage({super.key, required this.category, this.subcategory});

  @override
  State<DhikrDetailPage> createState() => _DhikrDetailPageState();
}

class _DhikrDetailPageState extends State<DhikrDetailPage> {
  List<Map<String, dynamic>> _dhikrList = [];
  bool _isLoading = true;
  final Map<int, bool> _expandedVirtues = {};

  @override
  void initState() {
    super.initState();
    _loadDhikrData();
  }

  Future<void> _loadDhikrData() async {
    setState(() => _isLoading = true);
    // جلب البيانات مع تمرير الـ subcategory إن وجد
    final data = await DBHelper.getAdhkar(
      category: widget.category,
      subcategory: widget.subcategory,
    );
    setState(() {
      _dhikrList = data;
      _isLoading = false;
    });
  }

  // تسمية الشاشة ديناميكياً
  String _getCategoryTitle() {
    if (widget.subcategory != null) {
      switch (widget.subcategory) {
        case 'tasbih':
          return 'تسابيح منوعة';
        case 'prophetic_duaa':
          return 'أدعية نبوية مأثورة';
        default:
          return 'أذكار فرعية';
      }
    }

    switch (widget.category) {
      case 'morning':
        return 'أذكار الصباح';
      case 'evening':
        return 'أذكار المساء';
      case 'sleep':
        return 'أذكار النوم';
      default:
        return 'الأذكار';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getCategoryTitle(),
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "إعادة تصفير الورد",
            onPressed: () async {
              await DBHelper.resetCategoryProgress(
                widget.category,
                subcategory: widget.subcategory,
              );
              _loadDhikrData();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dhikrList.isEmpty
          ? const Center(child: Text("لا توجد أذكار مضافة حالياً."))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _dhikrList.length,
              itemBuilder: (context, index) {
                final item = _dhikrList[index];
                final int id = item['id'];
                final String text = item['text'];
                final int limit = item['count_limit'];
                final int current = item['current_count'];
                final String virtue = item['virtue'] ?? '';
                final bool isCompleted = current >= limit;
                final bool isVirtueVisible = _expandedVirtues[id] ?? false;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(
                      color: isCompleted
                          ? theme.colorScheme.primary
                          : theme.dividerColor,
                      width: isCompleted ? 1.5 : 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          text,
                          style: GoogleFonts.tajawal(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 12),
                        if (virtue.isNotEmpty) ...[
                          InkWell(
                            onTap: () {
                              setState(() {
                                _expandedVirtues[id] = !isVirtueVisible;
                              });
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.menu_book,
                                  size: 14,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "📖 فضل الذكر",
                                  style: GoogleFonts.tajawal(
                                    fontSize: 12,
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isVirtueVisible) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.dividerColor.withValues(
                                  alpha: 0.3,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: theme.dividerColor),
                              ),
                              child: Text(
                                virtue,
                                style: GoogleFonts.tajawal(
                                  fontSize: 12,
                                  color: theme.textTheme.bodyMedium?.color,
                                ),
                              ),
                            ),
                          ],
                        ],
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isCompleted
                                  ? "مكتمل ✓"
                                  : "المتبقي: ${limit - current} من $limit",
                              style: GoogleFonts.tajawal(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isCompleted
                                    ? theme.colorScheme.primary
                                    : theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                if (current < limit) {
                                  final nextCount = current + 1;
                                  await DBHelper.updateCount(id, nextCount);
                                  _loadDhikrData();
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isCompleted
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.primary.withValues(
                                          alpha: 0.12,
                                        ),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: theme.colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: isCompleted
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 20,
                                        )
                                      : Text(
                                          "$current",
                                          style: GoogleFonts.tajawal(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
