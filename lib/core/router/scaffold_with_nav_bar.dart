import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),

        child: BottomNavigationBar(
          // backgroundColor: Color(0xFFFF9000),
          currentIndex: navigationShell.currentIndex,
          onTap: _onTap,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 24),
              label: 'الرئيسية',
            ),
            // BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Adhkar'),
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.favorite),
            //   label: 'Favorites',
            // ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings, size: 24),
              label: 'الإعدادات',
            ),
          ],
        ),
      ),
    );
  }
}
