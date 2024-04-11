import 'package:drivers/app/store/app_store.dart';
import 'package:drivers/app/util/const.dart';
import 'package:drivers/controller/pickup_controller.dart';
import 'package:drivers/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart' as urlLauncher;

class PickupScreen extends GetView<PickupController> {
  const PickupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Obx(() {
        if (controller.waiting.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return SizedBox(
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
                          "1. Pickup Goods",
                          style: mediumTextStyle(context,
                              color: Colors.green.shade400),
                        ),
                        Text(
                          AppStore.to.currentRequest.value!
                              .senderAddress['senderAddres'],
                          maxLines: 3,
                          textAlign: TextAlign.center,
                          style: mediumTextStyle(context, color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Align(
                            alignment: Alignment.bottomRight,
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
                        ),
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
                            onPressed: () => controller.getCurrentPosition(),
                            icon: const Icon(Icons.location_searching),
                          ),
                        ),
                      ],
                    ));
              }),
              Container(
                height: getHeight(context, height: 0.2),
                width: getWidth(context, width: 1),
                color: const Color(0xff363A45),
                child: Column(
                  children: [
                    SizedBox(
                      width: getWidth(context, width: 1),
                      height: getHeight(context, height: 0.1),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                await urlLauncher.launchUrl(Uri(
                                    scheme: 'tel',
                                    path: AppStore
                                        .to.currentRequest.value!.senderPhone));
                              },
                              child: Container(
                                height: getHeight(context, height: 0.1),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.black, width: 0.5)),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                    path: AppStore
                                        .to.currentRequest.value!.senderPhone));
                              },
                              child: Container(
                                height: getHeight(context, height: 0.1),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.black, width: 0.5)),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                            child: Container(
                              height: getHeight(context, height: 0.1),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.black, width: 0.5)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
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
                        ],
                      ),
                    ),
                    SizedBox(
                      width: getWidth(context, width: 1),
                      height: getHeight(context, height: 0.1),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Stack(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Obx(() {
                                      return ButtonWidget(
                                        function: () async {
                                          if (PickupController
                                                  .waitingConfirm.value ==
                                              true) {
                                            return;
                                          }

                                          await controller.pickUpSuccess();
                                          // await controller
                                          //     .openGoogleMapsDirections();
                                        },
                                        borderRadius: 5,
                                        textButton: PickupController
                                                .waitingConfirm.value
                                            ? "Waiting for user's confirmation"
                                            : "I arrived",
                                      );
                                    }),
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        IconButton(
                                            onPressed: () {
                                              showModalBottomSheet(
                                                context: context,
                                                builder: (context) {
                                                  return Container(
                                                    width: getWidth(context,
                                                        width: 1),
                                                    height: getHeight(context,
                                                        height: 0.2),
                                                    color: Colors.white,
                                                    child: Column(
                                                      children: [
                                                        Expanded(
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .black,
                                                                    width:
                                                                        0.2)),
                                                            child: const Center(
                                                              child: Text(
                                                                  "Sender does not reply"),
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .black,
                                                                    width:
                                                                        0.2)),
                                                            child: const Center(
                                                              child: Text(
                                                                  "Sender does not want to send "),
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .black,
                                                                    width:
                                                                        0.2)),
                                                            child: const Center(
                                                              child: Text(
                                                                "Product's size is not the same with the request information ",
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
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
                                            icon: const Icon(
                                              Icons.error,
                                              color: Colors.white,
                                            )),
                                        Text(
                                          "Error",
                                          style: smallTextStyle(context,
                                              color: Colors.white),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Positioned(
                                bottom: 0,
                                child: Obx(() {
                                  if (controller.isClose.value) {
                                    return const SizedBox();
                                  } else {
                                    return Container(
                                      width: getWidth(context, width: 0.65),
                                      height: getHeight(context, height: 0.1),
                                      color: Colors.black87,
                                    );
                                  }
                                }),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      })),
    );
  }
}
