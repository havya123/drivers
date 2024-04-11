import 'package:drivers/app/util/const.dart';
import 'package:drivers/extension/email_valid_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldWidget extends StatelessWidget {
  TextFieldWidget(
      {required this.hint,
      this.icon,
      this.isPass = false,
      this.type = TextInputType.text,
      this.errorText,
      this.numberOfLetter,
      this.errorPass,
      this.minLetter = 0,
      this.controller,
      this.isPass1 = false,
      this.isConfirmPass = false,
      this.removeBorder = false,
      this.hintText = "",
      this.maxline = 1,
      this.function,
      this.borderRadius = 30,
      this.color = const Color(0xffF3F5F7),
      this.textColor = Colors.white,
      super.key});
  final String hint;
  final Widget? icon;
  final bool isPass;
  final TextInputType type;
  final String? errorText;
  final int? numberOfLetter;
  final String? errorPass;
  final int? minLetter;
  final TextEditingController? controller;
  final bool isPass1;
  final bool isConfirmPass;
  final bool removeBorder;
  final String hintText;
  final Function(String?)? function;
  final double borderRadius;
  int maxline;
  Color color, textColor;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: const TextStyle(color: Colors.white),
      onFieldSubmitted: function,
      maxLines: maxline,
      controller: controller,
      inputFormatters: [
        LengthLimitingTextInputFormatter(numberOfLetter),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return errorText;
        } else if (value.length < minLetter!) {
          return errorPass;
        } else if (type == TextInputType.emailAddress) {
          if (!controller!.text.isValidEmail()) {
            return "Wrong Email Format";
          }
        }
        return null;
      },
      keyboardType: type,
      obscureText: isPass,
      decoration: InputDecoration(
          filled: true,
          fillColor: color,
          hintText: hintText,
          hintStyle: smallTextStyle(context, color: textColor),
          // label:  Text(hint),
          // labelText: hint,
          labelStyle: TextStyle(
            color: textColor,
          ),
          focusedErrorBorder: OutlineInputBorder(
              borderSide: !removeBorder
                  ? const BorderSide(color: Colors.black)
                  : BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(borderRadius))),
          errorBorder: OutlineInputBorder(
              borderSide: !removeBorder
                  ? const BorderSide(color: Colors.black)
                  : BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(borderRadius))),
          enabledBorder: OutlineInputBorder(
              borderSide: !removeBorder
                  ? const BorderSide(color: Colors.black)
                  : BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(borderRadius))),
          focusedBorder: OutlineInputBorder(
              borderSide: !removeBorder
                  ? const BorderSide(color: Colors.black)
                  : BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(borderRadius))),
          prefixIcon: icon),
    );
  }
}
