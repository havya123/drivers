import 'dart:convert';
import 'dart:math' as math;
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
import 'package:drivers/model/request.dart';
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
import 'package:url_launcher/url_launcher.dart' as urlLaunch;

class DeliverySavingController extends GetxController {
  // static DeliverySavingController get to => Get.find();

  RxString nameLocation = "".obs;
  RxBool isPick = true.obs;
  RxList<Request> listRequest = <Request>[].obs;
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
  RxBool waitingConfirm = false.obs;
  late Rx<LatLngBounds> bounds;
  Rx<XFile?> iamgeConfirm = Rx<XFile?>(null);
  Rx<Parcel?> parcelDetail = Rx<Parcel?>(null);
  RxBool loading = false.obs;
  RxList<LatLng> listPointArranged = <LatLng>[].obs;
  Rx<Request?> currentRequest = Rx<Request?>(null);
  int index = 0;
  RxList<String> listDestination = <String>[].obs;
  RxList<String> listDoneSaving = <String>[].obs;

  Future<DeliverySavingController> init() async {
    waiting.value = true;
    listRequest = AppStore.to.listRequestSaving;
    await initPosition();
    await getCurrentPosition();
    await createUserMarker();
    addMarker(currentPosition!.value);

    String listDoneSaved = AppServices.to.getString(MyKey.listDoneSaving);
    String listPointSaved = AppServices.to.getString(MyKey.listArranged);

    if (listDoneSaved.isNotEmpty) {
      listDoneSaving.value = jsonDecode(listDoneSaved).cast<String>();
    }
    if (listPointSaved.isNotEmpty) {
      Map<String, dynamic> listPointDecode = jsonDecode(listPointSaved);

      List<dynamic> listPoint = listPointDecode['listPointArranged'];
      for (var point in listPoint) {
        LatLng latLng = LatLng(point[0], point[1]);
        listPointArranged.add(latLng);
      }
      listDestination.value = listPointDecode['listDestination'].cast<String>();
    } else {
      optimizeRoute();
    }

    addDestinationMarker(listPointArranged[0]);
    await drawPolyline();
    if (listDoneSaving.isNotEmpty) {
      for (var des in listDestination) {
        if (listDoneSaving.contains(des)) {
          index++;
        }
      }
    }
    changeLocation();

    waiting.value = false;
    return this;
  }

  void optimizeRoute() {
    List<LatLng> listStartPoint = [];
    List<LatLng> listEndPoint = [];

    for (int i = 0; i < listRequest.length; i++) {
      listStartPoint.add(LatLng(listRequest[i].senderAddress['lat'],
          listRequest[i].senderAddress['lng']));
    }
    for (int i = 0; i < listRequest.length; i++) {
      listEndPoint.add(LatLng(listRequest[i].receiverAddress['lat'],
          listRequest[i].receiverAddress['lng']));
    }
    LatLng startPoint =
        _findNearestLatLng(currentPosition!.value, listStartPoint);

    int indexLatLng = getIndexLatLng(listStartPoint, startPoint);
    listPointArranged.add(startPoint);
    addListDestination(startPoint);

    List<LatLng> listStartPointTemp = [...listStartPoint];
    listStartPointTemp.removeAt(indexLatLng);

    List<LatLng> listTemp = [];
    listTemp.add(listEndPoint[indexLatLng]);
    listTemp.addAll(listStartPointTemp);

    while (listTemp.isNotEmpty) {
      if (listTemp.length == 1) {
        listPointArranged.add(listTemp[0]);
        addListDestination(listTemp[0]);
        break;
      }
      startPoint = _findNearestLatLng(startPoint, listTemp);
      listPointArranged.add(startPoint);
      addListDestination(startPoint);

      listTemp.remove(startPoint);

      if (listStartPoint.contains(startPoint)) {
        int indexLatLng = getIndexLatLng(listStartPoint, startPoint);
        listTemp.add(listEndPoint[indexLatLng]);
      }
    }
    Map<String, dynamic> optimize = {
      'listPointArranged': listPointArranged,
      'listDestination': listDestination
    };
    AppServices.to.setString(MyKey.listArranged, jsonEncode(optimize));
  }

  void addListDestination(LatLng destinationLatLng) {
    for (var request in listRequest) {
      if (request.senderAddress['lat'] == destinationLatLng.latitude &&
          request.senderAddress['lng'] == destinationLatLng.longitude) {
        listDestination.add(request.senderAddress['senderAddres']);
        return;
      }
      if (request.receiverAddress['lat'] == destinationLatLng.latitude &&
          request.receiverAddress['lng'] == destinationLatLng.longitude) {
        listDestination.add(request.receiverAddress['receiverAddress']);
        return;
      }
    }
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
    if (isPick.value) {
      double distance = calculateDistance(
          currentPosition!.value.latitude,
          currentPosition!.value.longitude,
          currentRequest.value!.senderAddress['lat'],
          currentRequest.value!.senderAddress['lng']);
      if (distance > 0.3) {
        isClose.value = false;
      } else {
        isClose.value = true;
      }
    } else {
      double distance = calculateDistance(
          currentPosition!.value.latitude,
          currentPosition!.value.longitude,
          currentRequest.value!.receiverAddress['lat'],
          currentRequest.value!.receiverAddress['lng']);
      if (distance > 0.3) {
        isClose.value = false;
      } else {
        isClose.value = true;
      }
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
        currentPosition?.value = LatLng(event.latitude, event.longitude);
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

  LatLng _findNearestLatLng(LatLng currentPoint, List<LatLng> listLatLng) {
    double minDistance = double.infinity;
    LatLng nearestLatLng = currentPoint;

    for (int i = 0; i < listLatLng.length; i++) {
      LatLng latLng = listLatLng[i];
      double distance = _calculateDistance(currentPoint, latLng);
      if (distance < minDistance) {
        minDistance = distance;
        nearestLatLng = latLng;
      }
    }

    return nearestLatLng;
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    const int earthRadius = 6371000; // Bán kính Trái đất tính bằng mét
    double lat1 = math.pi * point1.latitude / 180; // Chuyển đổi độ sang radian
    double lon1 = math.pi * point1.longitude / 180;
    double lat2 = math.pi * point2.latitude / 180;
    double lon2 = math.pi * point2.longitude / 180;

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(lat1) * math.cos(lat2) * math.pow(math.sin(dLon / 2), 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    double distance = earthRadius * c;

    return distance; // Khoảng cách tính bằng mét
  }

  int getIndexLatLng(List<LatLng> listLatLng, LatLng latLng) {
    return listLatLng.indexOf(latLng);
  }

  Future<void> openGoogleMapsDirections() async {
    LatLng userPosition = LatLng(
        currentPosition!.value.latitude, currentPosition!.value.longitude);
    LatLng destination = LatLng(currentRequest.value!.receiverAddress['lat'],
        currentRequest.value!.receiverAddress['lng']);

    String url =
        'https://www.google.com/maps/dir/?api=1&origin=${userPosition.latitude},${userPosition.longitude}&destination=${destination.latitude},${destination.longitude}';

    await urlLaunch.launchUrl(Uri.parse(url));
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

  void changeLocation() async {
    for (var request in listRequest) {
      if (request.senderAddress['lat'] == listPointArranged[index].latitude &&
          request.senderAddress['lng'] == listPointArranged[index].longitude) {
        nameLocation.value = request.senderAddress['senderAddres'];
        isPick.value = true;
        currentRequest.value = request;
        addDestinationMarker(LatLng(listPointArranged[index].latitude,
            listPointArranged[index].longitude));
        await drawPolyline();
        checkDistance();
        break;
      }
      if (request.receiverAddress['lat'] == listPointArranged[index].latitude &&
          request.receiverAddress['lng'] ==
              listPointArranged[index].longitude) {
        nameLocation.value = request.receiverAddress['receiverAddress'];
        isPick.value = false;
        currentRequest.value = request;
        addDestinationMarker(LatLng(listPointArranged[index].latitude,
            listPointArranged[index].longitude));
        await drawPolyline();
        checkDistance();
        break;
      }
    }
  }

  Future<void> pickUpSuccess() async {
    try {
      // await RequestRepo().updateStatus(
      //     AppStore.to.currentRequest.value!.requestId, 'on delivery');
      DeviceTokenModel receiverToken =
          await DeviceTokenRepo().getDeviceToken(currentRequest.value!.userId);
      // AppStore.to.currentRequest.value!.statusRequest = 'on delivery';
      await NotificationService().sendNotification(
          receiverToken.deviceToken,
          "Driver is coming",
          "Delivery man has picked up your order. Please comfirm to start delivery");
      waitingConfirm.value = true;
    } catch (e) {}
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
    await ParcelRepo()
        .uploadImage(currentRequest.value!.parcelId, iamgeConfirm.value!);
    await RequestRepo()
        .updateStatus(currentRequest.value!.requestId, "success");
    DeviceTokenModel deviceTokenModel =
        await DeviceTokenRepo().getDeviceToken(currentRequest.value!.userId);
    await NotificationService().sendNotification(
        deviceTokenModel.deviceToken, "Complete delivery", "Complete delivery");
    index++;
    if (index == listDestination.length) {
      AppStore.to.onDelivery.value = false;
      AppServices.to.removeString(MyKey.onDelivery);
      AppServices.to.removeString(MyKey.listArranged);
      AppServices.to.removeString(MyKey.listDoneSaving);
      AppServices.to.removeString(MyKey.listRequestSaving);
      Get.offNamed(RouteName.categoryRoute);
      return;
    }
    listDoneSaving
        .add(currentRequest.value!.receiverAddress['receiverAddress']);
    AppServices.to.setString(MyKey.listDoneSaving, jsonEncode(listDoneSaving));

    changeLocation();
    Get.back();
    Get.back();
  }
}
