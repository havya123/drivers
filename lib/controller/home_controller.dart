import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drivers/app/route/route_name.dart';
import 'package:drivers/app/store/app_store.dart';
import 'package:drivers/app/store/services.dart';
import 'package:drivers/app/util/key.dart';
import 'package:drivers/firebase_service/notification_service.dart';
import 'package:drivers/model/device_token.dart';
import 'package:drivers/model/place.dart';
import 'package:drivers/model/request.dart';
import 'package:drivers/model/request_multi.dart';
import 'package:drivers/repository/device_token_repo.dart';
import 'package:drivers/repository/request_repo.dart';
import 'package:drivers/repository/user_repo.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:http/http.dart' as http;
import 'package:drivers/extension/snackbar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeController extends GetxController {
  static HomeController get to => Get.find<HomeController>();

  GoogleMapController? myController;
  Rx<LatLng>? currentPosition;
  RxDouble zoom = 17.0.obs;
  final RxList<Marker> listMarkers = <Marker>[].obs;
  Rx<Place?> myPlace = Rx<Place?>(null);
  RxBool waiting = true.obs;
  Rx<dynamic> newRequest = Rx<dynamic>(dynamic);
  RxList<Request> listRequestSaving = <Request>[].obs;

  late Uint8List iconMarker;
  RxString newRequestComing = "".obs;
  RxString requestType = "".obs;

  RxInt second = 30.obs;
  RxBool timeup = false.obs;
  Timer? _timer;
  RxBool available = true.obs;

  void changeToDefaultMode() {
    AppStore.to.mode.value = "express";
    AppServices.to.setString(MyKey.modeSaved, AppStore.to.mode.value);
  }

  void changeToSavingMode() {
    AppStore.to.mode.value = "saving";
    AppServices.to.setString(MyKey.modeSaved, AppStore.to.mode.value);
  }

  void startCountDown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (second.value == 0) {
        timeup.value = true;
        if (newRequest is Request) {
          DeviceTokenModel deviceTokenModel =
              await DeviceTokenRepo().getDeviceToken(newRequest.value!.userId);
          await NotificationService()
              .declineRequest(deviceTokenModel.deviceToken);
        }
        if (newRequest is RequestMulti) {
          DeviceTokenModel deviceTokenModel =
              await DeviceTokenRepo().getDeviceToken(newRequest.value!.userId);
          await NotificationService()
              .declineRequest(deviceTokenModel.deviceToken);
        }
        newRequest.value = null;
        _timer?.cancel();
        return;
      }
      second.value--;
    });
  }

  void resetCountDown() async {
    _timer?.cancel();
    second.value = 30;
    timeup.value = false;
  }

  @override
  Future<HomeController> onInit() async {
    super.onInit();
    // if (AppStore.to.deviceToken.isEmpty) {
    //}

    if (AppStore.to.initUser.value == false) {
      await AppStore.to.saveUser(AppStore.to.uid.value);
    }

    if (AppStore.to.isActive.value == false) {
      await createUserMarker();
      waiting.value = false;
      return this;
    }
    listRequestSaving = AppStore.to.listRequestSaving;

    await initPosition();
    await createUserMarker();
    await getCurrentPosition();
    // await getPlaceByAttitude(
    //     "${currentPosition?.value.latitude},${currentPosition?.value.longitude}");
    waiting.value = false;

    return this;
  }

  Future<void> initPosition() async {
    try {
      Position latlng = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      currentPosition = LatLng(latlng.latitude, latlng.longitude).obs;
      await Geofire.initialize("activeDrivers");
      await Geofire.setLocation(AppStore.to.uid.value,
          currentPosition!.value.latitude, currentPosition!.value.longitude);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> isOnline() async {
    try {
      await initPosition();
      await getCurrentPosition();
      AppStore.to.isActive.value = true;
      DriverRepo().isOnline(AppStore.to.uid.value, AppStore.to.isActive.value);

      // await DriverRepo()
      //     .updateStatus(AppStore.to.uid.value, AppStore.to.isActive.value);
      // updateDriverLocationRealTime();
    } catch (e) {
      rethrow;
    }
  }

  // void isOffline() async {
  //   try {
  //     AppStore.to.isActive.value = false;
  //     await DriverRepo()
  //         .updateStatus(AppStore.to.uid.value, AppStore.to.isActive.value);
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  driverIsOffLineNow() {
    Geofire.removeLocation(AppStore.to.uid.value);
    Geofire.stopListener();
    try {
      AppStore.to.isActive.value = false;
      DriverRepo().ifOffLine(AppStore.to.uid.value, AppStore.to.isActive.value);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getCurrentPosition() async {
    try {
      Geolocator.getPositionStream(
              locationSettings: const LocationSettings(
                  accuracy: LocationAccuracy.best, distanceFilter: 2))
          .listen((event) {
        if (AppStore.to.isActive.value) {
          Geofire.setLocation(
              AppStore.to.uid.value, event.latitude, event.longitude);
        }
        currentPosition!.value = LatLng(event.latitude, event.longitude);
        addMarker(LatLng(
            currentPosition!.value.latitude, currentPosition!.value.longitude));

        moveCamera(currentPosition!.value);
      });
      addMarker(LatLng(
          currentPosition!.value.latitude, currentPosition!.value.longitude));
      moveCamera(currentPosition!.value);
    } catch (e) {
      return MyDialogs.error(
          msg: "Something went wrong. Please try again later");
    }
  }

  Future<void> createUserMarker() async {
    iconMarker =
        await getImageFromMarkers("lib/app/assets/userposition.png", 80);
  }

  void addMarker(LatLng lng) {
    bool hasMyPositionMarker =
        listMarkers.any((marker) => marker.markerId.value == "My Position");
    if (hasMyPositionMarker) {
      listMarkers
          .removeWhere((marker) => marker.markerId.value == "My Position");
    }

    Marker myMarker = Marker(
        icon: BitmapDescriptor.fromBytes(iconMarker),
        markerId: const MarkerId("My Position"),
        position: lng,
        infoWindow: const InfoWindow(title: "My Position"));
    listMarkers.add(myMarker);
  }

  Future<Uint8List> getImageFromMarkers(String path, int width) async {
    ByteData byteData = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
        byteData.buffer.asUint8List(),
        targetHeight: width);
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    return (await frameInfo.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  void moveCamera(LatLng lng) {
    try {
      myController?.animateCamera(
        CameraUpdate.newLatLng(lng),
      );
    } catch (e) {
      MyDialogs.error(msg: "Something went wrong");
    }
  }

  Future<void> getPlaceByAttitude(String keyword) async {
    final String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$keyword&key=MyKey.ggApiKey";

    final uri = Uri.parse(url);
    var response = await http.get(uri);
    Map<String, dynamic> data = jsonDecode(response.body);
    List location = data['results'];
    if (location.isEmpty) {
      return;
    }
    Map<String, dynamic> dataLocation = location[0];
    myPlace.value = Place(
        name: dataLocation['address_components'][1]['long_name'],
        address: dataLocation['formatted_address'],
        lat: dataLocation['geometry']['location']['lat'],
        lng: dataLocation['geometry']['location']['lng']);
  }

  Future<RequestMulti?> getRequestMultiInfor() async {
    RequestMulti? requestMulti =
        await RequestRepo().getRequestMulti(newRequestComing.value);
    if (requestMulti != null) {
      startCountDown();
      return requestMulti;
    }
    return null;
  }

  Future<Request?> getRequestInformation() async {
    Request? request = await RequestRepo().getRequest(newRequestComing.value);
    if (request != null) {
      startCountDown();
      return request;
    }
    return null;
  }

  Future<void> acceptRequestMulti() async {
    try {
      if (second.value != 0) {
        await RequestRepo().updateDriverRequestMulti(
            newRequestComing.value, AppStore.to.uid.value);
        await RequestRepo()
            .updateStatusMulti(newRequestComing.value, 'on taking');
        available.value = false;

        DeviceTokenModel receiverToken =
            await DeviceTokenRepo().getDeviceToken(newRequest.value.userId);

        await NotificationService().sendNotification(
            receiverToken.deviceToken, "Request Accept", AppStore.to.uid.value);

        Map<String, dynamic> currentRequest = {
          'requestId': newRequest.value.requestId,
          'requestType': 'requestMulti'
        };

        AppStore.to.currentRequest.value = newRequest.value;
        AppServices.to
            .setString(MyKey.currentRequest, jsonEncode(currentRequest));
        AppStore.to.onDelivery.value = true;
        AppServices.to.setString(
            MyKey.onDelivery, jsonEncode(AppStore.to.onDelivery.value));
      }
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        newRequestComing.value == "";

        requestType.value == "";
        MyDialogs.error(msg: "It seems like customer has canceled the request");
      }
      rethrow;
    }
  }

  Future<void> acceptRequestSaving() async {
    MyDialogs.showProgress();
    if (listRequestSaving.length <= 5) {
      if (second.value != 0) {
        await RequestRepo()
            .updateDriverRequest(newRequestComing.value, AppStore.to.uid.value);
        await RequestRepo().updateStatus(newRequestComing.value, 'on taking');
        Request? request =
            await RequestRepo().getRequest(newRequestComing.value);

        if (request != null) {
          listRequestSaving.add(request);
          DeviceTokenModel receiverToken =
              await DeviceTokenRepo().getDeviceToken(request.userId);

          await NotificationService().sendNotification(
              receiverToken.deviceToken,
              "Request Accept",
              AppStore.to.uid.value);
        }
        newRequestComing.value = "";
        AppServices.to.setString(
            MyKey.listRequestSaving, jsonEncode(listRequestSaving.toList()));
        Get.back();
      }
    } else {
      MyDialogs.error(msg: "You can only receive maximum 5 orders.");
      return;
    }
  }

  Future<void> acceptRequest() async {
    try {
      if (second.value != 0) {
        await RequestRepo()
            .updateDriverRequest(newRequestComing.value, AppStore.to.uid.value);

        await RequestRepo().updateStatus(newRequestComing.value, 'on taking');

        available.value = false;

        // Request newRequest =
        //     await RequestRepo().getRequest(newRequestComing.value) as Request;
        DeviceTokenModel receiverToken =
            await DeviceTokenRepo().getDeviceToken(newRequest.value.userId);

        await NotificationService().sendNotification(
            receiverToken.deviceToken, "Request Accept", AppStore.to.uid.value);

        AppStore.to.currentRequest.value = newRequest.value;
        Map<String, dynamic> currentRequest = {
          'requestId': newRequest.value.requestId,
          'requestType': 'express'
        };
        AppServices.to
            .setString(MyKey.currentRequest, jsonEncode(currentRequest));
        AppStore.to.onDelivery.value = true;
        await AppServices.to.setString(
            MyKey.onDelivery, jsonEncode(AppStore.to.onDelivery.value));
      }
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        newRequestComing.value == "";

        requestType.value == "";
        MyDialogs.error(msg: "It seems like customer has canceled the request");
      }
      rethrow;
    }
  }

  Future<void> startDelivery() async {
    try {
      for (var request in listRequestSaving) {
        DeviceTokenModel receiverToken =
            await DeviceTokenRepo().getDeviceToken(request.userId);

        await NotificationService().sendNotification(
            receiverToken.deviceToken,
            "Driver is coming. Please prepare your order",
            AppStore.to.uid.value);
      }

      Get.toNamed(RouteName.deliverySavingRoute);
    } catch (e) {}
  }

  void logout() {}
}
