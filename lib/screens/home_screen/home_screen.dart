import 'package:drivers/app/route/route_name.dart';
import 'package:drivers/app/store/app_store.dart';
import 'package:drivers/app/util/const.dart';
import 'package:drivers/controller/home_controller.dart';
import 'package:drivers/extension/snackbar.dart';
import 'package:drivers/model/request.dart';
import 'package:drivers/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        return !controller.waiting.value
            ? SafeArea(
                child: Stack(
                  children: [
                    GoogleMap(
                      markers: Set<Marker>.of(controller.listMarkers),
                      mapType: MapType.normal,
                      initialCameraPosition: CameraPosition(
                          target: controller.currentPosition?.value ??
                              const LatLng(
                                  10.82411061294854, 106.62992475965073),
                          zoom: controller.zoom.value),
                      onMapCreated: (clr) {
                        controller.myController = clr;
                      },
                      onCameraMove: (position) {
                        controller.zoom.value = position.zoom;
                      },
                    ),
                    Positioned(
                      bottom: getHeight(context, height: 0.15),
                      right: getWidth(context, width: 0.02),
                      child: IconButton(
                        onPressed: () => controller.getCurrentPosition(),
                        icon: const Icon(Icons.location_searching),
                      ),
                    ),
                    Positioned(
                      top: getHeight(context),
                      right: getWidth(context, width: 0.02),
                      child: IconButton(
                        onPressed: () {
                          if (AppStore.to.isActive.value) {
                            controller.driverIsOffLineNow();
                          } else {
                            controller.isOnline();
                            // controller.updateDriverLocationRealTime();
                          }
                        },
                        icon: const Icon(Icons.power_settings_new_rounded),
                      ),
                    ),
                    Obx(() {
                      if (controller.newRequestComing.value.isEmpty) {
                        return const SizedBox();
                      }
                      if (!controller.timeup.value &&
                          controller.available.value) {
                        return Container(
                            width: getWidth(context, width: 1),
                            height: getHeight(context, height: 1),
                            color: Colors.black87,
                            child: FutureBuilder(
                              future: controller.getRequestInformation(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                if (snapshot.data == null) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else {
                                  Request request = snapshot.data as Request;
                                  controller.newRequest.value = request;
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: getWidth(context, width: 0.8),
                                        height: getHeight(context, height: 0.1),
                                        color: Colors.black,
                                        child: Center(
                                          child: Text(
                                            "${request.cost.toString()}VND",
                                            style: largeTextStyle(context,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                      spaceHeight(context),
                                      Center(
                                        child: Container(
                                          width: getWidth(context, width: 0.8),
                                          height:
                                              getHeight(context, height: 0.57),
                                          clipBehavior: Clip.hardEdge,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: Colors.white,
                                          ),
                                          child: Column(
                                            children: [
                                              Container(
                                                width:
                                                    getWidth(context, width: 1),
                                                height: getHeight(context,
                                                    height: 0.1),
                                                color: Colors.grey.shade300,
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        "Km",
                                                        style: mediumTextStyle(
                                                            context),
                                                      ),
                                                      Text(
                                                        request.type,
                                                        style: mediumTextStyle(
                                                            context),
                                                      ),
                                                      Text(
                                                        request.paymentMethod,
                                                        style: mediumTextStyle(
                                                            context),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width:
                                                    getWidth(context, width: 1),
                                                height: getHeight(context,
                                                    height: 0.1),
                                                child: Text(
                                                    request.senderAddress[
                                                        'senderAddres'],
                                                    textAlign: TextAlign.center,
                                                    style: smallTextStyle(
                                                      context,
                                                    )),
                                              ),
                                              for (int i = 0; i < 2; i++) ...[
                                                Icon(
                                                  Icons.arrow_drop_down,
                                                  size: 40,
                                                  color: green,
                                                ),
                                              ],
                                              Container(
                                                width:
                                                    getWidth(context, width: 1),
                                                height: getHeight(context,
                                                    height: 0.1),
                                                color: Colors.grey.shade300,
                                                child: Text(
                                                  request.receiverAddress[
                                                      'receiverAddress'],
                                                  textAlign: TextAlign.center,
                                                  style:
                                                      smallTextStyle(context),
                                                ),
                                              ),
                                              spaceHeight(context,
                                                  height: 0.08),
                                              Obx(() {
                                                return Expanded(
                                                  child: ButtonWidget(
                                                    function: () async {
                                                      await controller
                                                          .acceptRequest();
                                                      Get.toNamed(RouteName
                                                          .pickupRoute);
                                                    },
                                                    borderRadius: 0,
                                                    textButton:
                                                        "Accept the request ${controller.second.value}",
                                                  ),
                                                );
                                              })
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              },
                            ));
                      }
                      controller.newRequestComing.value = '';
                      controller.resetCountDown();
                      return const SizedBox();
                    }),
                    Obx(() {
                      return !AppStore.to.isActive.value
                          ? Positioned(
                              top: 0,
                              child: Container(
                                width: getWidth(context, width: 1),
                                height: getHeight(context, height: 1),
                                color: Colors.black87,
                                child: Stack(
                                  children: [
                                    Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "You're in offline mode",
                                        style: smallTextStyle(context,
                                            color: Colors.white),
                                      ),
                                    ),
                                    Positioned(
                                      top: getHeight(context),
                                      right: getWidth(context, width: 0.04),
                                      child: IconButton(
                                        onPressed: () async {
                                          if (AppStore.to.isActive.value) {
                                            await controller
                                                .driverIsOffLineNow();
                                          } else {
                                            await controller.isOnline();
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.power_settings_new_rounded,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          : const SizedBox();
                    })
                  ],
                ),
              )
            : const Center(
                child: CircularProgressIndicator(),
              );
      }),
    );
  }
}
