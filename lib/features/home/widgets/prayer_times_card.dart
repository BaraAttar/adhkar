import 'dart:async';
import 'package:adhkar/features/home/services/prayer_time_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// الويدجت الرئيسي لبطاقة مواقيت الصلاة.
/// يقوم بإدارة الحالة (State)، جلب البيانات (الموقع والمواقيت)، وتحديث العداد التنازلي كل ثانية.
class PrayerTimesCard extends StatefulWidget {
  const PrayerTimesCard({super.key});

  @override
  State<PrayerTimesCard> createState() => _PrayerTimesCardState();
}

class _PrayerTimesCardState extends State<PrayerTimesCard> {
  String cityName = "جاري تحديد الموقع...";
  PrayerTimesModel? prayerTimes;
  Timer? _countdownTimer; // مؤقت داخلي لتحديث العداد التنازلي كل ثانية

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  @override
  void dispose() {
    _countdownTimer
        ?.cancel(); // إلغاء المؤقت فور مغادرة الصفحة لتجنب تسريب الذاكرة (Memory Leak)
    super.dispose();
  }

  /// جلب المدينة ومواقيت الصلاة، وتفعيل المؤقت الزمني فور الانتهاء.
  Future<void> _loadLocation() async {
    try {
      final name = await getLocation();
      final times = await getPrayerTimes();

      if (!mounted) return;

      setState(() {
        cityName = name;
        prayerTimes = times;
      });

      _startTimer();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        cityName = "مكة المكرمة";
      });

      debugPrint(e.toString());
    }
  }

  /// بدء تشغيل المؤقت الدوري وتحديث الواجهة كل ثانية.
  /// إذا انتهى وقت الصلاة القادمة، يعيد جلب البيانات للانتقال للصلاة التي تليها.
  void _startTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (prayerTimes != null) {
        final now = DateTime.now();
        final nextPrayer = prayerTimes!.nextPrayer;
        DateTime nextPrayerTime = nextPrayer.time;

        // معالجة صلاة الفجر لليوم التالي إذا انتهت صلوات اليوم الحالي
        if (nextPrayerTime.isBefore(now)) {
          nextPrayerTime = nextPrayerTime.add(const Duration(days: 1));
        }

        final remainingDuration = nextPrayerTime.difference(now);

        // التحقق مما إذا حان وقت الأذان الحالي للانتقال للصلاة التالية
        if (remainingDuration.isNegative || remainingDuration.inSeconds <= 0) {
          _loadLocation();
          return;
        }
      }

      setState(() {}); // تحديث الواجهة لعرض الثواني الجديدة
    });
  }

  /// دالة مساعدة لتنسيق الوقت المتبقي إلى صيغة (ساعة:دقيقة:ثانية).
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    // إظهار مؤشر التحميل حتى تتوفر البيانات
    if (prayerTimes == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final theme = Theme.of(context);
    final formatter = DateFormat('hh:mm a');

    // === الحسابات الرياضية للوقت والتقدم ===
    final now = DateTime.now();
    final nextPrayer = prayerTimes!.nextPrayer;

    // الحصول على الصلاة السابقة لتحديد بداية ونهاية الفترة الزمنية الحالية
    final nextIndex = prayerTimes!.prayers.indexOf(nextPrayer);
    final prevIndex =
        (nextIndex - 1 + prayerTimes!.prayers.length) %
        prayerTimes!.prayers.length;
    final prevPrayer = prayerTimes!.prayers[prevIndex];

    DateTime nextPrayerTime = nextPrayer.time;
    if (nextPrayerTime.isBefore(now)) {
      nextPrayerTime = nextPrayerTime.add(const Duration(days: 1));
    }

    DateTime prevPrayerTime = prevPrayer.time;
    if (prevPrayerTime.isAfter(now)) {
      prevPrayerTime = prevPrayerTime.subtract(const Duration(days: 1));
    }

    final totalDuration = nextPrayerTime.difference(prevPrayerTime);
    final remainingDuration = nextPrayerTime.difference(now);
    final elapsedDuration = now.difference(prevPrayerTime);

    // حساب نسبة الامتلاء لشريط التقدم
    double progress = 0.0;
    if (totalDuration.inSeconds > 0) {
      progress = elapsedDuration.inSeconds / totalDuration.inSeconds;
      progress = progress.clamp(0.0, 1.0);
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1. الجزء العلوي (رأس البطاقة)
            _PrayerHeader(cityName: cityName, nextPrayerName: nextPrayer.name),

            Divider(
              height: 24,
              thickness: 1.5,
              color: Colors.black.withValues(alpha: 0),
            ),

            // 2. شريط التقدم والعداد التنازلي
            _PrayerCountdown(
              remainingTime: _formatDuration(remainingDuration),
              progress: progress,
            ),

            Divider(
              height: 24,
              thickness: 1.5,
              color: Colors.black.withValues(alpha: 0),
            ),

            // 3. قائمة مواقيت الصلوات الخمس
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: prayerTimes!.prayers.map((prayer) {
                return _PrayerTimeItem(
                  name: prayer.name,
                  time: formatter.format(prayer.time),
                  isActive: prayer.isNext,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// الويدجت الفرعية المخصصة لواجهة المستخدم (Sub-Widgets)
// ==========================================

/// [1] رأس البطاقة: يعرض عنوان القسم، اسم المدينة الحالي، وشارة الصلاة القادمة.
class _PrayerHeader extends StatelessWidget {
  final String cityName;
  final String nextPrayerName;

  const _PrayerHeader({required this.cityName, required this.nextPrayerName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              " مواقيت الصلاة",
              style: GoogleFonts.tajawal(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              cityName,
              style: GoogleFonts.tajawal(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "$nextPrayerName بعد قليل",
            style: GoogleFonts.tajawal(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

/// [2] شريط التقدم والعداد التنازلي: يعرض الوقت المتبقي للأذان القادم وشريط تعبيري مرئي.
class _PrayerCountdown extends StatelessWidget {
  final String remainingTime;
  final double progress;

  const _PrayerCountdown({required this.remainingTime, required this.progress});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "الوقت المتبقي للأذان القادم",
              style: GoogleFonts.tajawal(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: theme.textTheme.bodyMedium?.color?.withValues(
                  alpha: 0.7,
                ),
              ),
            ),
            Text(
              remainingTime,
              style: GoogleFonts.tajawal(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

/// [3] ويدجت الصلاة الواحدة: يعرض اسم الصلاة ووقتها، ويتميز بخلفية ملونة ونصوص عريضة إذا كانت هي الصلاة القادمة.
class _PrayerTimeItem extends StatelessWidget {
  final String name;
  final String time;
  final bool isActive;

  const _PrayerTimeItem({
    required this.name,
    required this.time,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isActive
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text(
            name,
            style: GoogleFonts.tajawal(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: GoogleFonts.tajawal(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
}
