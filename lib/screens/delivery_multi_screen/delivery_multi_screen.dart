import 'dart:io';

import 'package:drivers/app/route/route_name.dart';
import 'package:drivers/app/store/app_store.dart';
import 'package:drivers/app/util/const.dart';
import 'package:drivers/controller/delivery_multi_controller.dart';
import 'package:drivers/extension/snackbar.dart';
import 'package:drivers/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart' as urlLauncher;

class DeliveryMultiScreen extends GetView<DeliveryMultiController> {
  const DeliveryMultiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: getWidth(context, width: 1),
          height: getHeight(context, height: 1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                  flex: 3,
                  child: Container(
                    width: getWidth(context, width: 1),
                    color: const Color(0xff363A45),
                    child: Column(
                      children: [
                        Text(
                          "2. Destination",
                          style: mediumTextStyle(context,
                              color: Colors.green.shade400),
                        ),
                        spaceHeight(context),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                        title: const Center(
                                            child: Text('Destination')),
                                        content: SizedBox(
                                          height:
                                              getHeight(context, height: 0.5),
                                          width: getWidth(context, width: 0.5),
                                          child: ListView.separated(
                                              itemBuilder: (context, index) {
                                                return TextButton(
                                                  onPressed: () async {
                                                    controller.onSelectDestination(
                                                        controller.listDestination[
                                                                index]
                                                            ['receiverAddress'],
                                                        index);
                                                    controller.checkDistance();
                                                    Get.back();
                                                  },
                                                  child: Text(controller
                                                              .listDestination[
                                                          index]
                                                      ['receiverAddress']),
                                                );
                                              },
                                              separatorBuilder:
                                                  (context, index) {
                                                return spaceHeight(context);
                                              },
                                              itemCount: controller
                                                  .listDestination.length),
                                        )),
                                  );
                                },
                                child: Obx(() {
                                  return Text(
                                    controller.destinationSelect.value,
                                    textAlign: TextAlign.center,
                                    style: smallTextStyle(context,
                                        color: Colors.white),
                                  );
                                }),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: GestureDetector(
                                onTap: () =>
                                    controller.openGoogleMapsDirections(),
                                child: SizedBox(
                                  width: 35,
                                  height: 35,
                                  child: Image.asset("lib/app/assets/map.png"),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  )),
              Obx(() {
                return Expanded(
                    flex: 8,
                    child: Stack(
                      children: [
                        Container(
                          color: Colors.black38,
                          child: GoogleMap(
                            markers: Set<Marker>.of(controller.listMarkers),
                            polylines: Set<Polyline>.of(controller.polylines),
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
                        ),
                        Positioned(
                          bottom: getHeight(context, height: 0.15),
                          right: getWidth(context, width: 0.02),
                          child: IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.location_searching),
                          ),
                        ),
                        AppStore.to.listDone
                                .contains(controller.destinationSelect.value)
                            ? Positioned(
                                bottom: 0,
                                child: Container(
                                  height: getHeight(context, height: 0.7),
                                  width: getWidth(context, width: 1),
                                  color: Colors.black87,
                                  child: Center(
                                    child: Text(
                                      "You have done this trip",
                                      style: smallTextStyle(context,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox(),
                      ],
                    ));
              }),
              Obx(() {
                return Container(
                  height: getHeight(context, height: 0.2),
                  width: getWidth(context, width: 1),
                  color: const Color(0xff363A45),
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          SizedBox(
                            width: getWidth(context, width: 1),
                            height: getHeight(context, height: 0.1),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (context) {
                                          return Container(
                                            width: getWidth(context, width: 1),
                                            height:
                                                getHeight(context, height: 0.2),
                                            color: Colors.white,
                                            child: Column(
                                              children: [
                                                Expanded(
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      await urlLauncher
                                                          .launchUrl(Uri(
                                                              scheme: 'tel',
                                                              path: controller
                                                                  .receiverPhone
                                                                  .value));
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color:
                                                                  Colors.black,
                                                              width: 0.2)),
                                                      child: const Center(
                                                        child: Text(
                                                            "Call receiver"),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      await urlLauncher
                                                          .launchUrl(Uri(
                                                              scheme: 'tel',
                                                              path: AppStore
                                                                  .to
                                                                  .currentRequest
                                                                  .value!
                                                                  .senderPhone));
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color:
                                                                  Colors.black,
                                                              width: 0.2)),
                                                      child: const Center(
                                                        child:
                                                            Text("Call Sender"),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Container(
                                      height: getHeight(context, height: 0.1),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black, width: 0.5)),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            "lib/app/assets/phone-call.png",
                                            scale: 15,
                                          ),
                                          Text(
                                            "Call",
                                            style: smallTextStyle(context,
                                                color: Colors.white),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      await urlLauncher.launchUrl(Uri(
                                          scheme: 'sms',
                                          path:
                                              controller.receiverPhone.value));
                                    },
                                    child: Container(
                                      height: getHeight(context, height: 0.1),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black, width: 0.5)),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            "lib/app/assets/email.png",
                                            scale: 15,
                                          ),
                                          Text(
                                            "Message",
                                            style: smallTextStyle(context,
                                                color: Colors.white),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () =>
                                        Get.toNamed(RouteName.detailRoute),
                                    child: Container(
                                      height: getHeight(context, height: 0.1),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black, width: 0.5)),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            "lib/app/assets/information.png",
                                            scale: 15,
                                          ),
                                          Text(
                                            "Detail",
                                            style: smallTextStyle(context,
                                                color: Colors.white),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: getWidth(context, width: 1),
                            height: getHeight(context, height: 0.1),
                            child: Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: Stack(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                            flex: 2,
                                            child: Obx(() {
                                              if (controller.isClose.value) {
                                                return ButtonWidget(
                                                  function: () {
                                                    showModalBottomSheet(
                                                      context: context,
                                                      builder: (context) {
                                                        return Obx(() {
                                                          return Container(
                                                            width: getWidth(
                                                                context,
                                                                width: 1),
                                                            height: getHeight(
                                                                context,
                                                                height: controller
                                                                            .iamgeConfirm
                                                                            .value !=
                                                                        null
                                                                    ? 0.6
                                                                    : 0.15),
                                                            color: Colors.white,
                                                            child: Column(
                                                              children: [
                                                                GestureDetector(
                                                                  onTap: () =>
                                                                      controller
                                                                          .pickImageFromCamera(),
                                                                  child:
                                                                      Container(
                                                                    width: getWidth(
                                                                        context,
                                                                        width:
                                                                            1),
                                                                    height: getHeight(
                                                                        context,
                                                                        height:
                                                                            0.075),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                            border:
                                                                                Border.all(width: 0.5)),
                                                                    child:
                                                                        const Center(
                                                                      child: Text(
                                                                          "Take a confirmation photo"),
                                                                    ),
                                                                  ),
                                                                ),
                                                                GestureDetector(
                                                                  onTap: () =>
                                                                      controller
                                                                          .pickImageFromGallery(),
                                                                  child:
                                                                      Container(
                                                                    width: getWidth(
                                                                        context,
                                                                        width:
                                                                            1),
                                                                    height: getHeight(
                                                                        context,
                                                                        height:
                                                                            0.075),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      border: Border.all(
                                                                          width:
                                                                              0.5),
                                                                    ),
                                                                    child:
                                                                        const Center(
                                                                      child: Text(
                                                                          "Pick an image from gallery"),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Obx(() {
                                                                  if (controller
                                                                          .iamgeConfirm
                                                                          .value ==
                                                                      null) {
                                                                    return const SizedBox();
                                                                  }
                                                                  return SizedBox(
                                                                    width: getWidth(
                                                                        context,
                                                                        width:
                                                                            1),
                                                                    height: getHeight(
                                                                        context,
                                                                        height:
                                                                            0.35),
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        spaceHeight(
                                                                            context,
                                                                            height:
                                                                                0.02),
                                                                        SizedBox(
                                                                          width: getWidth(
                                                                              context,
                                                                              width: 1),
                                                                          height: getHeight(
                                                                              context,
                                                                              height: 0.25),
                                                                          child:
                                                                              Image.file(
                                                                            File(controller.iamgeConfirm.value!.path),
                                                                            fit:
                                                                                BoxFit.contain,
                                                                          ),
                                                                        ),
                                                                        spaceHeight(
                                                                            context,
                                                                            height:
                                                                                0.02),
                                                                        GestureDetector(
                                                                          onTap:
                                                                              () async {
                                                                            if (controller.iamgeConfirm.value ==
                                                                                null) {
                                                                              return;
                                                                            }
                                                                            await controller.deliveryDone();
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            width:
                                                                                getWidth(context, width: 0.5),
                                                                            height:
                                                                                getHeight(context, height: 0.05),
                                                                            decoration:
                                                                                BoxDecoration(border: Border.all(width: 0.5), borderRadius: BorderRadius.circular(5)),
                                                                            child:
                                                                                const Center(child: Text("Confirm")),
                                                                          ),
                                                                        )
                                                                      ],
                                                                    ),
                                                                  );
                                                                }),
                                                              ],
                                                            ),
                                                          );
                                                        });
                                                      },
                                                    );
                                                  },
                                                  borderRadius: 5,
                                                  textButton: "I arrived",
                                                );
                                              }
                                              return ButtonWidget(
                                                listColor: [
                                                  Colors.grey,
                                                  Colors.grey.shade400
                                                ],
                                                function: () {
                                                  MyDialogs.error(
                                                      msg: "Please get closer");
                                                  return;
                                                },
                                                borderRadius: 5,
                                                textButton: "I arrived",
                                              );
                                            })),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: IconButton(
                                                    onPressed: () {
                                                      showModalBottomSheet(
                                                        context: context,
                                                        builder: (context) {
                                                          return Container(
                                                            width: getWidth(
                                                                context,
                                                                width: 1),
                                                            height: getHeight(
                                                                context,
                                                                height: 0.2),
                                                            color: Colors.white,
                                                            child: Column(
                                                              children: [
                                                                Expanded(
                                                                  child:
                                                                      Container(
                                                                    decoration: BoxDecoration(
                                                                        border: Border.all(
                                                                            color:
                                                                                Colors.black,
                                                                            width: 0.2)),
                                                                    child:
                                                                        const Center(
                                                                      child: Text(
                                                                          "Receiver does not reply"),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child:
                                                                      Container(
                                                                    decoration: BoxDecoration(
                                                                        border: Border.all(
                                                                            color:
                                                                                Colors.black,
                                                                            width: 0.2)),
                                                                    child:
                                                                        const Center(
                                                                      child: Text(
                                                                          "Receiver does not want to receive order "),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                    icon: const Icon(
                                                      Icons.error,
                                                      color: Colors.white,
                                                    )),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  "Error",
                                                  style: smallTextStyle(context,
                                                      color: Colors.white),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      AppStore.to.listDone
                              .contains(controller.destinationSelect.value)
                          ? Positioned(
                              bottom: 0,
                              child: Container(
                                height: getHeight(context, height: 0.2),
                                width: getWidth(context, width: 1),
                                color: Colors.black87,
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
