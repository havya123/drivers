import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CheckboxExample extends StatelessWidget {
  final RxBool isChecked;
  final Function(bool?)? onChanged;

  const CheckboxExample({
    required this.isChecked,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Checkbox(
        shape: const CircleBorder(),
        checkColor: Colors.green,
        fillColor:
            MaterialStateProperty.resolveWith((states) => Colors.transparent),
        side: const BorderSide(color: Colors.green),
        value: isChecked.value,
        onChanged: onChanged,
      );
    });
  }
}
