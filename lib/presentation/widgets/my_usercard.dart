import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_userchart.dart';

class MyUsercard extends StatelessWidget {
  const MyUsercard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: BoxDecoration(
            color: AppPallete.borderColor,
            borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Surat Masuk/Keluar
              Text(
                "Pengguna",
                style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: AppPallete.textColor,
                    fontWeight: FontWeight.bold),
              ),

              const SizedBox(
                height: 15,
              ),

              const SizedBox(
                height: 15,
              ),

              // Pie Chart
              const MyUserchart(
                  userAdmin: 1, userDekan: 1, userWakilDekan: 1, userStaff: 1),

              const SizedBox(
                height: 15,
              ),

              // Keterangan
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 15,
                              height: 15,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                color: Colors.lightGreen,
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Dekan",
                              style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  color: AppPallete.textColor,
                                  fontWeight: FontWeight.w500),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              width: 15,
                              height: 15,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Wakil Dekan",
                              style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  color: AppPallete.textColor,
                                  fontWeight: FontWeight.w500),
                            )
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                      children: [
                        Container(
                          width: 15,
                          height: 15,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: Colors.lightBlue,
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          "Admin",
                          style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: AppPallete.textColor,
                              fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: 15,
                          height: 15,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: Colors.yellow[300],
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          "Staff",
                          style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: AppPallete.textColor,
                              fontWeight: FontWeight.w500),
                        )
                      ],
                    )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
