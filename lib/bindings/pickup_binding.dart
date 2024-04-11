import 'package:drivers/controller/delivery_controller.dart';
import 'package:drivers/controller/pickup_controller.dart';
import 'package:get/get.dart';

class PickupBinding extends Bindings {
  @override
  void dependencies() async {
    var controller = PickupController();
    Get.put(controller);
    await controller.onInit();
  }
}
