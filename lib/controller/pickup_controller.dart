import 'dart:ui' as ui;
import 'package:drivers/app/store/app_store.dart';
import 'package:drivers/app/util/key.dart';
import 'package:drivers/extension/snackbar.dart';
import 'package:drivers/firebase_service/notification_service.dart';
import 'package:drivers/model/device_token.dart';
import 'package:drivers/model/parcel.dart';
import 'package:drivers/model/request.dart';
import 'package:drivers/model/request_multi.dart';
import 'package:drivers/repository/device_token_repo.dart';
import 'package:drivers/repository/parcel_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' show cos, sqrt, asin;
import 'package:url_launcher/url_launcher.dart' as urlLaunch;

class PickupController extends GetxController {
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
  Rx<Parcel?> parcelDetail = Rx<Parcel?>(null);

  @override
  Future<PickupController> onInit() async {
    if (currentPosition == null) {
      if (AppStore.to.currentRequest.value is Request) {
        parcelDetail.value = await ParcelRepo()
            .getParcelInfor(AppStore.to.currentRequest.value!.parcelId);
        await initPosition();
        await createUserMarker();
        LatLng parcelPosition = LatLng(
            AppStore.to.currentRequest.value!.senderAddress['lat'],
            AppStore.to.currentRequest.value!.senderAddress['lng']);
        addMarker(LatLng(
            currentPosition!.value.latitude, currentPosition!.value.longitude));
        addParcelMarker(parcelPosition);
        await getCurrentPosition();
        await drawPolyline();
        // await getPlaceByAttitude(
        //     "${currentPosition?.value.latitude},${currentPosition?.value.longitude}");
        waiting.value = false;
        return this;
      }
      if (AppStore.to.currentRequest.value is RequestMulti) {
        await initPosition();
        await createUserMarker();
        LatLng parcelPosition = LatLng(
            AppStore.to.currentRequest.value!.senderAddress['lat'],
            AppStore.to.currentRequest.value!.senderAddress['lng']);
        addMarker(LatLng(
            currentPosition!.value.latitude, currentPosition!.value.longitude));
        addParcelMarker(parcelPosition);
        await getCurrentPosition();
        await drawPolyline();
        waiting.value = false;
        return this;
      }
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
      waiting.value = false;
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
        await getImageFromMarkers("lib/app/assets/userposition.png", 60);
    parcelIcon = await getImageFromMarkers("lib/app/assets/parcels.png", 60);
  }

  void addParcelMarker(LatLng lng) {
    bool parcelMaker =
        listMarkers.any((marker) => marker.markerId.value == "Parcel");
    if (parcelMaker) {
      listMarkers.removeWhere((marker) => marker.markerId.value == "Parcel");
    }
    Marker parcel = Marker(
        icon: BitmapDescriptor.fromBytes(parcelIcon),
        markerId: const MarkerId("Parcel"),
        position: lng,
        infoWindow: const InfoWindow(title: "Parcel"));
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
          .listen((event) {
        if (AppStore.to.isActive.value) {
          Geofire.setLocation(
              AppStore.to.uid.value, event.latitude, event.longitude);
        }
        currentPosition!.value = LatLng(event.latitude, event.longitude);
        addMarker(LatLng(
            currentPosition!.value.latitude, currentPosition!.value.longitude));

        moveCamera(currentPosition!.value);
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
        AppStore.to.currentRequest.value!.senderAddress['lat'],
        AppStore.to.currentRequest.value!.senderAddress['lng']);
    if (distance > 0.2) {
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
    LatLng destination = LatLng(
        AppStore.to.currentRequest.value!.senderAddress['lat'],
        AppStore.to.currentRequest.value!.senderAddress['lng']);

    String url =
        'https://www.google.com/maps/dir/?api=1&origin=${userPosition.latitude},${userPosition.longitude}&destination=${destination.latitude},${destination.longitude}';

    await urlLaunch.launchUrl(Uri.parse(url));
  }

  void showModalBottom(context) {}
}
