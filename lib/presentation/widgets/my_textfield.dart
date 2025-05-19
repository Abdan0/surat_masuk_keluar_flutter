import 'package:flutter/material.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';

class MyTextfield extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obsecureText;
  final int maxLines;
  final double? height;
  final String? Function(String?)? validator; // Menambahkan validator

  const MyTextfield({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obsecureText,
    this.maxLines = 1,
    this.height,
    this.validator, // Menambahkan parameter validator
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TextFormField( // Menggunakan TextFormField untuk validator
        controller: controller,
        obscureText: obsecureText,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
            borderRadius: BorderRadius.circular(12),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        ),
        validator: validator, // Menggunakan validator
      ),
    );
  }
}
