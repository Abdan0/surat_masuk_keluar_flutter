import 'package:flutter/material.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';

class MyMenu extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const MyMenu(
      {super.key,  required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(12.0),
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 50,
            width: 50,
              decoration: BoxDecoration(
                  color: AppPallete.borderColor,
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Icon(icon, size: 30),
                  ],
                ),
              )),
        ));
  }
}
