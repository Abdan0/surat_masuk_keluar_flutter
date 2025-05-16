import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_apppbar2.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_date_field.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_file_field.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_textfield.dart';

class TambahSuratMasuk extends StatefulWidget {
  const TambahSuratMasuk({super.key});

  @override
  State<TambahSuratMasuk> createState() => _TambahSuratMasukState();
}

class _TambahSuratMasukState extends State<TambahSuratMasuk> {
  final TextEditingController nomorSuratController = TextEditingController();
  final TextEditingController tipeSuratController = TextEditingController();
  final TextEditingController kategoriSuratController = TextEditingController();
  final TextEditingController asalSuratController = TextEditingController();
  final TextEditingController perihalSuratController = TextEditingController();
  final TextEditingController isiSuratController = TextEditingController();
  final TextEditingController tanggalController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Bar
              const MyAppBar2(),

              const SizedBox(
                height: 12,
              ),

              // Judul Halaman
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'Tambah Surat Masuk',
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: AppPallete.textColor,
                      fontWeight: FontWeight.w700),
                  textAlign: TextAlign.left,
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              // Field Nomor Surat
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Text('Nomor Surat'),
                    Expanded(
                        child: MyTextfield(
                      controller: nomorSuratController,
                      hintText: '',
                      obsecureText: false,
                      height: 40,
                    )),
                  ],
                ),
              ),

              // Field Tipe Surat (Masuk/Keluar)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Text('Tipe Surat'),
                    Expanded(
                        child: MyTextfield(
                      controller: nomorSuratController,
                      hintText: '',
                      obsecureText: false,
                      height: 40,
                    )),
                  ],
                ),
              ),

              // Field Kategori Surat (Internnal/Eksternal)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Text('Kategori Surat'),
                    Expanded(
                        child: MyTextfield(
                      controller: nomorSuratController,
                      hintText: '',
                      obsecureText: false,
                      height: 40,
                    )),
                  ],
                ),
              ),

              // Field Asal Surat
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Text('Asal Surat'),
                    Expanded(
                        child: MyTextfield(
                      controller: nomorSuratController,
                      hintText: '',
                      obsecureText: false,
                      height: 40,
                    )),
                  ],
                ),
              ),

              // Field Nomor Agenda
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Text('Nomor Agenda'),
                    Expanded(
                        child: MyTextfield(
                      controller: nomorSuratController,
                      hintText: '',
                      obsecureText: false,
                      height: 40,
                    )),
                  ],
                ),
              ),

              // Field Tanggal Surat
              // Row(
              //   children: [
              //     Text('Perihal'),
              //     Expanded(
              //         child: MyDateField(
              //       label: 'DD - MMMM - YYYY',
              //       controller: tanggalController,
              //     )),
              //   ],
              // ),

              // Field Perihal
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Text('Perihal'),
                    Expanded(
                        child: MyTextfield(
                      controller: nomorSuratController,
                      hintText: '',
                      obsecureText: false,
                      height: 40,
                    )),
                  ],
                ),
              ),

              // Field Isi
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Text('Isi'),
                    Expanded(
                        child: MyTextfield(
                      controller: nomorSuratController,
                      hintText: '',
                      obsecureText: false,
                      height: 40,
                    )),
                  ],
                ),
              ),

              // Field Lampiran
              MyFileField(
                  label: 'Lampiran',
                  onFilePicked: (file) {
                    print('File Dipilih : ${file.name}');
                  })
            ],
          ),
        ),
      ),
    );
  }
}
