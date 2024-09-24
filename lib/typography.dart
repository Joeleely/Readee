import 'package:flutter/material.dart';

extension TypographyText on TextTheme {
  static TextStyle h0(Color color) {
    return TextStyle(
        color: color,
        fontFamily: 'Roboto',
        fontSize: 34,
        fontWeight: FontWeight.w600);
  }
  static TextStyle h1(Color color) {
    return TextStyle(
        color: color,
        fontFamily: 'Roboto',
        fontSize: 24,
        fontWeight: FontWeight.w600);
  }

  static TextStyle h2(Color color) {
    return TextStyle(
        color: color,
        fontFamily: 'Roboto',
        fontSize: 20,
        fontWeight: FontWeight.w600);
  }

  static TextStyle h3(Color color) {
    return TextStyle(
        color: color,
        fontFamily: 'Roboto',
        fontSize: 16,
        fontWeight: FontWeight.w600);
  }

  static TextStyle h4(Color color) {
    return TextStyle(
        color: color,
        fontFamily: 'Roboto',
        fontSize: 12,
        fontWeight: FontWeight.w600);
  }

  static TextStyle b1(Color color) {
    return TextStyle(
        color: color,
        fontFamily: 'Roboto',
        fontSize: 22,
        fontWeight: FontWeight.w400);
  }

  static TextStyle b2(Color color) {
    return TextStyle(
        color: color,
        fontFamily: 'Roboto',
        fontSize: 16,
        fontWeight: FontWeight.w400);
  }

  static TextStyle b3(Color color) {
    return TextStyle(
        color: color,
        fontFamily: 'Roboto',
        fontSize: 14,
        fontWeight: FontWeight.w400);
  }

    static TextStyle b4(Color color) {
    return TextStyle(
        color: color,
        fontFamily: 'Roboto',
        fontSize: 12,
        fontWeight: FontWeight.w400);
  }
}
