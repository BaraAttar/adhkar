import 'package:adhkar/core/router/scaffold_with_nav_bar.dart';
import 'package:adhkar/features/settings/settings_page.dart';
import 'package:adhkar/features/home/pages/home_page.dart';
import 'package:adhkar/features/home/pages/other_adhkar_page.dart';
import 'package:go_router/go_router.dart';
// import 'package:adhkar/features/home/pages/dhikr_detail_page.dart';
import 'package:adhkar/features/home/pages/dhikr_detail_page_v2.dart'; // استيراد النسخة الجديدة

final GoRouter appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomePage(),
              routes: [
                // 1. مسار صفحة التفاصيل (يستقبل الكاتيجوري الرئيسي والفرعي)
                GoRoute(
                  path: 'dhikr-detail/:category',
                  builder: (context, state) {
                    final category =
                        state.pathParameters['category'] ?? 'morning';
                    // استخراج الـ subcategory من مسار الروتر كبارامتر استعلام اختياري
                    final subcategory =
                        state.uri.queryParameters['subcategory'];
                    // return DhikrDetailPage(
                    //   category: category,
                    //   subcategory: subcategory,
                    // );
                    return DhikrDetailPageV2(
                      category: category,
                      subcategory: subcategory,
                    );
                  },
                ),
                // 2. مسار صفحة الأذكار الأخرى الفرعية
                GoRoute(
                  path: 'other-adhkar',
                  builder: (context, state) => const OtherAdhkarPage(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
