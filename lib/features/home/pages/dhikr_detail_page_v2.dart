// هذا الملف يمثل نسخة محسّنة من صفحة تفاصيل الأذكار.
// دوره توفير تجربة تفاعلية أكثر سلاسة مع تنقل سريع بين الأذكار وزر عداد مريح.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // مكتبة الاهتزاز المادي (Haptics)
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart'; // مكتبة الانكماش المرن
import 'package:adhkar/core/database/db_helper.dart';
import 'dart:ui'; // لازم تضيف هذا الاستيراد فوق الملف لأجل ImageFilter

// =================================================================
// 1. الشاشة الرئيسية والمنطق البرمجي (المهندس المنسق)
// =================================================================
class DhikrDetailPageV2 extends StatefulWidget {
  final String category;
  final String? subcategory;

  const DhikrDetailPageV2({
    super.key,
    required this.category,
    this.subcategory,
  });

  @override
  State<DhikrDetailPageV2> createState() => _DhikrDetailPageV2State();
}

class _DhikrDetailPageV2State extends State<DhikrDetailPageV2> {
  List<Map<String, dynamic>> _dhikrList = [];
  bool _isLoading = true;

  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDhikrData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // تحميل الأذكار من قاعدة البيانات SQLite
  Future<void> _loadDhikrData() async {
    setState(() => _isLoading = true);
    final data = await DBHelper.getAdhkar(
      category: widget.category,
      subcategory: widget.subcategory,
    );
    setState(() {
      _dhikrList = List<Map<String, dynamic>>.from(data);
      _isLoading = false;
    });
  }

  // تعديل العداد محلياً وقاعدة البيانات مع ميزة النقل التلقائي
  void _incrementCounter(int index) async {
    final item = _dhikrList[index];
    final int id = item['id'];
    final int limit = item['count_limit'];
    int current = item['current_count'];

    if (current < limit) {
      current++;

      setState(() {
        _dhikrList[index] = Map<String, dynamic>.from(item)
          ..['current_count'] = current;
      });

      await DBHelper.updateCount(id, current);

      // الانتقال التلقائي للذكر التالي بعد نصف ثانية من الاكتمال
      if (current == limit && index < _dhikrList.length - 1) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (_pageController.hasClients) {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    }
  }

  // تحديد عنوان الشاشة بناءً على القسم المفتوح
  String _getCategoryTitle() {
    if (widget.subcategory != null && widget.subcategory!.isNotEmpty) {
      switch (widget.subcategory) {
        case 'tasbih':
          return 'تسابيح منوعة';
        case 'prophetic_duaa':
          return 'أدعية نبوية';
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

  // نافذة الفهرس والتنقل السريع (BottomSheet)
  void _showQuickNavigationSheet(ThemeData theme) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Material(
            color: theme.scaffoldBackgroundColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 20, bottom: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.55),
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Text(
                        "فهرس الأذكار (تنقل سريع)",
                        style: GoogleFonts.tajawal(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                // const Divider(height: 1),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: ListView.builder(
                      itemCount: _dhikrList.length,
                      itemBuilder: (context, index) {
                        final item = _dhikrList[index];
                        final String textSnippet = item['text']
                            .toString()
                            .split('\n')
                            .first;
                        final bool isCurrent = index == _currentPageIndex;
                        final bool isCompleted =
                            item['current_count'] >= item['count_limit'];

                        return ListTile(
                          tileColor: isCurrent
                              ? theme.colorScheme.primary.withValues(alpha: 0.1)
                              : null,
                          leading: CircleAvatar(
                            radius: 14,
                            backgroundColor: isCompleted
                                ? Colors.green
                                : theme.dividerColor,
                            child: Text(
                              "${index + 1}",
                              style: GoogleFonts.tajawal(
                                fontSize: 12,
                                color: isCompleted
                                    ? Colors.white
                                    : theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                          ),
                          title: Text(
                            textSnippet,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.tajawal(
                              fontWeight: isCurrent
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isCurrent
                                  ? theme.colorScheme.primary
                                  : theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          trailing: isCompleted
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.green,
                                  size: 20,
                                )
                              : null,
                          onTap: () {
                            Navigator.pop(context);
                            _pageController.jumpToPage(index);
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // تجهيز قيم العداد الحالي والأقصى للذكر النشط أمام المستخدم
    final currentItem = _dhikrList.isNotEmpty
        ? _dhikrList[_currentPageIndex]
        : null;
    final int limitValue = currentItem != null
        ? currentItem['count_limit'] as int
        : 1;
    final int currentValue = currentItem != null
        ? currentItem['current_count'] as int
        : 0;

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
              if (_pageController.hasClients && _dhikrList.isNotEmpty) {
                _pageController.jumpToPage(0);
              }
              // _pageController.jumpToPage(0);
            },
          ),
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: "فهرس التنقل السريع",
            onPressed: () => _showQuickNavigationSheet(theme),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dhikrList.isEmpty
          ? const Center(child: Text("لا توجد أذكار مضافة حالياً."))
          : Column(
              children: [
                // 1. مؤشر التقدم العلوي الخطي
                DhikrProgressHeader(
                  currentIndex: _currentPageIndex,
                  totalCount: _dhikrList.length,
                ),

                // 2. منطقة تقليب الكروت (PageView)
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPageIndex = index;
                      });
                    },
                    itemCount: _dhikrList.length,
                    itemBuilder: (context, index) {
                      final item = _dhikrList[index];
                      return DhikrCard(
                        text: item['text'],
                        virtue: item['virtue'] ?? '',
                      );
                    },
                  ),
                ),

                // 3. زر العداد السفلي التفاعلي المريح للضغط
                DhikrBottomCounter(
                  limit: limitValue,
                  current: currentValue,
                  onTap: () => _incrementCounter(_currentPageIndex),
                ),
              ],
            ),
    );
  }
}

// =================================================================
// 2. مكعب مؤشر التقدم الخطي العلوي (Progress Indicator)
// =================================================================
class DhikrProgressHeader extends StatelessWidget {
  final int currentIndex;
  final int totalCount;

  const DhikrProgressHeader({
    super.key,
    required this.currentIndex,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double progressValue = totalCount > 0
        ? (currentIndex + 1) / totalCount
        : 0.0;

    return Padding(
      // padding: const EdgeInsets.symmetric( horizontal: 20),
      padding: const EdgeInsets.only(top: 16, bottom: 0, left: 20, right: 20),
      child: Row(
        children: [
          Text(
            "${currentIndex + 1} / $totalCount",
            style: GoogleFonts.tajawal(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progressValue,
                minHeight: 6,
                backgroundColor: theme.dividerColor,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// 3. مكعب كارت عرض الذكر والفضل (Dhikr & Virtue Card)
// =================================================================
class DhikrCard extends StatelessWidget {
  final String text;
  final String virtue;

  const DhikrCard({super.key, required this.text, required this.virtue});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      // padding: const EdgeInsets.only(top: 8, bottom: 10, left: 10, right: 10),
      padding: const EdgeInsets.only(top: 8, bottom: 6, left: 6, right: 6),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // النص الأساسي للدعاء بخط كبير وواضح لقراءة مريحة للعين
              Text(
                text,
                style: GoogleFonts.tajawal(
                  fontSize: 24, // يمكنك تعديل حجم خط الدعاء من هنا
                  fontWeight: FontWeight.w800,
                  height: 1.8,
                  color: theme.textTheme.bodyLarge?.color,
                ),
                textAlign: TextAlign.center,
              ),

              // صندوق فضل الذكر الهادئ والمريح للعين
              if (virtue.isNotEmpty) ...[
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(
                      alpha: 0.04,
                    ), // درجة الشفافية لخلفية الصندوق
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(
                        alpha: 0.1,
                      ), // لون حد الصندوق
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.tips_and_updates_outlined,
                            size: 16,
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.7,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "فضل الذكر",
                            style: GoogleFonts.tajawal(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        virtue,
                        style: GoogleFonts.tajawal(
                          fontSize: 13, // حجم خط فضل الذكر
                          color: theme.textTheme.bodyMedium?.color,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// =================================================================
// 4. مكعب زر العداد السفلي التفاعلي (Bounceable Counter Button)
// =================================================================
class DhikrBottomCounter extends StatelessWidget {
  final int limit;
  final int current;
  final VoidCallback onTap;

  const DhikrBottomCounter({
    super.key,
    required this.limit,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isCompleted = current >= limit;

    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 20, left: 24, right: 24),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // نص العداد المتبقي
          Text(
            isCompleted
                ? "اكتمل الذكر بفضل الله ✨"
                : "المتبقي: ${limit - current} من $limit",
            style: GoogleFonts.tajawal(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isCompleted
                  ? Colors.green
                  : theme.textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 16),

          // ويدجت حركة الانكماش المرنة والاهتزاز الفيزيائي اللطيف عند الضغط
          Bounceable(
            scaleFactor:
                0.85, // مدى تصغير الزر عند الضغط (0.85 تعني يصغر بنسبة 15%)
            duration: const Duration(milliseconds: 100), // سرعة الانكماش
            reverseDuration: const Duration(
              milliseconds: 100,
            ), // سرعة الارتداد للحجم الطبيعي
            hitTestBehavior: HitTestBehavior.opaque,
            onTap: () {
              HapticFeedback.lightImpact(); // اهتزاز خفيف باليد يحاكي ضغط حبات السبحة
              onTap(); // استدعاء دالة تحديث العداد
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height:
                  65, // ارتفاع الزر ليكون مريحاً جداً للضغط الإبهام دون النظر للشاشة
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                // التدرج اللوني للزر (يتغير للون الأخضر تلقائياً عند الاكتمال)
                gradient: LinearGradient(
                  colors: isCompleted
                      ? [Colors.green.shade400, Colors.green.shade600]
                      : [
                          theme.colorScheme.primary.withValues(alpha: 0.7),
                          theme.colorScheme.primary,
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        (isCompleted ? Colors.green : theme.colorScheme.primary)
                            .withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: isCompleted
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: Colors.white,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "اكتمل",
                            style: GoogleFonts.tajawal(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.touch_app_rounded,
                            color: Colors.white70,
                            size: 28,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            "$current",
                            style: GoogleFonts.tajawal(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
