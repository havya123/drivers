import 'package:drivers/app/route/route_name.dart';
import 'package:drivers/app/util/const.dart';
import 'package:drivers/controller/home_controller.dart';
import 'package:drivers/model/request_multi.dart';
import 'package:drivers/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NewRequestMultiWidget extends StatelessWidget {
  const NewRequestMultiWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<HomeController>();
    return Container(
      width: getWidth(context, width: 1),
      height: getHeight(context, height: 1),
      color: Colors.black87,
      child: FutureBuilder(
        future: controller.getRequestMultiInfor(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          RequestMulti requestMulti = snapshot.data as RequestMulti;
          controller.newRequest.value = requestMulti;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: getWidth(context, width: 1),
                height: getHeight(context, height: 0.08),
                color: Colors.black,
                child: Center(
                  child: Text(
                    "${requestMulti.cost.toString()}VND",
                    style: largeTextStyle(context, color: Colors.white),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: getWidth(context, width: 1),
                  height: getHeight(context, height: 0.7),
                  clipBehavior: Clip.hardEdge,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: getWidth(context, width: 1),
                        height: getHeight(context, height: 0.1),
                        color: Colors.grey.shade300,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "100Km",
                                style: mediumTextStyle(context),
                              ),
                              Text(
                                "Multi Destinations",
                                style: mediumTextStyle(context),
                              ),
                              Text(
                                requestMulti.paymentMethod,
                                style: mediumTextStyle(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: getWidth(context, width: 1),
                        height: getHeight(context, height: 0.1),
                        child: Text(requestMulti.senderAddress['senderAddres'],
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
                      Expanded(
                        child: Container(
                            width: getWidth(context, width: 1),
                            color: Colors.grey.shade300,
                            child: ListView.separated(
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return Text(
                                    requestMulti.receiverAddress[index]
                                        ['receiverAddress'],
                                    textAlign: TextAlign.center,
                                    style: smallTextStyle(context),
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return spaceHeight(context, height: 0.02);
                                },
                                itemCount:
                                    requestMulti.receiverAddress.length)),
                      ),
                      Obx(() {
                        return ButtonWidget(
                          function: () async {
                            await controller.acceptRequestMulti();
                            Get.toNamed(RouteName.pickupRoute);
                          },
                          borderRadius: 0,
                          textButton:
                              "Accept the request ${controller.second.value}",
                        );
                      })
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
