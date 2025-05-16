import 'package:flutter/material.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';

class MyTextfield extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obsecureText;
  final double? width;
  final double? height;

  const MyTextfield(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.obsecureText,
      this.height,
      this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
        ),
        child: TextField(
          controller: controller,
          obscureText: obsecureText,
          decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: const BorderSide(color: AppPallete.borderColor)),
              focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppPallete.secondaryColor)),
              hintText: hintText,
              hintStyle: const TextStyle(color: AppPallete.textColor)),
        ),
      ),
    );
  }
}
