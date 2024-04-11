import 'dart:convert';
import 'package:drivers/app/store/services.dart';
import 'package:drivers/app/util/key.dart';
import 'package:drivers/model/driver.dart';
import 'package:drivers/model/request.dart';
import 'package:drivers/repository/request_repo.dart';
import 'package:drivers/repository/user_repo.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStore extends GetxController {
  static AppStore get to => Get.find();
  bool firstRun = false;
  Rx<Driver?> user = Rx<Driver?>(null);
  RxString userName = "".obs;
  RxString uid = "".obs;
  RxString phoneNumber = "".obs;
  RxString avatar = "".obs;
  RxBool isExpired = true.obs;
  RxBool isActive = false.obs;
  RxBool initUser = false.obs;
  RxString deviceToken = "".obs;
  Rx<Request?> currentRequest = Rx<Request?>(null);
  RxBool onDelivery = false.obs;

  Future<AppStore> init() async {
    String tokenSaved = AppServices.to.getString(MyKey.token);

    if (tokenSaved.isNotEmpty) {
      // isExpired.value = JwtDecoder.isExpired(tokenSaved);
      // if (isExpired.value) {
      //   clearUser();
      //   return;
      // }
      // isExpired.value = false;
      String userSaved = AppServices.to.getString(MyKey.user);
      if (userSaved.isNotEmpty) {
        String decode = jsonDecode(userSaved);
        Driver driver = Driver.fromJson(decode);
        deviceToken.value = AppServices.to.getString(MyKey.deviceToken);

        updateUser(driver);
        String request = AppServices.to.getString(MyKey.currentRequest);
        if (request.isNotEmpty) {
          var updateRequest = await RequestRepo().getRequest(request);
          currentRequest.value = updateRequest;
        }
        // User user = User.fromMap(userData);
        // updateUser(user);
      }
      if (AppServices.to.getString(MyKey.onDelivery).isNotEmpty) {
        onDelivery.value =
            jsonDecode(AppServices.to.getString(MyKey.onDelivery));
      }
      // var b = jsonDecode(AppServices.to.getString(MyKey.onDelivery));
    }

    return this;
  }

  void updateUser(Driver driver) {
    user.value = driver;
    userName.value = driver.userName;
    uid.value = driver.uid;
    phoneNumber.value = driver.phoneNumber;
    avatar.value = driver.avatar;
    isActive.value = driver.active;
  }

  void updateDriverStatus() {
    isActive.value = !isActive.value;
  }

  Future<void> saveUser(String uid) async {
    Driver? driver = await DriverRepo().getUser(uid);
    if (driver != null) {
      AppStore.to.updateUser(driver);

      await AppServices.to.setString(MyKey.user, driver);
    }
  }

  void clearUser() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.remove(MyKey.user);
  }
}
