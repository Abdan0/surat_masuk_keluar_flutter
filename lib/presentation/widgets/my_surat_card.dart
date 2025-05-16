import 'package:flutter/material.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';

class MySuratCard extends StatelessWidget {
  final String nomorSurat;
  final String tanggalSurat;
  final String pengirimSurat;
  final String nomorAgenda;
  final String klasifikasiSurat;
  final String ringkasanSurat;
  final String keteranganSurat;
  final VoidCallback? onDisposisiTap;
  final VoidCallback? onPdfTap;

  const MySuratCard(
      {super.key,
      required this.nomorSurat,
      required this.tanggalSurat,
      required this.pengirimSurat,
      required this.nomorAgenda,
      required this.klasifikasiSurat,
      required this.ringkasanSurat,
      required this.keteranganSurat,
      this.onDisposisiTap,
      this.onPdfTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppPallete.borderColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              //Bagian Atas Card
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Atribut Surat
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nomorSurat,
                        style: const TextStyle(
                            color: AppPallete.textColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 15),
                      ),
                      const SizedBox(
                        height: 8.0,
                      ),
                      Text(
                        '$pengirimSurat | $nomorAgenda | $klasifikasiSurat',
                        style: const TextStyle(
                            color: AppPallete.textColor, fontSize: 10.0),
                      )
                    ],
                  ),

                  // Tanggal Surat
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tanggal Surat',
                        style: TextStyle(
                            color: AppPallete.textColor, fontSize: 10.0),
                      ),
                      const SizedBox(
                        height: 8.0,
                      ),
                      Text(
                        tanggalSurat,
                        style: const TextStyle(
                            color: AppPallete.textColor, fontSize: 10.0),
                      )
                    ],
                  ),

                  // Button Disposisi
                  SizedBox(
                    height: 40,
                    width: 80,
                    child: ElevatedButton(
                        onPressed: () {
                          print('Disposisi diklik');
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppPallete.primaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12))),
                        child: const Text(
                          'Disposisi',
                          style: TextStyle(
                              color: AppPallete.whiteColor,
                              fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                        )),
                  ),

                  const Icon(Icons.more_vert)

                  // MyButton(text: 'Disposisi', onTap: onDisposisiTap)
                ],
              ),

              const SizedBox(height: 8),

              const Divider(
                thickness: 2,
                color: Colors.black,
              ),

              //Bagian Bawah Card
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ringkasanSurat,
                        style: const TextStyle(
                            color: AppPallete.textColor, fontSize: 12.0),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        keteranganSurat,
                        style: const TextStyle(
                            color: AppPallete.textColor, fontSize: 12.0),
                      ),
                    ],
                  ),
                  IconButton(
                      onPressed: onPdfTap,
                      icon: const Icon(
                        Icons.picture_as_pdf,
                        color: Colors.black87,
                        size: 35,
                      ))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
