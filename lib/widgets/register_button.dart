import 'package:drivers/app/util/const.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterButton extends StatelessWidget {
  const RegisterButton(
      {required this.function,
      this.colorButton = Colors.white,
      super.key,
      required this.suffixIcon,
      this.textButton = "",
      this.textColor = Colors.white,
      this.border = false,
      this.colorBorder = Colors.red});
  final VoidCallback function;
  final String textButton;
  final Color textColor;
  final bool border;
  final Color colorBorder;
  final Color colorButton;
  final Widget suffixIcon;
  @override
  Widget build(BuildContext context) {
    var isLoading = false.obs;
    return InkWell(
      onTap: () async {
        if (isLoading.value) return;
        isLoading.value = !isLoading.value;
        await Future.delayed(const Duration(seconds: 2));
        isLoading.value = !isLoading.value;
        function();
      },
      child: Ink(
        child: Container(
            width: double.infinity,
            height: getHeight(context, height: 0.08),
            decoration: BoxDecoration(
                border: border ? Border.all(color: colorBorder) : null,
                color: colorButton,
                borderRadius: BorderRadius.circular(40)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  suffixIcon,
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    textButton,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
              ),
            )),
      ),
    );
  }
}
