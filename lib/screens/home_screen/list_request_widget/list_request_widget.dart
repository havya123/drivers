import 'package:drivers/app/util/const.dart';
import 'package:flutter/material.dart';

class ListRequestWidget extends StatelessWidget {
  const ListRequestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: getWidth(context, width: 0.8),
      height: getHeight(context, height: 0.5),
      color: Colors.black,
    );
  }
}
