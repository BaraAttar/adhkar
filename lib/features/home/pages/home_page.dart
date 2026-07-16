// هذا الملف يمثل الصفحة الرئيسية للتطبيق.
// دوره عرض الترحيب، ومواقيت الصلاة، ومؤشر التقدم اليومي، وأقسام الأذكار الرئيسية.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:adhkar/core/database/db_helper.dart';

// Widgets
import 'package:adhkar/features/home/widgets/home_header.dart';
import 'package:adhkar/features/home/widgets/prayer_times_card.dart';
import 'package:adhkar/features/home/widgets/progress_card.dart';
import 'package:adhkar/features/home/widgets/category_card.dart';
import 'package:adhkar/features/home/widgets/support_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String greeting = "السلام عليكم، اذكر الله";
  int completedCategories = 0;

  @override
  void initState() {
    super.initState();
    _updateGreeting();
    _loadProgress();
  }

  // تحديث التحية بناءً على الوقت الحالي
  void _updateGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      setState(() => greeting = "صباح الخير، اذكر الله ☀️");
    } else if (hour >= 12 && hour < 18) {
      setState(() => greeting = "طاب يومك، اذكر الله ✨");
    } else {
      setState(() => greeting = "مساء الخير، اذكر الله 🌙");
    }
  }

  // حساب عدد الأقسام المكتملة لليوم
  Future<void> _loadProgress() async {
    int completed = 0;
    final categories = ['morning', 'evening', 'sleep', 'tasbih'];
    for (var cat in categories) {
      if (await DBHelper.isCategoryCompleted(cat)) {
        completed++;
      }
    }
    setState(() {
      completedCategories = completed;
    });
  }

  @override
  Widget build(BuildContext context) {
    double progressPercent = completedCategories / 4.0;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. الترحيب وآية اليوم
              HomeHeader(greeting: greeting),
              const SizedBox(height: 18),

              // 2. مواقيت الصلاة
              const PrayerTimesCard(),
              const SizedBox(height: 16),

              // 3. شريط التقدم اليومي
              ProgressCard(
                completedCategories: completedCategories,
                progressPercent: progressPercent,
              ),
              const SizedBox(height: 18),

              // 4. شبكة الأقسام الأربعة
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.2,
                children: [
                  CategoryCard(
                    title: "أذكار الصباح",
                    icon: Icons.wb_sunny_outlined,
                    categoryKey: "morning",
                    onTap: () => _navigateToDetail("morning"),
                  ),
                  CategoryCard(
                    title: "أذكار المساء",
                    icon: Icons.nightlight_round_outlined,
                    categoryKey: "evening",
                    onTap: () => _navigateToDetail("evening"),
                  ),
                  CategoryCard(
                    title: "أذكار النوم",
                    icon: Icons.bedtime_outlined,
                    categoryKey: "sleep",
                    onTap: () => _navigateToDetail("sleep"),
                  ),
                  CategoryCard(
                    title: "تسابيح منوعة",
                    icon: Icons.all_inclusive_outlined,
                    categoryKey: "tasbih",
                    onTap: () => _navigateToDetail("tasbih"),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 5. بطاقة دعم التطبيق
              const SupportCard(),
            ],
          ),
        ),
      ),
    );
  }

  // دالة مخصصة للانتقال لشاشة التفاصيل وتحديث حالة الإنجاز عند العودة
  Future<void> _navigateToDetail(String categoryKey) async {
    await context.push('/home/dhikr-detail/$categoryKey');
    _loadProgress(); // إعادة حساب التقدم عند العودة من شاشة الأذكار
  }
}
