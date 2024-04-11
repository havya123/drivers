import 'package:drivers/controller/delivery_controller.dart';
import 'package:get/get.dart';

class DeliveryBinding extends Bindings {
  @override
  void dependencies() async {
    var controller = DeliveryController();
    Get.lazyPut(() => controller);
    await controller.onInit();
  }
}
