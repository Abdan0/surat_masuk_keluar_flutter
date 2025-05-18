import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';
import 'package:surat_masuk_keluar_flutter/presentation/pages/transaksi_surat/detail_surat_keluar_page.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_apppbar2.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_button.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_date_field.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_file_field.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_textfield.dart';

class TambahSuratKeluar extends StatefulWidget {
  const TambahSuratKeluar({super.key});

  @override
  State<TambahSuratKeluar> createState() => _TambahSuratKeluarState();
}

class _TambahSuratKeluarState extends State<TambahSuratKeluar> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedTipeDropdown;
  String? _selectedKategoriDropdown;

  final List<String> _tipeSuratList = [
    '--Tipe Surat--',
    'Surat Masuk',
    'Surat Keluar',
  ];

  final List<String> _kategoriSuratList = [
    '--Kategori Surat--',
    'Internal',
    'Eksternal',
  ];

  final TextEditingController nomorSuratController = TextEditingController();
  final TextEditingController tujuanSuratController = TextEditingController();
  final TextEditingController nomorAgendaController = TextEditingController();
  final TextEditingController perihalSuratController = TextEditingController();
  final TextEditingController isiSuratController = TextEditingController();
  final TextEditingController tanggalController = TextEditingController();
  final TextEditingController lampiranController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive design
    final screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 600;

    return Scaffold(
      backgroundColor: AppPallete.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Bar
                  const MyAppBar2(),

                  const SizedBox(height: 16),

                  // Page Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Tambah Surat Keluar',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: AppPallete.textColor,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Form Card
                  Card(
                    color: AppPallete.backgroundColor,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section title
                          Text(
                            'Informasi Dasar',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppPallete.primaryColor,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Form fields - adapting based on screen size
                          if (isSmallScreen)
                            _buildFormFieldsColumn()
                          else
                            _buildFormFieldsRow(),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Button actions
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Cancel button
                        OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppPallete.textColor,
                            side: const BorderSide(color: AppPallete.borderColor),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Batal',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Save button
                        MyButton(
                          text: 'Simpan',
                          onTap: () {
                            if (_formKey.currentState!.validate()) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const DetailSuratKeluar(),
                                ),
                              );
                            }
                          },
                          width: 120,
                          height: 50,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Build column layout for small screens
  Widget _buildFormFieldsColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Field Nomor Surat
        _buildFormFieldVertical(
          label: 'Nomor Surat',
          isRequired: true,
          child: MyTextfield(
            controller: nomorSuratController,
            hintText: 'Masukkan nomor surat',
            obsecureText: false,
          ),
        ),

        // Field Tipe Surat (Masuk/Keluar)
        _buildFormFieldVertical(
          label: 'Tipe Surat',
          isRequired: true,
          child: DropdownButtonFormField<String>(
            value: _selectedTipeDropdown,
            items: _tipeSuratList
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            decoration: _inputDecoration(hint: 'Pilih tipe surat'),
            onChanged: (val) {
              setState(() => _selectedTipeDropdown = val);
            },
            validator: (v) => v == _tipeSuratList[0] || v == null
                ? 'Pilih tipe surat'
                : null,
          ),
        ),

        // Field Kategori Surat (Internal/Eksternal)
        _buildFormFieldVertical(
          label: 'Kategori Surat',
          isRequired: true,
          child: DropdownButtonFormField<String>(
            value: _selectedKategoriDropdown,
            items: _kategoriSuratList
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            decoration: _inputDecoration(hint: 'Pilih kategori surat'),
            onChanged: (val) {
              setState(() => _selectedKategoriDropdown = val);
            },
            validator: (v) => v == _kategoriSuratList[0] || v == null
                ? 'Pilih kategori surat'
                : null,
          ),
        ),

        // Field Tujuan Surat (diubah dari Asal Surat)
        _buildFormFieldVertical(
          label: 'Tujuan Surat',
          isRequired: true,
          child: MyTextfield(
            controller: tujuanSuratController,
            hintText: 'Masukkan tujuan surat',
            obsecureText: false,
          ),
        ),

        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),

        // Section title
        Text(
          'Detail Surat',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppPallete.primaryColor,
          ),
        ),

        const SizedBox(height: 16),

        // Field Nomor Agenda
        _buildFormFieldVertical(
          label: 'Nomor Agenda',
          child: MyTextfield(
            controller: nomorAgendaController,
            hintText: 'Masukkan nomor agenda',
            obsecureText: false,
          ),
        ),

        // Field Tanggal Surat
        _buildFormFieldVertical(
          label: 'Tanggal Surat',
          isRequired: true,
          child: MyDateField(
            label: '',
            controller: tanggalController,
            hintText: 'Pilih Tanggal',
          ),
        ),

        // Field Perihal
        _buildFormFieldVertical(
          label: 'Perihal',
          isRequired: true,
          child: MyTextfield(
            controller: perihalSuratController,
            hintText: 'Masukkan perihal surat',
            obsecureText: false,
          ),
        ),

        // Field Isi
        _buildFormFieldVertical(
          label: 'Isi',
          child: MyTextfield(
            controller: isiSuratController,
            hintText: 'Masukkan isi ringkas surat',
            obsecureText: false,
            maxLines: 3,
            height: 80,
          ),
        ),

        // Field Lampiran
        _buildFormFieldVertical(
          label: 'Lampiran',
          child: MyFileField(
            label: '',
            hintText: 'Pilih file lampiran',
            controller: lampiranController,
            onFilePicked: (file) {
              print('File Dipilih : ${file.name}');
            },
          ),
        ),
      ],
    );
  }

  // Build horizontal layout for larger screens
  Widget _buildFormFieldsRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Field Nomor Surat
        _buildFormField(
          label: 'Nomor Surat',
          isRequired: true,
          child: MyTextfield(
            controller: nomorSuratController,
            hintText: 'Masukkan nomor surat',
            obsecureText: false,
          ),
        ),

        // Field Tipe Surat (Masuk/Keluar)
        _buildFormField(
          label: 'Tipe Surat',
          isRequired: true,
          child: DropdownButtonFormField<String>(
            value: _selectedTipeDropdown,
            items: _tipeSuratList
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            decoration: _inputDecoration(hint: 'Pilih tipe surat'),
            onChanged: (val) {
              setState(() => _selectedTipeDropdown = val);
            },
            validator: (v) => v == _tipeSuratList[0] || v == null
                ? 'Pilih tipe surat'
                : null,
          ),
        ),

        // Field Kategori Surat (Internal/Eksternal)
        _buildFormField(
          label: 'Kategori Surat',
          isRequired: true,
          child: DropdownButtonFormField<String>(
            value: _selectedKategoriDropdown,
            items: _kategoriSuratList
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            decoration: _inputDecoration(hint: 'Pilih kategori surat'),
            onChanged: (val) {
              setState(() => _selectedKategoriDropdown = val);
            },
            validator: (v) => v == _kategoriSuratList[0] || v == null
                ? 'Pilih kategori surat'
                : null,
          ),
        ),

        // Field Tujuan Surat
        _buildFormField(
          label: 'Tujuan Surat',
          isRequired: true,
          child: MyTextfield(
            controller: tujuanSuratController,
            hintText: 'Masukkan tujuan surat',
            obsecureText: false,
          ),
        ),

        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),

        // Section title
        Text(
          'Detail Surat',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppPallete.primaryColor,
          ),
        ),

        const SizedBox(height: 16),

        // Field Nomor Agenda
        _buildFormField(
          label: 'Nomor Agenda',
          child: MyTextfield(
            controller: nomorAgendaController,
            hintText: 'Masukkan nomor agenda',
            obsecureText: false,
          ),
        ),

        // Field Tanggal Surat
        _buildFormField(
          label: 'Tanggal Surat',
          isRequired: true,
          child: MyDateField(
            label: '',
            controller: tanggalController,
            hintText: 'Pilih Tanggal',
          ),
        ),

        // Field Perihal
        _buildFormField(
          label: 'Perihal',
          isRequired: true,
          child: MyTextfield(
            controller: perihalSuratController,
            hintText: 'Masukkan perihal surat',
            obsecureText: false,
          ),
        ),

        // Field Isi
        _buildFormField(
          label: 'Isi',
          child: MyTextfield(
            controller: isiSuratController,
            hintText: 'Masukkan isi ringkas surat',
            obsecureText: false,
            maxLines: 3,
            height: 80,
          ),
        ),

        // Field Lampiran
        _buildFormField(
          label: 'Lampiran',
          child: MyFileField(
            label: '',
            hintText: 'Pilih file lampiran',
            controller: lampiranController,
            onFilePicked: (file) {
              print('File Dipilih : ${file.name}');
            },
          ),
        ),
      ],
    );
  }

  // Helper method to build horizontal form fields (for larger screens)
  Widget _buildFormField({
    required String label,
    required Widget child,
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3, // Reduced flex to give more space to the input
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (isRequired)
                    Text(
                      ' *',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.red,
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(flex: 7, child: child), // Increased flex for input field
        ],
      ),
    );
  }

  // Helper method to build vertical form fields (for smaller screens)
  Widget _buildFormFieldVertical({
    required String label,
    required Widget child,
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label and required asterisk
          Row(
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              if (isRequired)
                Text(
                  ' *',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.red,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8), // Space between label and field
          child, // Input field
        ],
      ),
    );
  }

  // Input decoration for form fields
  InputDecoration _inputDecoration({String? hint, Widget? suffixIcon}) =>
      InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppPallete.backgroundColor,
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppPallete.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppPallete.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppPallete.secondaryColor),
        ),
      );
}