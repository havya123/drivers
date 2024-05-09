import 'dart:convert';

import 'package:drivers/app/route/route_name.dart';
import 'package:drivers/app/store/app_store.dart';
import 'package:drivers/app/store/services.dart';
import 'package:drivers/app/util/const.dart';
import 'package:drivers/app/util/key.dart';
import 'package:drivers/controller/home_controller.dart';
import 'package:drivers/extension/snackbar.dart';
import 'package:drivers/model/request.dart';
import 'package:drivers/screens/home_screen/detail_widget/detail_widget.dart';
import 'package:drivers/screens/home_screen/list_request_widget/list_request_widget.dart';
import 'package:drivers/screens/home_screen/new_request_multi_widget/new_request_multi_widget.dart';
import 'package:drivers/screens/home_screen/new_request_widget/new_request_widget.dart';
import 'package:drivers/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:transparent_image/transparent_image.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Obx(() {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(AppStore.to.isActive.value ? "Online " : "Offline "),
              Text("(${AppStore.to.mode.value})")
            ],
          );
        }),
        elevation: 1,
        actions: [
          IconButton(
            onPressed: () {
              if (AppStore.to.isActive.value) {
                controller.driverIsOffLineNow();
              } else {
                controller.isOnline();
              }
            },
            icon: const Icon(Icons.power_settings_new_rounded),
          ),
        ],
      ),
      drawer: Drawer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: getWidth(context, width: 1),
                height: getHeight(context, height: 0.3),
                color: Colors.green,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
                  child: Row(
                    children: [
                      Container(
                        width: getHeight(context, height: 0.1),
                        height: getHeight(context, height: 0.1),
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.white,
                        ),
                        // child: FadeInImage.memoryNetwork(
                        //     placeholder: kTransparentImage,
                        //     image: AppStore.to.avatar.value),
                      ),
                      Text(
                        AppStore.to.userName.value,
                        style: mediumTextStyle(context),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: SizedBox(
                        height: getHeight(context, height: 0.08),
                        child: Row(
                          children: [
                            Icon(
                              Icons.home,
                              size: 30,
                              color: grey,
                            ),
                            spaceWidth(context),
                            Expanded(
                              child: Text(
                                "Home Page",
                                style: smallTextStyle(context, color: grey),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: SizedBox(
                        height: getHeight(context, height: 0.08),
                        child: Row(
                          children: [
                            Icon(FontAwesomeIcons.chartColumn,
                                size: 30, color: grey),
                            spaceWidth(context),
                            Expanded(
                              child: Text(
                                "Statistic",
                                style: smallTextStyle(context, color: grey),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: SizedBox(
                        height: getHeight(context, height: 0.08),
                        child: Row(
                          children: [
                            Icon(FontAwesomeIcons.gift, size: 30, color: grey),
                            spaceWidth(context),
                            Expanded(
                              child: Text(
                                "Invite People",
                                style: smallTextStyle(context, color: grey),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: SizedBox(
                        height: getHeight(context, height: 0.08),
                        child: Row(
                          children: [
                            Icon(Icons.logout, size: 30, color: grey),
                            spaceWidth(context),
                            Expanded(
                              child: Text(
                                "Log Out",
                                style: smallTextStyle(context, color: grey),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      body: Obx(() {
        return !controller.waiting.value
            ? SafeArea(
                child: Stack(
                  children: [
                    GoogleMap(
                      onTap: (argument) {},
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
                    Obx(() {
                      if (AppStore.to.mode.value == "saving") {
                        return Positioned(
                          bottom: getHeight(context, height: 0.25),
                          right: getWidth(context, width: 0.03),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                                border: Border.all(width: 0.5),
                                color: Colors.white),
                            child: IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (contextDialog) {
                                    return Dialog(
                                      insetPadding: const EdgeInsets.all(10),
                                      child: Container(
                                        width:
                                            getWidth(contextDialog, width: 1),
                                        height: getHeight(contextDialog,
                                            height: 0.85),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 12),
                                          child: ListView.separated(
                                              itemBuilder: (context, index) {
                                                if (controller.listRequestSaving
                                                    .isEmpty) {
                                                  return const Center(
                                                    child: Text(
                                                        "You have no order "),
                                                  );
                                                }

                                                return index ==
                                                        controller
                                                            .listRequestSaving
                                                            .length
                                                    ? ButtonWidget(
                                                        borderRadius: 8,
                                                        function: () {
                                                          Get.toNamed(RouteName
                                                              .deliverySavingRoute);
                                                          HomeController
                                                              .to
                                                              .available
                                                              .value = false;
                                                          AppStore.to.onDelivery
                                                              .value = true;
                                                          AppServices.to.setString(
                                                              MyKey.onDelivery,
                                                              jsonEncode(AppStore
                                                                  .to
                                                                  .onDelivery
                                                                  .value));
                                                        },
                                                        textButton:
                                                            "Start Delivery",
                                                      )
                                                    : Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 12,
                                                                vertical: 8),
                                                        child: Container(
                                                          width: getWidth(
                                                              context,
                                                              width: 1),
                                                          height: getHeight(
                                                              context,
                                                              height: 0.3),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            border: Border.all(
                                                                width: 0.5),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        8,
                                                                    vertical:
                                                                        5),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    SizedBox(
                                                                      width: 20,
                                                                      height:
                                                                          20,
                                                                      child: Image
                                                                          .asset(
                                                                              "lib/app/assets/parcels.png"),
                                                                    ),
                                                                    spaceWidth(
                                                                        context),
                                                                    Expanded(
                                                                      child:
                                                                          Text(
                                                                        "${controller.listRequestSaving[index].senderAddress['senderAddres'].split(',').take(2).join(',')}",
                                                                        style: mediumTextStyle(
                                                                            context,
                                                                            size:
                                                                                16),
                                                                        maxLines:
                                                                            1,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          6),
                                                                  child: Column(
                                                                    children: [
                                                                      for (int i =
                                                                              0;
                                                                          i < 5;
                                                                          i++) ...<Widget>[
                                                                        spaceHeight(
                                                                            context,
                                                                            height:
                                                                                0.01),
                                                                        Icon(
                                                                          Icons
                                                                              .rectangle,
                                                                          size:
                                                                              5,
                                                                          color: Colors
                                                                              .grey
                                                                              .shade300,
                                                                        ),
                                                                      ],
                                                                    ],
                                                                  ),
                                                                ),
                                                                spaceHeight(
                                                                    context,
                                                                    height:
                                                                        0.01),
                                                                Row(
                                                                  children: [
                                                                    SizedBox(
                                                                      width: 20,
                                                                      height:
                                                                          20,
                                                                      child: Image
                                                                          .asset(
                                                                              "lib/app/assets/parcels.png"),
                                                                    ),
                                                                    spaceWidth(
                                                                        context),
                                                                    Expanded(
                                                                      child:
                                                                          Text(
                                                                        "${controller.listRequestSaving[index].receiverAddress['receiverAddress'].split(',').take(2).join(',')}",
                                                                        style: mediumTextStyle(
                                                                            context,
                                                                            size:
                                                                                16),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                                spaceHeight(
                                                                    contextDialog,
                                                                    height:
                                                                        0.02),
                                                                Container(
                                                                  width: getWidth(
                                                                      context,
                                                                      width: 1),
                                                                  height: 1,
                                                                  color: Colors
                                                                      .grey
                                                                      .shade400,
                                                                ),
                                                                spaceHeight(
                                                                    context,
                                                                    height:
                                                                        0.02),
                                                                Expanded(
                                                                    child: Row(
                                                                  children: [
                                                                    Text(
                                                                      "Total: ",
                                                                      style: smallTextStyle(
                                                                          context,
                                                                          color:
                                                                              const Color(0xffB8B8B8)),
                                                                    ),
                                                                    Expanded(
                                                                      child:
                                                                          Text(
                                                                        "${controller.listRequestSaving[index].cost}VND",
                                                                        style: largeTextStyle(
                                                                            context,
                                                                            size:
                                                                                18,
                                                                            color:
                                                                                const Color(0xff22AB94)),
                                                                      ),
                                                                    ),
                                                                    IconButton(
                                                                      onPressed:
                                                                          () {
                                                                        Get.to(DetailWidget(
                                                                            request:
                                                                                controller.listRequestSaving[index]));
                                                                      },
                                                                      icon: const Icon(
                                                                          Icons
                                                                              .arrow_forward_ios),
                                                                    )
                                                                  ],
                                                                ))
                                                                // spaceHeight(
                                                                //     context),
                                                                // Align(
                                                                //   alignment:
                                                                //       Alignment
                                                                //           .bottomRight,
                                                                //   child:
                                                                //       TextButton(
                                                                //           onPressed:
                                                                //               () {},
                                                                //           child:
                                                                //               Text(
                                                                //             "Tap to see detail",
                                                                //             style:
                                                                //                 smallTextStyle(context, color: Colors.blue),
                                                                //           )),
                                                                // )
                                                              ],
                                                            ),
                                                          ),
                                                        ));
                                              },
                                              separatorBuilder: (context,
                                                      index) =>
                                                  spaceHeight(contextDialog),
                                              itemCount: controller
                                                      .listRequestSaving
                                                      .length +
                                                  1),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              icon: const Icon(Icons.list),
                            ),
                          ),
                        );
                      }
                      return const SizedBox();
                    }),
                    Positioned(
                      bottom: getHeight(context, height: 0.2),
                      right: getWidth(context, width: 0.03),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(width: 0.5),
                          color: Colors.white,
                        ),
                        child: Center(
                          child: IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return Center(
                                    child: Container(
                                      width: getWidth(context, width: 0.8),
                                      height: getHeight(context, height: 0.5),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        AlertDialog(
                                                      title: const Text(
                                                          "Change to Default Express"),
                                                      content: const Text(
                                                          "Are you sure you want to proceed?"),
                                                      actions: [
                                                        TextButton(
                                                            onPressed: () {
                                                              Get.back();
                                                              Get.back();
                                                            },
                                                            child: const Text(
                                                                "Cancle")),
                                                        TextButton(
                                                            onPressed: () {
                                                              if (controller
                                                                  .listRequestSaving
                                                                  .isNotEmpty) {
                                                                MyDialogs.error(
                                                                    msg:
                                                                        "Please finish the orders before changing mode");
                                                                Navigator.pop(
                                                                    context);
                                                                Navigator.pop(
                                                                    context);
                                                                return;
                                                              }
                                                              controller
                                                                  .changeToDefaultMode();
                                                              Get.back();
                                                              Get.back();
                                                            },
                                                            child: const Text(
                                                                "Yes")),
                                                      ],
                                                      buttonPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                              horizontal: 12),
                                                    ),
                                                  );
                                                },
                                                child: SizedBox(
                                                  width: getWidth(context,
                                                      width: 1),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        "Default Express",
                                                        style: mediumTextStyle(
                                                            context,
                                                            color: Colors.blue),
                                                      ),
                                                      const Text(
                                                          "Default Express: You can receive both fast express and multistops express order")
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        AlertDialog(
                                                      title: const Text(
                                                          "Change to Saving Express"),
                                                      content: const Text(
                                                          "Are you sure you want to proceed?"),
                                                      actions: [
                                                        TextButton(
                                                            onPressed: () {
                                                              Get.back();
                                                              Get.back();
                                                            },
                                                            child: const Text(
                                                                "Cancle")),
                                                        TextButton(
                                                            onPressed: () {
                                                              controller
                                                                  .changeToSavingMode();
                                                              Get.back();
                                                              Get.back();
                                                            },
                                                            child: const Text(
                                                                "Yes")),
                                                      ],
                                                      buttonPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                              horizontal: 12),
                                                    ),
                                                  );
                                                },
                                                child: SizedBox(
                                                  width: getWidth(context,
                                                      width: 1),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        "Saving Express",
                                                        style: mediumTextStyle(
                                                            context,
                                                            color: Colors.blue),
                                                      ),
                                                      const Text(
                                                          "Saving Express: You can only receive saving express order. However, you can receive maximum 5 orders at the same time")
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            icon: const Icon(Icons.settings),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: getHeight(context, height: 0.15),
                      right: getWidth(context, width: 0.03),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            border: Border.all(width: 0.5),
                            color: Colors.white),
                        child: IconButton(
                          onPressed: () => controller.getCurrentPosition(),
                          icon: const Icon(Icons.location_searching),
                        ),
                      ),
                    ),
                    // Positioned(
                    //   top: getHeight(context),
                    //   right: getWidth(context, width: 0.02),
                    //   child: IconButton(
                    //     onPressed: () {
                    //       if (AppStore.to.isActive.value) {
                    //         controller.driverIsOffLineNow();
                    //       } else {
                    //         controller.isOnline();
                    //       }
                    //     },
                    //     icon: const Icon(Icons.power_settings_new_rounded),
                    //   ),
                    // ),
                    Obx(() {
                      if (controller.newRequestComing.value.isEmpty) {
                        return const SizedBox();
                      }
                      if (!controller.timeup.value &&
                          controller.newRequestComing.value.isNotEmpty &&
                          controller.available.value &&
                          controller.requestType.value == "requestMulti") {
                        return const NewRequestMultiWidget();
                      }
                      if (!controller.timeup.value &&
                          controller.newRequestComing.value.isNotEmpty &&
                          controller.available.value &&
                          controller.requestType.value == "express") {
                        return NewRequestWidget(
                          mode: "express",
                        );
                      }
                      if (!controller.timeup.value &&
                          controller.newRequestComing.value.isNotEmpty &&
                          controller.available.value &&
                          controller.requestType.value == "saving") {
                        return NewRequestWidget(
                          mode: "saving",
                        );
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
                                    // Positioned(
                                    //   top: getHeight(context),
                                    //   right: getWidth(context, width: 0.04),
                                    //   child: IconButton(
                                    //     onPressed: () async {
                                    //       if (AppStore.to.isActive.value) {
                                    //         await controller
                                    //             .driverIsOffLineNow();
                                    //       } else {
                                    //         await controller.isOnline();
                                    //       }
                                    //     },
                                    //     icon: const Icon(
                                    //       Icons.power_settings_new_rounded,
                                    //       color: Colors.white,
                                    //     ),
                                    //   ),
                                    // ),
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
