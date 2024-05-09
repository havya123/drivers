import 'package:drivers/screens/history_screen/history_screen.dart';
import 'package:drivers/screens/home_screen/home_screen.dart';
import 'package:drivers/screens/profile_screen/profile_screen.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

class CategoryController extends GetxController {
  List<Widget> listWidget = [
    const HomeScreen(),
    const HistoryScreen(),
    // const ProfileScreen(),
  ];

  final PersistentTabController controller = PersistentTabController();

  final List<PersistentBottomNavBarItem> items = [
    PersistentBottomNavBarItem(
        icon: const Icon(Icons.home),
        inactiveColorPrimary: const Color(0xff67686D),
        activeColorPrimary: Colors.blue),
    PersistentBottomNavBarItem(
        icon: const Icon(Icons.history),
        inactiveColorPrimary: const Color(0xff67686D),
        activeColorPrimary: Colors.blue),
    // PersistentBottomNavBarItem(
    //     icon: const Icon(Icons.person),
    //     inactiveColorPrimary: const Color(0xff67686D),
    //     activeColorPrimary: Colors.blue),
  ];
}
