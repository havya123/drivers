import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:drivers/app/route/route_name.dart';
import 'package:drivers/app/store/app_store.dart';
import 'package:drivers/app/store/services.dart';
import 'package:drivers/app/util/key.dart';
import 'package:drivers/extension/snackbar.dart';
import 'package:drivers/firebase_service/notification_service.dart';
import 'package:drivers/model/device_token.dart';
import 'package:drivers/model/parcel.dart';
import 'package:drivers/repository/device_token_repo.dart';
import 'package:drivers/repository/parcel_repo.dart';
import 'package:drivers/repository/request_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:url_launcher/url_launcher.dart' as urlLauncher;

class DeliveryMultiController extends GetxController {
  RxList<Marker> listMarkers = <Marker>[].obs;
  Rx<LatLng>? currentPosition;
  RxDouble zoom = 15.0.obs;
  GoogleMapController? myController;
  RxBool waiting = true.obs;
  PolylinePoints polylinePoints = PolylinePoints();
  late Uint8List driverIcon;
  late Uint8List parcelIcon;
  final RxSet<Polyline> polylines = <Polyline>{}.obs;
  RxBool isClose = false.obs;
  static RxBool waitingConfirm = false.obs;
  late Rx<LatLngBounds> bounds;
  Rx<XFile?> iamgeConfirm = Rx<XFile?>(null);
  // Rx<Parcel?> parcelDetail = Rx<Parcel?>(null);
  RxBool loading = false.obs;
  RxList<Map<String, dynamic>> listDestination = <Map<String, dynamic>>[].obs;
  RxString destinationSelect = "".obs;
  RxString receiverPhone = "".obs;
  RxList<String> listParcelId = <String>[].obs;
  RxString currentParcelID = "".obs;
  Rx<LatLng> currentDestinationPos = const LatLng(0, 0).obs;
  RxList<Parcel> listParcel = <Parcel>[].obs;

  @override
  Future<DeliveryMultiController> onInit() async {
    if (currentPosition == null) {
      // parcelDetail.value = await ParcelRepo()
      //     .getParcelInfor(AppStore.to.currentRequest.value!.parcelId);

      await initPosition();
      await createUserMarker();
      await getCurrentPosition();

      listDestination.value = AppStore.to.currentRequest.value.receiverAddress;
      receiverPhone.value =
          AppStore.to.currentRequest.value.receiverAddress[0]['receiverPhone'];
      destinationSelect.value = AppStore
          .to.currentRequest.value.receiverAddress[0]['receiverAddress'];
      currentDestinationPos.value = LatLng(
          AppStore.to.currentRequest.value.receiverAddress[0]['lat'],
          AppStore.to.currentRequest.value.receiverAddress[0]['lng']);

      listParcelId.value = AppStore.to.currentRequest.value.parcelId;
      currentParcelID.value = listParcelId[0];
      LatLng destinationPosition = LatLng(
          AppStore.to.currentRequest.value.receiverAddress[0]['lat'],
          AppStore.to.currentRequest.value.receiverAddress[0]['lng']);

      addDestinationMarker(destinationPosition);
      addMarker(LatLng(
          currentPosition!.value.latitude, currentPosition!.value.longitude));
      await getAllParcel();
      await drawPolyline();
      _calculateBounds();
      waiting.value = false;
    }
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

  Future<void> createUserMarker() async {
    driverIcon =
        await getImageFromMarkers("lib/app/assets/userposition.png", 80);
  }

  void addDestinationMarker(LatLng lng) {
    bool parcelMaker =
        listMarkers.any((marker) => marker.markerId.value == "Destination");
    if (parcelMaker) {
      listMarkers
          .removeWhere((marker) => marker.markerId.value == "Destination");
    }
    Marker parcel = Marker(
        markerId: const MarkerId("Destination"),
        position: lng,
        infoWindow: const InfoWindow(title: "Destination"));
    listMarkers.add(parcel);
  }

  void addMarker(LatLng lng) {
    bool hasMyPositionMarker =
        listMarkers.any((marker) => marker.markerId.value == "My Position");
    if (hasMyPositionMarker) {
      listMarkers
          .removeWhere((marker) => marker.markerId.value == "My Position");
    }

    Marker myMarker = Marker(
        icon: BitmapDescriptor.fromBytes(driverIcon),
        markerId: const MarkerId("My Position"),
        position: lng,
        infoWindow: const InfoWindow(title: "My Position"));

    listMarkers.add(myMarker);
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

  Future<void> getCurrentPosition() async {
    try {
      Geolocator.getPositionStream(
              locationSettings: const LocationSettings(
                  accuracy: LocationAccuracy.best, distanceFilter: 2))
          .listen((event) async {
        if (AppStore.to.isActive.value) {
          Geofire.setLocation(
              AppStore.to.uid.value, event.latitude, event.longitude);
        }
        currentPosition!.value = LatLng(event.latitude, event.longitude);
        addMarker(LatLng(
            currentPosition!.value.latitude, currentPosition!.value.longitude));

        moveCamera(currentPosition!.value);
        await drawPolyline();
        checkDistance();
      });

      moveCamera(currentPosition!.value);
    } catch (e) {
      return MyDialogs.error(
          msg: "Something went wrong. Please try again later");
    }
  }

  Future<void> drawPolyline() async {
    try {
      List<LatLng> polylineCoordinates = [];
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        MyKey.ggApiKey,
        PointLatLng(listMarkers[0].position.latitude,
            listMarkers[0].position.longitude),
        PointLatLng(listMarkers[1].position.latitude,
            listMarkers[1].position.longitude),
        travelMode: TravelMode.driving,
      );
      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
      }

      Polyline polyline = Polyline(
          polylineId: const PolylineId('nearest_neighbor_polyline'),
          color: Colors.blue,
          points: polylineCoordinates,
          width: 3);

      polylines.add(polyline);
    } catch (e) {
      print(e);
    }
  }

  void checkDistance() {
    double distance = calculateDistance(
        currentPosition!.value.latitude,
        currentPosition!.value.longitude,
        currentDestinationPos.value.latitude,
        currentDestinationPos.value.longitude);
    if (distance > 0.05) {
      isClose.value = false;
    } else {
      isClose.value = true;
    }
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  Future<void> pickUpSuccess() async {
    try {
      // await RequestRepo().updateStatus(
      //     AppStore.to.currentRequest.value!.requestId, 'on delivery');
      DeviceTokenModel receiverToken = await DeviceTokenRepo()
          .getDeviceToken(AppStore.to.currentRequest.value!.userId);
      // AppStore.to.currentRequest.value!.statusRequest = 'on delivery';
      await NotificationService().sendNotification(
          receiverToken.deviceToken,
          "Driver is coming",
          "Delivery man has picked up your order. Please comfirm to start delivery");
      waitingConfirm.value = true;
    } catch (e) {}
  }

  Future<void> openGoogleMapsDirections() async {
    LatLng userPosition = LatLng(
        currentPosition!.value.latitude, currentPosition!.value.longitude);
    LatLng destination = listMarkers[1].position;

    String url =
        'https://www.google.com/maps/dir/?api=1&origin=${userPosition.latitude},${userPosition.longitude}&destination=${destination.latitude},${destination.longitude}';

    await urlLauncher.launchUrl(Uri.parse(url));
  }

  void _calculateBounds() {
    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLong = double.infinity;
    double maxLong = -double.infinity;

    for (final marker in listMarkers) {
      final lat = marker.position.latitude;
      final long = marker.position.longitude;
      minLat = lat < minLat ? lat : minLat;
      maxLat = lat > maxLat ? lat : maxLat;
      minLong = long < minLong ? long : minLong;
      maxLong = long > maxLong ? long : maxLong;
    }

    bounds = LatLngBounds(
      southwest: LatLng(minLat, minLong),
      northeast: LatLng(maxLat, maxLong),
    ).obs;

    _moveCameraToFitBounds();
  }

  void _moveCameraToFitBounds() {
    if (myController != null) {
      final CameraUpdate cameraUpdate =
          CameraUpdate.newLatLngBounds(bounds.value, 50);
      myController!.animateCamera(cameraUpdate);
    }
  }

  Future<void> pickImageFromGallery() async {
    var status = await Permission.storage.request();
    if (status.isDenied) {
      await Permission.storage.request();
    }
    final returnImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnImage == null) return;
    iamgeConfirm.value = returnImage;
  }

  Future<void> pickImageFromCamera() async {
    var status = await Permission.camera.request();
    if (status.isDenied) {
      return Future.error("Storage permission is denied");
    }
    final returnImage =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (returnImage == null) return;
    iamgeConfirm.value = returnImage;
  }

  void deleteImage(int index) {
    iamgeConfirm.value = null;
  }

  Future<void> deliveryDone() async {
    MyDialogs.showProgress();
    // loading.value = true;
    await ParcelRepo().uploadImage(currentParcelID.value, iamgeConfirm.value!);
    if (listDestination.isNotEmpty) {
      AppStore.to.listDone.add(destinationSelect.value);
      AppServices.to
          .setString(MyKey.listDone, jsonEncode(AppStore.to.listDone));

      if (containsAll()) {
        await RequestRepo().updateStatusMulti(
            AppStore.to.currentRequest.value!.requestId, "success");
        DeviceTokenModel deviceTokenModel = await DeviceTokenRepo()
            .getDeviceToken(AppStore.to.currentRequest.value!.userId);
        await NotificationService().sendNotification(
            deviceTokenModel.deviceToken,
            "Complete delivery",
            "Complete delivery");
        AppStore.to.currentRequest.value = null;
        AppServices.to.removeString(MyKey.currentRequest);
        AppServices.to.removeString(MyKey.onDelivery);
        AppStore.to.onDelivery.value = false;
        AppStore.to.listDone.clear();
        AppServices.to.removeString(MyKey.listDone);

        loading.value = false;
        MyDialogs.dialogInfo(
            context: Get.context!,
            msg: "Congratulation!!!",
            body: const Text("You have deliveried all parcels successfully"));
        Future.delayed(const Duration(seconds: 1),
            () => Get.offNamed(RouteName.categoryRoute));
        return;
      }
      Get.back();
      Get.back();
      return;
    }
  }

  void onSelectDestination(String newDestination, int index) async {
    destinationSelect.value = newDestination;
    receiverPhone.value = AppStore
        .to.currentRequest.value.receiverAddress[index]['receiverPhone'];
    currentParcelID.value = listParcelId[index];
    currentDestinationPos.value = LatLng(
        AppStore.to.currentRequest.value.receiverAddress[index]['lat'],
        AppStore.to.currentRequest.value.receiverAddress[index]['lng']);
    polylines.clear();
    addDestinationMarker(currentDestinationPos.value);
    await drawPolyline();
    _calculateBounds();
  }

  Future<void> getAllParcel() async {
    for (var parcelId in listParcelId) {
      Parcel parcel = await ParcelRepo().getParcelInfor(parcelId);
      listParcel.add(parcel);
    }
  }

  Future<Parcel> getParcelImageConfirm(int index) async {
    return await ParcelRepo().getParcelInfor(listParcelId[index]);
  }

  bool containsAll() {
    for (var destination in listDestination) {
      if (!AppStore.to.listDone.contains(destination['receiverAddress'])) {
        return false;
      }
    }
    return true;
  }
}
