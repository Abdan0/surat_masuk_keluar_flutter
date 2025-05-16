import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_piechart.dart';

class MyPiecard extends StatelessWidget {
  final String surat;
  final String tahunSurat;
  final int suratDone;
  final int suratNew;
  final int suratProcess;

  const MyPiecard({
    super.key,
    required this.surat,
    required this.tahunSurat,
    required this.suratDone,
    required this.suratNew,
    required this.suratProcess,
  });

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
                surat,
                style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: AppPallete.textColor,
                    fontWeight: FontWeight.bold),
              ),

              const SizedBox(
                height: 15,
              ),

              // Tahun
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.arrow_back_ios_new),
                    Text(
                      tahunSurat,
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: AppPallete.textColor,
                          fontWeight: FontWeight.bold),
                    ),
                    const Icon(Icons.arrow_forward_ios),
                  ],
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              // Pie Chart
              MyPiechart(
                  suratDone: suratDone,
                  suratNew: suratNew,
                  suratProcess: suratProcess),

              const SizedBox(
                height: 15,
              ),

              // Keterangan
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
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
                          "Selesai",
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
                            color: Colors.lightBlue,
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          "Proses",
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
                          "Baru",
                          style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: AppPallete.textColor,
                              fontWeight: FontWeight.w500),
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
