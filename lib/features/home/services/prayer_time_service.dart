import 'package:adhan_dart/adhan_dart.dart';
import 'package:adhkar/core/utils/logger.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// نموذج بيانات يمثل مدينة جغرافية.
/// يُستخدم لتخزين الإحداثيات الثابتة للمدن لعرض المواقيت أو كخيار بديل عند تعذر تحديد الموقع التلقائي.
class City {
  final String name; // اسم المدينة (مثال: مكة)
  final double latitude; // خط العرض
  final double longitude; // خط الطول

  const City(this.name, this.latitude, this.longitude);
}

/// قائمة المدن الافتراضية المعرفة مسبقاً في التطبيق.
/// تُستخدم كقائمة ثابتة للاختيار أو لتحديد موقع افتراضي في حال رفض المستخدم إعطاء صلاحية الموقع.
const cities = [
  City('مكة', 21.4225, 39.8262),
  City('الرياض', 24.7136, 46.6753),
  City('جدة', 21.5433, 39.1728),
  City('القاهرة', 30.0444, 31.2357),
];

/// دالة مسؤولة عن جلب إحداثيات الموقع الجغرافي (Coordinates) لحساب مواقيت الصلاة.
/// - إذا تم تمرير مدينة معينة [city]، تُرجع إحداثياتها مباشرة.
/// - إذا لم تُمرر مدينة، تحاول جلب الإحداثيات الحالية عبر الـ GPS مع معالجة الصلاحيات.
Future<Coordinates> getPrayerCoordinates({City? city}) async {
  // 1. إذا اختار المستخدم مدينة محددة يدوياً، نستخدم إحداثياتها فوراً
  if (city != null) {
    return Coordinates(city.latitude, city.longitude);
  }

  // المدينة الافتراضية للرجوع إليها في حال حدوث أي مشكلة أو رفض الصلاحيات (مكة المكرمة)
  final defaultCity = cities.first;

  // 2. التحقق مما إذا كانت خدمة تحديد الموقع (GPS) مفعلة في جهاز المستخدم
  if (!await Geolocator.isLocationServiceEnabled()) {
    return Coordinates(defaultCity.latitude, defaultCity.longitude);
  }

  // 3. التحقق من صلاحيات الوصول للموقع الجغرافي
  LocationPermission permission = await Geolocator.checkPermission();

  // 4. طلب الصلاحية من المستخدم إذا لم يتم تحديدها مسبقاً
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  // 5. إذا تم رفض الصلاحية نهائياً أو مؤقتاً، نعود لإحداثيات مكة المكرمة الافتراضية
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    return Coordinates(defaultCity.latitude, defaultCity.longitude);
  }

  // 6. في حال قبول الصلاحية بنجاح، جلب موقع الجهاز الحالي
  final position = await Geolocator.getCurrentPosition();

  return Coordinates(position.latitude, position.longitude);
}

/// دالة تقوم بتحويل الإحداثيات الجغرافية الحالية إلى اسم مدينة مقروء (عبر تقنية Reverse Geocoding).
Future<String> getLocation() async {
  String cityName = "جاري تحديد الموقع...";
  final geocoding = Geocoding();

  try {
    // جلب الإحداثيات الحالية للجهاز
    final coordinates = await getPrayerCoordinates();

    // استخراج معلومات العناوين المرتبطة بهذه الإحداثيات
    final placemarks = await geocoding.placemarkFromCoordinates(
      coordinates.latitude,
      coordinates.longitude,
    );

    // استخراج اسم المدينة (locality) وإرجاعه، أو التراجع لاسم "مكة" كخيار افتراضي
    if (placemarks.isNotEmpty) {
      cityName = placemarks.first.locality ?? "مكة";
    }
  } catch (e) {
    // تسجيل أي خطأ قد يحدث أثناء العملية في سجل الأخطاء الآمن
    safeLog(e.toString());
  }

  return cityName;
}

/// نموذج بيانات يمثل صلاة واحدة.
class PrayerItem {
  final String name; // اسم الصلاة (الفجر، الظهر، إلخ)
  final DateTime time; // التوقيت الفعلي للصلاة بصيغة تاريخ ووقت كامل

  bool isNext; // علامة لتحديد ما إذا كانت هذه هي الصلاة القادمة حالياً

  PrayerItem({required this.name, required this.time, this.isNext = false});
}

/// نموذج البيانات الكلي لمواقيت صلوات اليوم.
/// يوفر وصولاً سريعاً ومنظماً للصلوات الخمس الفردية، بالإضافة للوصول المباشر للصلاة القادمة.
class PrayerTimesModel {
  final List<PrayerItem> prayers; // قائمة تحتوي على الصلوات الخمس مرتبة

  PrayerTimesModel({required this.prayers});

  // اختصارات (Getters) لتسهيل الوصول لكل صلاة على حدة من خلال ترتيبها في القائمة
  PrayerItem get fajr => prayers[0];
  PrayerItem get dhuhr => prayers[1];
  PrayerItem get asr => prayers[2];
  PrayerItem get maghrib => prayers[3];
  PrayerItem get isha => prayers[4];

  // استخراج الصلاة التي تم تحديدها كصلاة قادمة بناءً على حقل isNext
  PrayerItem get nextPrayer => prayers.firstWhere((p) => p.isNext);
}

/// الدالة الأساسية لحساب مواقيت الصلاة لليوم الحالي.
/// تعتمد على موقع المستخدم الحالي وتطبق طريقة حساب "أم القرى".
Future<PrayerTimesModel> getPrayerTimes() async {
  // 1. جلب إحداثيات الموقع (الجغرافي أو الافتراضي)
  final coordinates = await getPrayerCoordinates();

  // 2. ضبط إعدادات طريقة الحساب (هنا تم استخدام طريقة أم القرى الرسمية لعامة المملكة العربية السعودية)
  final params = CalculationMethodParameters.ummAlQura();

  // 3. حساب الأوقات باستخدام مكتبة adhan_dart استناداً لتاريخ اليوم والمنطقة
  final adhan = PrayerTimes(
    coordinates: coordinates,
    date: DateTime.now(),
    calculationParameters: params,
    precision: true, // دقة إضافية للحسابات بالثواني
  );

  // 4. تعبئة قائمة الصلوات وتأكيد تحويل أوقات الصلوات من التوقيت العالمي (UTC) إلى التوقيت المحلي للجهاز (.toLocal)
  final prayers = [
    PrayerItem(name: "الفجر", time: adhan.fajr.toLocal()),
    PrayerItem(name: "الظهر", time: adhan.dhuhr.toLocal()),
    PrayerItem(name: "العصر", time: adhan.asr.toLocal()),
    PrayerItem(name: "المغرب", time: adhan.maghrib.toLocal()),
    PrayerItem(name: "العشاء", time: adhan.isha.toLocal()),
  ];

  final now = DateTime.now();
  bool found = false;

  // 5. البحث عن الصلاة القادمة بمقارنة الوقت الحالي بأوقات الصلوات
  for (final prayer in prayers) {
    // أول صلاة يكون وقتها لاحقاً للوقت الحالي تُعتبر هي الصلاة القادمة
    if (!found && now.isBefore(prayer.time)) {
      prayer.isNext = true;
      found = true;
    }
  }

  // 6. حالة استثنائية (بعد صلاة العشاء):
  // إذا مر وقت صلاة العشاء ولم تُعثر على أي صلاة متبقية لليوم،
  // فإن الصلاة القادمة تلقائياً هي صلاة "الفجر" (لليوم التالي).
  if (!found) {
    prayers.first.isNext = true;
  }

  return PrayerTimesModel(prayers: prayers);
}
