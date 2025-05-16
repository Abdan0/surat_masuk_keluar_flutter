import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';

class MyButton extends StatelessWidget {
  final Function()? onTap;
  final String text;

  const MyButton(
    {
      super.key,
      required this.text,
      required this.onTap,
    }
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        margin: const EdgeInsets.symmetric(horizontal: 90.0, vertical: 5.0),
        decoration:  BoxDecoration(
          color: AppPallete.primaryColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(text, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15.0)),
        ),
      ),
    );
  }
}
