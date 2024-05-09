import 'dart:io';

import 'package:drivers/app/util/const.dart';
import 'package:drivers/controller/delivery_saving_controller.dart';
import 'package:drivers/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart' as urlLauncher;

class DestinationWidget extends StatelessWidget {
  const DestinationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<DeliverySavingController>();
    return Container(
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
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Container(
                            width: getWidth(context, width: 1),
                            height: getHeight(context, height: 0.2),
                            color: Colors.white,
                            child: Column(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      await urlLauncher.launchUrl(Uri(
                                          scheme: 'tel',
                                          path: controller.currentRequest.value!
                                              .receiverPhone));
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black, width: 0.2)),
                                      child: const Center(
                                        child: Text("Call receiver"),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      await urlLauncher.launchUrl(Uri(
                                          scheme: 'tel',
                                          path: controller.currentRequest.value!
                                              .senderPhone));
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black, width: 0.2)),
                                      child: const Center(
                                        child: Text("Call Sender"),
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
                          border: Border.all(color: Colors.black, width: 0.5)),
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
                            style: smallTextStyle(context, color: Colors.white),
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
                              controller.currentRequest.value!.receiverPhone));
                    },
                    child: Container(
                      height: getHeight(context, height: 0.1),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 0.5)),
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
                            style: smallTextStyle(context, color: Colors.white),
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
                        border: Border.all(color: Colors.black, width: 0.5)),
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
                          style: smallTextStyle(context, color: Colors.white),
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
                              if (controller.isClose.value) {
                                return ButtonWidget(
                                  function: () {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (context) {
                                        return Obx(() {
                                          return Container(
                                            width: getWidth(context, width: 1),
                                            height: getHeight(context,
                                                height: controller.iamgeConfirm
                                                            .value !=
                                                        null
                                                    ? 0.6
                                                    : 0.15),
                                            color: Colors.white,
                                            child: Column(
                                              children: [
                                                GestureDetector(
                                                  onTap: () => controller
                                                      .pickImageFromCamera(),
                                                  child: Container(
                                                    width: getWidth(context,
                                                        width: 1),
                                                    height: getHeight(context,
                                                        height: 0.075),
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            width: 0.5)),
                                                    child: const Center(
                                                      child: Text(
                                                          "Take a confirmation photo"),
                                                    ),
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () => controller
                                                      .pickImageFromGallery(),
                                                  child: Container(
                                                    width: getWidth(context,
                                                        width: 1),
                                                    height: getHeight(context,
                                                        height: 0.075),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          width: 0.5),
                                                    ),
                                                    child: const Center(
                                                      child: Text(
                                                          "Pick an image from gallery"),
                                                    ),
                                                  ),
                                                ),
                                                Obx(() {
                                                  if (controller
                                                          .iamgeConfirm.value ==
                                                      null) {
                                                    return const SizedBox();
                                                  }
                                                  return SizedBox(
                                                    width: getWidth(context,
                                                        width: 1),
                                                    height: getHeight(context,
                                                        height: 0.35),
                                                    child: Column(
                                                      children: [
                                                        spaceHeight(context,
                                                            height: 0.02),
                                                        SizedBox(
                                                          width: getWidth(
                                                              context,
                                                              width: 1),
                                                          height: getHeight(
                                                              context,
                                                              height: 0.25),
                                                          child: Image.file(
                                                            File(controller
                                                                .iamgeConfirm
                                                                .value!
                                                                .path),
                                                            fit: BoxFit.contain,
                                                          ),
                                                        ),
                                                        spaceHeight(context,
                                                            height: 0.02),
                                                        GestureDetector(
                                                          onTap: () async {
                                                            if (controller
                                                                    .iamgeConfirm
                                                                    .value ==
                                                                null) {
                                                              return;
                                                            }
                                                            await controller
                                                                .deliveryDone();
                                                          },
                                                          child: Container(
                                                            width: getWidth(
                                                                context,
                                                                width: 0.5),
                                                            height: getHeight(
                                                                context,
                                                                height: 0.05),
                                                            decoration: BoxDecoration(
                                                                border:
                                                                    Border.all(
                                                                        width:
                                                                            0.5),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5)),
                                                            child: const Center(
                                                                child: Text(
                                                                    "Confirm")),
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
                              } else {
                                return ButtonWidget(
                                  function: () {},
                                  listColor: [
                                    Colors.grey,
                                    Colors.grey.shade400
                                  ],
                                  borderRadius: 5,
                                  textButton: "I arrived",
                                );
                              }
                            })),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                  onPressed: () {
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
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.black,
                                                          width: 0.2)),
                                                  child: const Center(
                                                    child: Text(
                                                        "Receiver does not reply"),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.black,
                                                          width: 0.2)),
                                                  child: const Center(
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
    );
  }
}
