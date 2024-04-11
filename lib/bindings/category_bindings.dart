import 'package:drivers/controller/category_controller.dart';
import 'package:drivers/controller/home_controller.dart';
import 'package:drivers/controller/user_controller.dart';
import 'package:get/get.dart';

class CategoryBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CategoryController());
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => UserController());
  }
}
