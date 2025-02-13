import 'package:flutter/material.dart';

class TextFormDecoration {
  static InputDecoration box({
    double? padding,
    Widget? suffixIcon,
    Widget? prefixIcon,
    double? circularRadius,
    Color? fillColor,
    String? hintText,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(circularRadius ?? 10),
        ),
      ),
      alignLabelWithHint: true,
      isDense: true,
      // hintStyle: TextStyle(fontSize: 10),
      contentPadding: EdgeInsets.symmetric(
        vertical: padding ?? 15,
        horizontal: 10,
      ),
      suffixIcon: suffixIcon,
      prefixIcon: prefixIcon,
    );
  }

  static InputDecoration iconBox(
    String title, {
    bool showLabel = true,
    bool showHint = true,
    double? padding,
    double? textIconSize,
    String? textIcon,
  }) {
    return InputDecoration(
      border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
        Radius.circular(8.0),
      )),
      hintText: showHint ? title : null,
      labelText: showLabel ? title : null,
      contentPadding: EdgeInsets.all(padding ?? 10),
      suffixIcon: Container(
        decoration: BoxDecoration(
          color: Colors.black45,
          border: Border.all(color: Colors.grey, width: 1.5),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
        ),
        child: Text(
          textIcon ?? "",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: textIconSize,
          ),
        ),
      ),
    );
  }

  static InputDecoration boxLogin(String hintText) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hintText,
      hintStyle: const TextStyle(fontSize: 18),
      contentPadding: const EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        bottom: 8.0,
        top: 8.0,
      ),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(40),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.blue),
        borderRadius: BorderRadius.circular(40),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: const BorderSide(color: Colors.white),
        borderRadius: BorderRadius.circular(40),
      ),
    );
  }
}
