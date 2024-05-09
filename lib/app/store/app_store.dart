import 'dart:convert';
import 'package:drivers/app/store/services.dart';
import 'package:drivers/app/util/key.dart';
import 'package:drivers/main.dart';
import 'package:drivers/model/driver.dart';
import 'package:drivers/model/request.dart';
import 'package:drivers/repository/request_repo.dart';
import 'package:drivers/repository/user_repo.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStore extends GetxController {
  static AppStore get to => Get.find();
  bool firstRun = false;
  Rx<Driver?> user = Rx<Driver?>(null);
  RxString userName = "".obs;
  RxString uid = "".obs;
  RxString phoneNumber = "".obs;
  RxString avatar = "".obs;
  RxBool isActive = false.obs;
  RxBool initUser = false.obs;
  RxString deviceToken = "".obs;
  Rx<dynamic> currentRequest = Rx<dynamic>(null);
  RxBool onDelivery = false.obs;
  RxString mode = "express".obs;
  RxString requestType = "".obs;
  RxList<String> listDone = <String>[].obs;
  RxList<Request> listRequestSaving = <Request>[].obs;

  Future<AppStore> init() async {
    //await clearData();
    // AppServices.to.removeString(MyKey.listArranged);
    // AppServices.to.removeString(MyKey.listDoneSaving);

    String userSaved = AppServices.to.getString(MyKey.user);

    if (userSaved.isNotEmpty) {
      String decode = jsonDecode(userSaved);
      Driver driver = Driver.fromJson(decode);
      updateUser(driver);
      deviceToken.value = AppServices.to.getString(MyKey.deviceToken);
      String modeSaved = AppServices.to.getString(MyKey.modeSaved);
      if (modeSaved.isNotEmpty) {
        mode.value = modeSaved;
      }
      if (mode.value == "express" || mode.value.isEmpty) {
        String request = AppServices.to.getString(MyKey.currentRequest);
        if (request.isNotEmpty) {
          Map<String, dynamic> request =
              jsonDecode(AppServices.to.getString(MyKey.currentRequest));
          if (request.isNotEmpty) {
            if (request['requestType'] == "express") {
              var updateRequest =
                  await RequestRepo().getRequest(request['requestId']);
              currentRequest.value = updateRequest;
              requestType.value = request['requestType'];
            } else {
              var updateRequest =
                  await RequestRepo().getRequestMulti(request['requestId']);
              currentRequest.value = updateRequest;
              requestType.value = request['requestType'];
              String getListDone = AppServices.to.getString(MyKey.listDone);
              if (getListDone.isNotEmpty) {
                listDone.value = jsonDecode(getListDone).cast<String>();
              }
            }
          }
        }
      }
      if (mode.value == "saving") {
        String listRequestsSaved =
            AppServices.to.getString(MyKey.listRequestSaving);
        if (listRequestsSaved.isNotEmpty) {
          List<dynamic> jsonList = jsonDecode(listRequestsSaved);
          listRequestSaving.value =
              jsonList.map((json) => Request.fromJson(json)).toList();
          print(listRequestSaving);
        }
        // await AppServices.to.removeString(MyKey.listDoneSaving);
      }
    }
    if (AppServices.to.getString(MyKey.onDelivery).isNotEmpty) {
      onDelivery.value = jsonDecode(AppServices.to.getString(MyKey.onDelivery));
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

      await AppServices.to.setString(MyKey.user, jsonEncode(driver));
    }
  }

  void clearUser() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.remove(MyKey.user);
  }
}
