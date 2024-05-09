import 'package:drivers/app/route/route_name.dart';
import 'package:drivers/app/store/app_store.dart';
import 'package:drivers/app/util/const.dart';
import 'package:drivers/controller/home_controller.dart';
import 'package:drivers/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../model/request.dart';

class NewRequestWidget extends StatelessWidget {
  NewRequestWidget({super.key, required this.mode});
  String mode;
  @override
  Widget build(BuildContext context) {
    var controller = Get.find<HomeController>();
    return mode == "saving"
        ? Container(
            width: getWidth(context, width: 1),
            height: getHeight(context, height: 1),
            color: Colors.black87,
            child: FutureBuilder(
              future: controller.getRequestInformation(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.data == null) {
                  return const Center(child: CircularProgressIndicator());
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
                            style: largeTextStyle(context, color: Colors.white),
                          ),
                        ),
                      ),
                      spaceHeight(context),
                      Center(
                        child: Container(
                          width: getWidth(context, width: 0.8),
                          height: getHeight(context, height: 0.57),
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: getWidth(context, width: 1),
                                height: getHeight(context, height: 0.1),
                                color: Colors.grey.shade300,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Km",
                                        style: mediumTextStyle(context),
                                      ),
                                      Text(
                                        request.type,
                                        style: mediumTextStyle(context),
                                      ),
                                      Text(
                                        request.paymentMethod,
                                        style: mediumTextStyle(context),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: getWidth(context, width: 1),
                                height: getHeight(context, height: 0.1),
                                child:
                                    Text(request.senderAddress['senderAddres'],
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
                                width: getWidth(context, width: 1),
                                height: getHeight(context, height: 0.1),
                                color: Colors.grey.shade300,
                                child: Text(
                                  request.receiverAddress['receiverAddress'],
                                  textAlign: TextAlign.center,
                                  style: smallTextStyle(context),
                                ),
                              ),
                              spaceHeight(context, height: 0.08),
                              Obx(() {
                                return Expanded(
                                  child: ButtonWidget(
                                    function: () async {
                                      await controller.acceptRequestSaving();
                                      return;
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
            ))
        : Container(
            width: getWidth(context, width: 1),
            height: getHeight(context, height: 1),
            color: Colors.black87,
            child: FutureBuilder(
              future: controller.getRequestInformation(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.data == null) {
                  return const Center(child: CircularProgressIndicator());
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
                            style: largeTextStyle(context, color: Colors.white),
                          ),
                        ),
                      ),
                      spaceHeight(context),
                      Center(
                        child: Container(
                          width: getWidth(context, width: 0.8),
                          height: getHeight(context, height: 0.57),
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: getWidth(context, width: 1),
                                height: getHeight(context, height: 0.1),
                                color: Colors.grey.shade300,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Km",
                                        style: mediumTextStyle(context),
                                      ),
                                      Text(
                                        request.type,
                                        style: mediumTextStyle(context),
                                      ),
                                      Text(
                                        request.paymentMethod,
                                        style: mediumTextStyle(context),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: getWidth(context, width: 1),
                                height: getHeight(context, height: 0.1),
                                child:
                                    Text(request.senderAddress['senderAddres'],
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
                                width: getWidth(context, width: 1),
                                height: getHeight(context, height: 0.1),
                                color: Colors.grey.shade300,
                                child: Text(
                                  request.receiverAddress['receiverAddress'],
                                  textAlign: TextAlign.center,
                                  style: smallTextStyle(context),
                                ),
                              ),
                              spaceHeight(context, height: 0.08),
                              Obx(() {
                                return Expanded(
                                  child: ButtonWidget(
                                    function: () async {
                                      await controller.acceptRequest();
                                      Get.offNamed(RouteName.pickupRoute);
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
}
