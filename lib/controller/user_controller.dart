import 'package:drivers/app/store/services.dart';
import 'package:drivers/app/util/key.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  FirebaseMessaging fcm = FirebaseMessaging.instance;

  @override
  void onInit() async {
    await saveDeviceToken();
    super.onInit();
  }

  Future<void> saveDeviceToken() async {
    String? deviceToken = await fcm.getToken();
    if (deviceToken != null) {
      await AppServices.to.setString(MyKey.deviceToken, deviceToken);
    }
  }

  Future<void> driverUpdateStatus() async {}
}
