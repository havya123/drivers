import 'package:drivers/app/util/const.dart';
import 'package:drivers/controller/delivery_saving_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart' as urlLauncher;

import '../../../widgets/button.dart';

class PickUpWidget extends StatelessWidget {
  const PickUpWidget({super.key});

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
                      await urlLauncher.launchUrl(Uri(
                          scheme: 'tel',
                          path: controller.currentRequest.value!.senderPhone));
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
                          path: controller.currentRequest.value!.senderPhone));
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
                            return controller.isClose.value
                                ? ButtonWidget(
                                    function: () async {
                                      if (controller.waitingConfirm.value ==
                                          true) {
                                        return;
                                      }

                                      await controller.pickUpSuccess();
                                      // await controller
                                      //     .openGoogleMapsDirections();
                                    },
                                    borderRadius: 5,
                                    textButton: controller.waitingConfirm.value
                                        ? "Waiting for user's confirmation"
                                        : "I arrived",
                                  )
                                : ButtonWidget(
                                    listColor: [
                                      Colors.grey,
                                      Colors.grey.shade400
                                    ],
                                    function: () async {
                                      // await controller.pickUpSuccess();
                                      // await controller
                                      //     .openGoogleMapsDirections();
                                    },
                                    borderRadius: 5,
                                    textButton: "I arrived",
                                  );
                          }),
                        ),
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
                                                        "Sender does not reply"),
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
                                                        "Sender does not want to send "),
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
                                                      "Product's size is not the same with the request information ",
                                                      textAlign:
                                                          TextAlign.center,
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
                                    color: Colors.white, size: 14),
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
