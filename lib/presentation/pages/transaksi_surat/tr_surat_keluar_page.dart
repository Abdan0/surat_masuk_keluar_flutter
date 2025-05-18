import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_surat_card.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_apppbar2.dart';
import 'package:surat_masuk_keluar_flutter/presentation/pages/transaksi_surat/tbh_surat_keluar_page.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';

class TrSuratKeluarPage extends StatefulWidget {
  const TrSuratKeluarPage({super.key});

  @override
  State<TrSuratKeluarPage> createState() => _TrSuratKeluarPageState();
}

class _TrSuratKeluarPageState extends State<TrSuratKeluarPage> {
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
                  'Surat Keluar',
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
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const TambahSuratKeluar()));
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
                  nomorSurat: 'SRT-K1',
                  tanggalSurat: '5/14/2025',
                  pengirimSurat: 'Bagian Umum',
                  nomorAgenda: 'AGK-1',
                  klasifikasiSurat: 'Eksternal',
                  ringkasanSurat: 'Surat Undangan',
                  keteranganSurat: 'Surat Undangan Rapat'),

              const MySuratCard(
                  nomorSurat: 'SRT-K2',
                  tanggalSurat: '5/15/2025',
                  pengirimSurat: 'Bagian Keuangan',
                  nomorAgenda: 'AGK-2',
                  klasifikasiSurat: 'Eksternal',
                  ringkasanSurat: 'Surat Pemberitahuan',
                  keteranganSurat: 'Surat Pemberitahuan Kegiatan'),

              const MySuratCard(
                  nomorSurat: 'SRT-K3',
                  tanggalSurat: '5/16/2025',
                  pengirimSurat: 'Bagian SDM',
                  nomorAgenda: 'AGK-3',
                  klasifikasiSurat: 'Internal',
                  ringkasanSurat: 'Memo Internal',
                  keteranganSurat: 'Memo Rapat Koordinasi'),
            ],
          ),
        ),
      ),
    );
  }
}