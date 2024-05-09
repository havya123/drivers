import 'package:drivers/app/util/const.dart';
import 'package:drivers/model/request.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HistoryWidget extends StatelessWidget {
  HistoryWidget({super.key, required this.request});
  Request request;
  @override
  Widget build(BuildContext context) {
    Color getStatusColor(String status) {
      switch (status) {
        case 'waiting':
          return Colors.yellow.shade400;
        case 'on taking':
          return Colors.yellow.shade400;
        case 'on delivery':
          return Colors.yellow.shade400;
        case 'success':
          return Colors.green.shade400;
        case 'cancel':
          return Colors.red.shade400;
        default:
          return Colors.transparent; // Set a default color if needed
      }
    }

    return GestureDetector(
      onTap: () {
        // if (request.statusRequest == 'waiting') {
        //   Get.toNamed(RouteName.trackingRoute,
        //       parameters: {'requestId': request.requestId});
        //   return;
        // }
        // Get.toNamed(RouteName.detailTripRoute, arguments: {
        //   'request': request,
        // });
      },
      child: Container(
        width: getWidth(context, width: 1),
        height: getHeight(context, height: 0.3),
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                  width: 35,
                  height: 35,
                  child: Image.asset(
                    "lib/app/assets/parcels.png",
                    fit: BoxFit.contain,
                  )),
              spaceWidth(context),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            "Delivery to ${request.receiverAddress['receiverAddress']}",
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: smallTextStyle(context),
                          ),
                        ),
                        spaceWidth(context, width: 0.06),
                        Expanded(
                          flex: 1,
                          child: Text(
                            "${request.cost}VND",
                            style: mediumTextStyle(context, size: 18),
                          ),
                        )
                      ],
                    ),
                    spaceHeight(context, height: 0.03),
                    Container(
                      width: getWidth(context, width: 0.2),
                      height: getHeight(context, height: 0.04),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: getStatusColor(request.statusRequest)),
                      child: Center(
                        child: Text(request.statusRequest),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
