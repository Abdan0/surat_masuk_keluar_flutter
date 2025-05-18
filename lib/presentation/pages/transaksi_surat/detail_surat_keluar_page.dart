import 'package:flutter/material.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_apppbar2.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_detail_surat.dart';

class DetailSuratKeluar extends StatefulWidget {
  const DetailSuratKeluar({super.key});

  @override
  State<DetailSuratKeluar> createState() => _DetailSuratKeluarState();
}

class _DetailSuratKeluarState extends State<DetailSuratKeluar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //App Bar
              const MyAppBar2(),

              const SizedBox(
                height: 12,
              ),

              // Judul Page
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'Detail Surat Keluar',
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: AppPallete.textColor,
                      fontWeight: FontWeight.w700),
                  textAlign: TextAlign.left,
                ),
              ),

              // Detail Surat
              const MyDetailSurat(
                  nomorSurat: 'SK-001',
                  tanggalSurat: '16 Mei 2025',
                  pengirimSurat: 'Bagian Umum', // Untuk surat keluar, ini bisa jadi pengirim atau tujuan
                  nomorAgenda: 'AGK-001',
                  klasifikasiSurat: 'Eksternal',
                  ringkasanSurat: 'Surat Undangan Koordinasi',
                  keteranganSurat: 'Undangan untuk koordinasi kegiatan kampus',
                  createByController: 'Staff TU',
                  createOnController: '16 Mei 2025',
                  updateOnController: '16 Mei 2025')
            ],
          ),
        ),
      ),
    );
  }
}