import 'package:drivers/controller/delivery_multi_controller.dart';
import 'package:get/get.dart';

class DeliveryMultiBinding extends Bindings {
  @override
  void dependencies() async {
    var controller = DeliveryMultiController();
    Get.lazyPut(() => controller);
    await controller.onInit();
  }
}
