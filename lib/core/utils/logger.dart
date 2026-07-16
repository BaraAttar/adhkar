import 'package:flutter/foundation.dart';

void safeLog(String message) {
  // كود فحص مسار الاستدعاء الحالي
  final trace = StackTrace.current.toString().split('\n');

  if (trace.length > 1) {
    // السطر الثاني في الـ Trace يمثل دائماً الملف الذي استدعى دالة safeLog حالياً
    final String traceLine = trace[1];

    // استخراج النص الموجود بين القوسين (الذي يحتوي على اسم الملف ورقم السطر)
    final int start = traceLine.indexOf('(');
    final int end = traceLine.indexOf(')');

    if (start != -1 && end != -1) {
      final String fileAndLine = traceLine.substring(start + 1, end);

      // طباعة النتيجة بشكل منسق وأنيق
      debugPrint(' [$fileAndLine]: $message');
      return;
    }
  }
  // في حال فشل الفحص، نطبع الرسالة بشكل عادي
  debugPrint(': $message');
}
