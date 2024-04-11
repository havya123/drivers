import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:drivers/app/store/app_store.dart';
import 'package:drivers/app/store/services.dart';
import 'package:drivers/app/util/key.dart';
import 'package:drivers/firebase_service/notification_service.dart';
import 'package:drivers/model/device_token.dart';
import 'package:drivers/model/place.dart';
import 'package:drivers/model/request.dart';
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
  Rx<Request?> newRequest = Rx<Request?>(null);

  late Uint8List iconMarker;
  RxString newRequestComing = "".obs;
  RxInt second = 30.obs;
  RxBool timeup = false.obs;
  Timer? _timer;
  RxBool available = true.obs;

  void startCountDown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (second.value == 0) {
        timeup.value = true;
        DeviceTokenModel deviceTokenModel =
            await DeviceTokenRepo().getDeviceToken(newRequest.value!.userId);
        await NotificationService()
            .declineRequest(deviceTokenModel.deviceToken);
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
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$keyword&key=AIzaSyCYyiIDdbZMRqbLG0VMfR-go_5sO-JN6Dc";

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

  Future<Request?> getRequestInformation() async {
    Request? request = await RequestRepo().getRequest(newRequestComing.value);
    if (request != null) {
      startCountDown();
      return request;
    }
    return null;
  }

  Future<void> acceptRequest() async {
    try {
      if (second.value != 0) {
        await RequestRepo()
            .updateDriverRequest(newRequestComing.value, AppStore.to.uid.value);

        await RequestRepo().updateStatus(newRequestComing.value, 'on taking');

        available.value = false;

        Request newRequest =
            await RequestRepo().getRequest(newRequestComing.value) as Request;
        DeviceTokenModel receiverToken =
            await DeviceTokenRepo().getDeviceToken(newRequest.userId);

        await NotificationService().sendNotification(
            receiverToken.deviceToken, "Request Accept", AppStore.to.uid.value);

        AppStore.to.currentRequest.value = newRequest;
        await AppServices.to
            .setString(MyKey.currentRequest, newRequest.requestId);
        AppStore.to.onDelivery.value = true;
        await AppServices.to.setString(
            MyKey.onDelivery, jsonEncode(AppStore.to.onDelivery.value));
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
