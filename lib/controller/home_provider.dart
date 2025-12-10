// import 'package:flutter/material.dart';

// class HomeProvider with ChangeNotifier {
//   int _selectedIndex = 0;
//   String _currentTitle = 'Home';

//   final List<Map<String, dynamic>> drawerItems = [
//     {'title': 'Home', 'icon': Icons.home},
//     {'title': 'Profile', 'icon': Icons.person},
//     {'title': 'Settings', 'icon': Icons.settings},
//     {'title': 'Notifications', 'icon': Icons.notifications},
//     {'title': 'About', 'icon': Icons.info},
//   ];

//   int get selectedIndex => _selectedIndex;
//   String get currentTitle => _currentTitle;
//   void setCustomTitle(String title) {
//     _currentTitle = title;
//     notifyListeners();
//   }

//   void setIndex(int index) {
//     _selectedIndex = index;
//     _currentTitle = drawerItems[index]['title'];
//     notifyListeners();
//   }

//   void resetToHome() {
//     _selectedIndex = 0;
//     _currentTitle = 'Home';
//     notifyListeners();
//   }
// }
