import 'package:drivers/app/util/const.dart';
import 'package:flutter/material.dart';

class SearchBoxWidget extends StatelessWidget {
  SearchBoxWidget({
    required this.width,
    required this.height,
    required this.color,
    required this.suffixIcon,
    required this.textBox,
    super.key,
    required this.controller,
    this.borderRadius = 10,
    required this.textStyle,
  });
  double width, height;
  Color color;
  Icon suffixIcon;
  String textBox;
  TextEditingController controller;
  double borderRadius;
  TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        border: Border.all(color: color),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            suffixIcon,
            spaceWidth(context),
            Expanded(
                child: TextField(
              controller: controller,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: textBox,
                  hintStyle: textStyle),
            ))
          ],
        ),
      ),
    );
  }
}
