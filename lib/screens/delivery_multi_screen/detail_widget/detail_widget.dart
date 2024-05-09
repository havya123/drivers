import 'package:drivers/app/store/app_store.dart';
import 'package:drivers/app/util/const.dart';
import 'package:drivers/controller/delivery_multi_controller.dart';
import 'package:drivers/model/parcel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:transparent_image/transparent_image.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<DeliveryMultiController>();
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Sender Address",
                style: largeTextStyle(context, size: 24),
              ),
              spaceHeight(context, height: 0.02),
              Text(
                AppStore.to.currentRequest.value.senderAddress['senderAddres'],
                style: smallTextStyle(context),
              ),
              Align(
                alignment: Alignment.center,
                child: Icon(
                  Icons.arrow_drop_down,
                  size: 100,
                  color: green,
                ),
              ),
              spaceHeight(context, height: 0.02),
              Text(
                "Receiver Address",
                style: largeTextStyle(context, size: 24),
              ),
              ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.listDestination[index]['receiverAddress'],
                          style: smallTextStyle(context),
                        ),
                        spaceHeight(context, height: 0.02),
                        Text(
                          "Parcel's image",
                          style: smallTextStyle(context,
                              fontWeight: FontWeight.w700),
                        ),
                        spaceHeight(context, height: 0.02),
                        SizedBox(
                          height: getHeight(context, height: 0.15),
                          child: ListView.separated(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index1) {
                                return Container(
                                  clipBehavior: Clip.hardEdge,
                                  width: getHeight(context, height: 0.15),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5)),
                                  child: FadeInImage.memoryNetwork(
                                    placeholder: kTransparentImage,
                                    image: controller
                                        .listParcel[index].listImage[index1],
                                    fit: BoxFit.cover,
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) =>
                                  spaceWidth(context),
                              itemCount: controller
                                  .listParcel[index].listImage.length),
                        ),
                        spaceHeight(context),
                        Text(
                          "Confirmation Image",
                          style: smallTextStyle(context,
                              fontWeight: FontWeight.w700),
                        ),
                        spaceHeight(context, height: 0.02),
                        FutureBuilder(
                          future: controller.getParcelImageConfirm(index),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            Parcel parcel = snapshot.data as Parcel;
                            if (parcel.imageConfirm.isEmpty) {
                              return const SizedBox();
                            }
                            return Container(
                              width: getHeight(context, height: 0.15),
                              height: getHeight(context, height: 0.15),
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: FadeInImage.memoryNetwork(
                                  placeholder: kTransparentImage,
                                  image: parcel.imageConfirm),
                            );
                          },
                        )
                      ],
                    );
                  },
                  separatorBuilder: (context, index) => spaceHeight(context),
                  itemCount: controller.listDestination.length)
            ],
          ),
        ),
      )),
    );
  }
}
