import 'package:drivers/app/util/const.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ButtonWidget extends StatelessWidget {
  ButtonWidget(
      {required this.function,
      super.key,
      this.textButton = "",
      this.listColor = const [
        Color(0xff363ff5),
        Color(0xff6357CC),
      ],
      this.textColor = Colors.white,
      this.border = false,
      this.colorBorder = Colors.red,
      this.width = double.infinity,
      this.height,
      this.borderRadius = 20,
      this.fontSize = 19});
  final VoidCallback function;
  final String textButton;
  final List<Color> listColor;
  final Color textColor;
  final bool border;
  final Color colorBorder;
  final double width, borderRadius, fontSize;
  double? height;
  @override
  Widget build(BuildContext context) {
    var isLoading = false.obs;
    return InkWell(
      onTap: () async {
        if (isLoading.value) return;
        isLoading.value = !isLoading.value;
        await Future.delayed(
          const Duration(seconds: 1),
          () {
            function();
          },
        );
        isLoading.value = !isLoading.value;
      },
      child: Ink(
        child: Container(
          width: width,
          height: height ?? getHeight(context, height: 0.08),
          decoration: BoxDecoration(
              border: border ? Border.all(color: colorBorder) : null,
              gradient: LinearGradient(colors: listColor),
              borderRadius: BorderRadius.circular(borderRadius)),
          child: Obx(
            () => Center(
              child: !isLoading.value
                  ? Text(
                      textButton,
                      style: mediumTextStyle(context).copyWith(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      textAlign: TextAlign.center,
                    )
                  : const CircularProgressIndicator(),
            ),
          ),
        ),
      ),
    );
  }
}
