import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sizer/flutter_sizer.dart';

class CommonWidget{

  Widget customeText(String text, int size, Color color, String font){
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: size.dp,
        fontFamily: font,
      ),
    );
  }
}




class CommonTextField extends StatelessWidget {
  final String placeholder;
  final double textSize;
  final String fontFamily;
  final Color textColor;
  final TextEditingController controller;
  final bool isNumber; // optional -> true = number pad, false = alphabetic
  final ValueChanged<String>? onChanged; // return entered text
  final FocusNode? focusNode;

  const CommonTextField({
    super.key,
    required this.placeholder,
    required this.textSize,
    required this.fontFamily,
    required this.textColor,
    required this.controller,
    this.isNumber = false,
    this.onChanged,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(color: Colors.grey, width: 1),
      ),
      child: CupertinoTextField(
        focusNode: focusNode,
        controller: controller,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: TextStyle(
          fontSize: textSize,
          fontFamily: fontFamily,
          color: textColor,
        ),
        placeholder: placeholder,
        placeholderStyle: TextStyle(
          fontSize: textSize,
          fontFamily: fontFamily,
          color: textColor.withOpacity(0.5),
        ),
        inputFormatters: isNumber
            ? [
          FilteringTextInputFormatter.digitsOnly, // only numbers
          LengthLimitingTextInputFormatter(10), // max 10 digits
        ]
            : [],
        decoration: null, // so CupertinoTextField uses parent container
        onChanged: onChanged,
      ),
    );
  }
}

