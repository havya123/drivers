import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:drivers/controller/category_controller.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

class CategoryScreen extends GetView<CategoryController> {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      backgroundColor: const Color(0xff242A32),
      context,
      screens: controller.listWidget,
      items: controller.items,
      controller: controller.controller,
      resizeToAvoidBottomInset: true,
    );
  }
}
