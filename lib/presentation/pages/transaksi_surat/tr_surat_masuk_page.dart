import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_appbar.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_surat_card.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_apppbar2.dart';
import 'package:surat_masuk_keluar_flutter/presentation/pages/transaksi_surat/tbh_surat_masuk_page.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';

class TrSuratMasukPage extends StatefulWidget {
  const TrSuratMasukPage({super.key});

  @override
  State<TrSuratMasukPage> createState() => _TrSuratMasukPageState();
}

class _TrSuratMasukPageState extends State<TrSuratMasukPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Bar
              const MyAppBar2(),

              const SizedBox(
                height: 20,
              ),

              // Halaman
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'Surat Masuk',
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: AppPallete.textColor,
                      fontWeight: FontWeight.w700),
                  textAlign: TextAlign.left,
                ),
              ),

              // Button Tambah
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    height: 40,
                    width: 100,
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const TambahSuratMasuk()));
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppPallete.primaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12))),
                        child: const Text(
                          'Tambah',
                          style: TextStyle(
                            color: AppPallete.whiteColor,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        )),
                  ),
                ),
              ),

              const SizedBox(height: 12,),

              
              // Card Surat
              const MySuratCard(
                  nomorSurat: 'SRT-1',
                  tanggalSurat: '5/14/2025',
                  pengirimSurat: 'Abdan',
                  nomorAgenda: 'AG-1',
                  klasifikasiSurat: 'Internal',
                  ringkasanSurat: 'Hai',
                  keteranganSurat: 'ini Surat'),

                  const MySuratCard(
                  nomorSurat: 'SRT-1',
                  tanggalSurat: '5/14/2025',
                  pengirimSurat: 'Abdan',
                  nomorAgenda: 'AG-1',
                  klasifikasiSurat: 'Internal',
                  ringkasanSurat: 'Hai',
                  keteranganSurat: 'ini Surat'),

                  const MySuratCard(
                  nomorSurat: 'SRT-1',
                  tanggalSurat: '5/14/2025',
                  pengirimSurat: 'Abdan',
                  nomorAgenda: 'AG-1',
                  klasifikasiSurat: 'Internal',
                  ringkasanSurat: 'Hai',
                  keteranganSurat: 'ini Surat'),
            ],
          ),
        ),
      ),
    );
  }
}
