import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Size size(context) => MediaQuery.sizeOf(context);

double getHeight(context, {double height = 0.04}) =>
    size(context).height * height;

double getWidth(context, {double width = 0.04}) => size(context).width * width;

SizedBox spaceHeight(context, {double height = 0.04}) => SizedBox(
      height: size(context).height * height,
    );

SizedBox spaceWidth(context, {double width = 0.04}) => SizedBox(
      width: size(context).width * width,
    );

TextStyle smallTextStyle(context,
        {double size = 16, Color color = Colors.black}) =>
    GoogleFonts.roboto(
        fontSize: size, color: color, fontWeight: FontWeight.normal);

TextStyle mediumTextStyle(context,
        {double size = 21, Color color = Colors.black}) =>
    GoogleFonts.roboto(
        fontSize: size, color: color, fontWeight: FontWeight.w400);

TextStyle largeTextStyle(context,
        {double size = 30, Color color = Colors.black}) =>
    GoogleFonts.roboto(
        fontSize: size, color: color, fontWeight: FontWeight.bold);
Color green = const Color(0xff9BFE03);
Color grey = const Color(0xff898989);
Color lightGrey = const Color(0xff3B3F34);
