import 'package:drivers/controller/delivery_saving_controller.dart';
import 'package:get/get.dart';

class DeliverySavingBinding extends Bindings {
  @override
  void dependencies() async {
    var controller = DeliverySavingController();
    Get.lazyPut(() => controller);
    await controller.init();
  }
}
