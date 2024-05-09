import 'package:drivers/app/util/const.dart';
import 'package:drivers/controller/history_controller.dart';
import 'package:drivers/screens/history_screen/history_widget/history_multi_widget.dart';
import 'package:drivers/screens/history_screen/history_widget/history_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HistoryScreen extends GetView<HistoryController> {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! > 0) {
                controller.swipeLeft();
              } else if (details.primaryVelocity! < 0) {
                print("Swipe right");
                controller.swipeRight();
              }
            },
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_back_ios),
                      Expanded(
                        child: Text(
                          "History of activities",
                          style: largeTextStyle(context),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delivery Type'),
                                content: Column(
                                  mainAxisSize:
                                      MainAxisSize.min, // Restrict content size
                                  children: [
                                    ListTile(
                                      title: const Text('Default'),
                                      onTap: () async {
                                        controller.mode.value = "Default";
                                        Get.back(); // Close dialog
                                        await controller.getAllRequest();
                                      },
                                    ),
                                    ListTile(
                                      title: const Text('Multi Express'),
                                      onTap: () async {
                                        controller.mode.value = "Multi Express";
                                        // Handle multi express delivery selection (update state or logic)
                                        Get.back(); // Close dialog
                                        await controller.getAllRequestMulti();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.settings))
                    ],
                  ),
                ),
                spaceHeight(context),
                SizedBox(
                  height: getHeight(context, height: 0.06),
                  child: ListView.separated(
                    controller: controller.titleController,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Obx(() {
                        return GestureDetector(
                          onTap: () => controller.changeIndex(index),
                          child: Container(
                            height: getHeight(context),
                            decoration: BoxDecoration(
                              color: index == controller.index.value
                                  ? const Color(0xff00631f)
                                  : const Color(0xffdbfff9),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 2,
                              ),
                              child: Center(
                                child: Text(
                                  controller.listType[index],
                                  style: smallTextStyle(context,
                                      size: 14,
                                      fontWeight: FontWeight.w600,
                                      color: index == controller.index.value
                                          ? Colors.white
                                          : const Color(0xff003028)),
                                ),
                              ),
                            ),
                          ),
                        );
                      });
                    },
                    separatorBuilder: (context, index) => spaceWidth(context),
                    itemCount: controller.listType.length,
                  ),
                ),
                spaceHeight(context),
                Obx(() {
                  if (controller.mode.value == "Default") {
                    if (controller.loading.value) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return Expanded(
                      child: Obx(() {
                        return ListView.separated(
                          itemBuilder: (context, index) {
                            return HistoryWidget(
                              request: controller
                                  .allRequest[controller.index.value][index],
                            );
                          },
                          separatorBuilder: (context, index) =>
                              spaceHeight(context),
                          itemCount: controller
                              .allRequest[controller.index.value].length,
                        );
                      }),
                    );
                  }
                  if (controller.mode.value == "Multi Express") {
                    if (controller.loading.value) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return Expanded(
                      child: Obx(() {
                        return ListView.separated(
                          itemBuilder: (context, index) {
                            return HistoryMultiWidget(
                              request: controller
                                      .allRequestMulti[controller.index.value]
                                  [index],
                            );
                          },
                          separatorBuilder: (context, index) =>
                              spaceHeight(context),
                          itemCount: controller
                              .allRequestMulti[controller.index.value].length,
                        );
                      }),
                    );
                  }
                  return const SizedBox();
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
