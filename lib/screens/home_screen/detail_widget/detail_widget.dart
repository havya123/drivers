import 'package:drivers/app/store/app_store.dart';
import 'package:drivers/app/util/const.dart';
import 'package:drivers/model/parcel.dart';
import 'package:drivers/model/request.dart';
import 'package:drivers/repository/parcel_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:transparent_image/transparent_image.dart';

class DetailWidget extends StatelessWidget {
  DetailWidget({super.key, required this.request});
  Request request;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: Text(
          "Order Detail",
          style: largeTextStyle(context),
        ),
        centerTitle: true,
      ),
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
                request.senderAddress['senderAddres'],
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.receiverAddress['receiverAddress'],
                    style: smallTextStyle(context),
                  ),
                  spaceHeight(context, height: 0.04),
                  Text(
                    "Parcel's image",
                    style: largeTextStyle(context, size: 24),
                  ),
                  spaceHeight(context, height: 0.02),
                  SizedBox(
                    height: getHeight(context, height: 0.5),
                    child: FutureBuilder(
                        future: ParcelRepo().getParcelInfor(request.parcelId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          Parcel parcel = snapshot.data as Parcel;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: getHeight(context, height: 0.3),
                                child: ListView.separated(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index1) {
                                      return Container(
                                        clipBehavior: Clip.hardEdge,
                                        width: getHeight(context, height: 0.3),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        child: FadeInImage.memoryNetwork(
                                          placeholder: kTransparentImage,
                                          image: parcel.listImage[index1],
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    },
                                    separatorBuilder: (context, index) =>
                                        spaceWidth(context),
                                    itemCount: parcel.listImage.length),
                              ),
                              spaceHeight(context),
                              Text(
                                "Parcel's Information",
                                style: largeTextStyle(context, size: 24),
                              ),
                              Text(
                                "Dimension: ${parcel.dimension} cm2",
                                style: smallTextStyle(context),
                              ),
                              Text(
                                "Weight : ${parcel.weight} kg",
                                style: smallTextStyle(context),
                              ),
                            ],
                          );
                        }),
                  ),
                ],
              )
            ],
          ),
        ),
      )),
    );
  }
}
