import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';
import 'package:surat_masuk_keluar_flutter/data/models/surat.dart';
import 'package:surat_masuk_keluar_flutter/data/services/surat_service.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_apppbar2.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_button.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_date_field.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_file_field.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_textfield.dart';

class EditSuratPage extends StatefulWidget {
  final Surat surat;
  
  const EditSuratPage({super.key, required this.surat});

  @override
  State<EditSuratPage> createState() => _EditSuratPageState();
}

class _EditSuratPageState extends State<EditSuratPage> {
  final _formKey = GlobalKey<FormState>();
  late String? _selectedKategoriDropdown;
  
  final List<String> _kategoriSuratList = [
    '--Kategori Surat--',
    'internal',
    'eksternal',
  ];

  late TextEditingController nomorSuratController;
  late TextEditingController asalSuratController;
  late TextEditingController tujuanSuratController;
  late TextEditingController perihalSuratController;
  late TextEditingController isiSuratController;
  late TextEditingController tanggalController;
  late TextEditingController lampiranController;

  bool _isLoading = false;
  PlatformFile? _selectedFile;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with existing surat data
    nomorSuratController = TextEditingController(text: widget.surat.nomorSurat);
    asalSuratController = TextEditingController(text: widget.surat.asalSurat);
    tujuanSuratController = TextEditingController(text: widget.surat.tujuanSurat ?? '');
    perihalSuratController = TextEditingController(text: widget.surat.perihal);
    isiSuratController = TextEditingController(text: widget.surat.isi);
    tanggalController = TextEditingController(text: widget.surat.tanggalSurat.toString().split(' ')[0]);
    lampiranController = TextEditingController(text: widget.surat.file != null ? 'File terlampir' : '');
    
    // Initialize dropdown
    _selectedKategoriDropdown = widget.surat.kategori;
    if (!_kategoriSuratList.contains(_selectedKategoriDropdown)) {
      _selectedKategoriDropdown = _kategoriSuratList[0];
    }
  }

  @override
  void dispose() {
    nomorSuratController.dispose();
    asalSuratController.dispose();
    tujuanSuratController.dispose();
    perihalSuratController.dispose();
    isiSuratController.dispose();
    tanggalController.dispose();
    lampiranController.dispose();
    super.dispose();
  }

  Future<void> _updateSurat() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create updated surat object
      final updatedSurat = Surat(
        id: widget.surat.id,
        nomorSurat: nomorSuratController.text,
        tipe: widget.surat.tipe,
        kategori: _selectedKategoriDropdown == '--Kategori Surat--' 
            ? 'internal' 
            : _selectedKategoriDropdown!,
        asalSurat: asalSuratController.text,
        tujuanSurat: widget.surat.tipe == 'keluar' ? tujuanSuratController.text : null,
        tanggalSurat: DateTime.parse(tanggalController.text),
        perihal: perihalSuratController.text,
        isi: isiSuratController.text,
        file: widget.surat.file,
        status: widget.surat.status,
        userId: widget.surat.userId,
      );

      // Update surat with fallback strategy
      final result = await SuratService.updateSuratWithFallback(
        widget.surat.id!,
        updatedSurat,
        pdfFile: _selectedFile != null ? File(_selectedFile!.path!) : null,
      );
      
      setState(() {
        _isLoading = false;
      });
      
      if (!mounted) return;
      
      // Show success notification
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Surat berhasil diperbarui'),
          backgroundColor: AppPallete.successColor,
        ),
      );

      // Return to previous page with updated data
      Navigator.pop(context, result);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // Show error notification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui surat: ${e.toString()}'),
          backgroundColor: AppPallete.errorColor,
        ),
      );
      
      // Tambahan: Tambahkan logging untuk membantu debug
      print('Error detail: $e');
      
      // Menampilkan dialog dengan detail error
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Detail Error'),
          content: SingleChildScrollView(
            child: Text(e.toString()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
            TextButton(
              onPressed: () {
                // Mencoba gunakan fallback jika API bermasalah
                Navigator.pop(context);
                Navigator.pop(context, widget.surat); // Kembalikan surat asli
              },
              child: const Text('Kembali ke Detail'),
            ),
          ],
        ),
      );
    }
  }

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
                      'Edit ${widget.surat.tipe == 'masuk' ? 'Surat Masuk' : 'Surat Keluar'}',
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

                          // Form fields
                          if (isSmallScreen)
                            _buildFormFieldsColumn()
                          else
                            _buildFormFieldsColumn(), // Use the same layout for now
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
                        _isLoading
                            ? const CircularProgressIndicator()
                            : MyButton(
                                text: 'Simpan',
                                onTap: _updateSurat,
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

  // Build column layout for form fields
  Widget _buildFormFieldsColumn() {
    final bool isSuratMasuk = widget.surat.tipe == 'masuk';
    
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nomor surat wajib diisi';
              }
              return null;
            },
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

        // Field Asal Surat or Tujuan Surat based on tipe
        if (isSuratMasuk)
          _buildFormFieldVertical(
            label: 'Asal Surat',
            isRequired: true,
            child: MyTextfield(
              controller: asalSuratController,
              hintText: 'Masukkan asal surat',
              obsecureText: false,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Asal surat wajib diisi';
                }
                return null;
              },
            ),
          )
        else
          _buildFormFieldVertical(
            label: 'Tujuan Surat',
            isRequired: true,
            child: MyTextfield(
              controller: tujuanSuratController,
              hintText: 'Masukkan tujuan surat',
              obsecureText: false,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Tujuan surat wajib diisi';
                }
                return null;
              },
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

        // Field Tanggal Surat
        _buildFormFieldVertical(
          label: 'Tanggal Surat',
          isRequired: true,
          child: MyDateField(
            label: '',
            controller: tanggalController,
            hintText: 'Pilih Tanggal',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Tanggal surat wajib diisi';
              }
              return null;
            },
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Perihal surat wajib diisi';
              }
              return null;
            },
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
            hintText: widget.surat.file != null ? 'Ganti file lampiran' : 'Pilih file lampiran',
            controller: lampiranController,
            onFilePicked: (file) {
              setState(() {
                _selectedFile = file;
                lampiranController.text = file.name;
              });
              print('File Dipilih: ${file.name}');
            },
          ),
        ),
      ],
    );
  }

  // Helper method for form fields
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