import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';
import 'package:surat_masuk_keluar_flutter/presentation/pages/transaksi_surat/detail_surat_masuk_page.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_apppbar2.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_button.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_date_field.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_file_field.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_textfield.dart';
import 'package:surat_masuk_keluar_flutter/data/models/surat.dart';
import 'package:surat_masuk_keluar_flutter/data/services/surat_service.dart';
import 'package:surat_masuk_keluar_flutter/data/services/user_service.dart';

class TambahSuratMasuk extends StatefulWidget {
  const TambahSuratMasuk({super.key});

  @override
  State<TambahSuratMasuk> createState() => _TambahSuratMasukState();
}

class _TambahSuratMasukState extends State<TambahSuratMasuk> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedKategoriDropdown = '--Kategori Surat--';

  final List<String> _kategoriSuratList = [
    '--Kategori Surat--',
    'internal',
    'eksternal',
  ];

  final TextEditingController nomorSuratController = TextEditingController();
  final TextEditingController asalSuratController = TextEditingController();
  final TextEditingController nomorAgendaController = TextEditingController();
  final TextEditingController perihalSuratController = TextEditingController();
  final TextEditingController isiSuratController = TextEditingController();
  final TextEditingController tanggalController = TextEditingController();
  final TextEditingController lampiranController = TextEditingController();

  bool _isLoading = false;
  PlatformFile? _selectedFile;

  @override
  void initState() {
    super.initState();
    // Check API URLs
    SuratService.checkApiUrls();
  }

  @override
  void dispose() {
    nomorSuratController.dispose();
    asalSuratController.dispose();
    nomorAgendaController.dispose();
    perihalSuratController.dispose();
    isiSuratController.dispose();
    tanggalController.dispose();
    lampiranController.dispose();
    super.dispose();
  }

  // Modifikasi fungsi _saveSurat()
  Future<void> _saveSurat() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Mendapatkan user ID dengan mencoba beberapa pendekatan
      int userId;
      try {
        userId = await getUserId();
        print('👤 Menggunakan user ID: $userId');
      } catch (e) {
        print('❌ Error mendapatkan user ID: $e');
        
        // Mencoba refresh token terlebih dahulu
        final tokenRefreshed = await refreshToken();
        if (tokenRefreshed) {
          try {
            userId = await getUserId();
            print('👤 Menggunakan user ID setelah refresh token: $userId');
          } catch (refreshError) {
            // Tampilkan error dan minta user login ulang
            setState(() {
              _isLoading = false;
            });
            
            if (!mounted) return;
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Session telah berakhir, silakan login kembali'),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Login',
                  onPressed: () {
                    // Navigate to login page
                    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                  },
                ),
              ),
            );
            return;
          }
        } else {
          // Jika refresh gagal, gunakan fixed default (hanya untuk debugging)
          if (kDebugMode) {
            userId = 1; // Default untuk debugging
            print('⚠️ WARNING: Menggunakan default user ID = $userId (hanya untuk debugging)');
          } else {
            // Di production, tampilkan error
            setState(() {
              _isLoading = false;
            });
            
            if (!mounted) return;
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Gagal mendapatkan data user. Silakan login kembali.'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
        }
      }
      
      // Buat objek surat dengan user ID yang valid
      final surat = Surat(
        nomorSurat: nomorSuratController.text,
        tipe: 'masuk',
        kategori: _selectedKategoriDropdown == '--Kategori Surat--' ? 'internal' : _selectedKategoriDropdown!,
        asalSurat: asalSuratController.text,
        tujuanSurat: null,
        tanggalSurat: DateTime.parse(tanggalController.text),
        perihal: perihalSuratController.text,
        isi: isiSuratController.text,
        status: 'draft',
        userId: userId, // User ID yang valid
      );

      // Logging
      print('📝 Mengirim surat masuk dengan user ID: $userId');

      // Simpan surat ke API
      final createdSurat = await SuratService.createSuratWithErrorHandling(
        surat, 
        pdfFile: _selectedFile != null ? File(_selectedFile!.path!) : null,
        createAgenda: true
      );

      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      // Cek jika ada error pembuatan agenda
      if (createdSurat.agendaCreationError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Surat berhasil disimpan, tetapi gagal membuat agenda: ${createdSurat.agendaCreationError}'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
      } else {
        // Tampilkan notifikasi berhasil
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Surat dan agenda berhasil disimpan'),
            backgroundColor: AppPallete.successColor,
          ),
        );
      }

      // Navigasi ke halaman detail
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailSuratMasuk(surat: createdSurat),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      String errorMessage = 'Gagal menyimpan surat';
      
      // More specific error handling for user ID issues
      if (e.toString().contains('user id is invalid')) {
        errorMessage = 'ID pengguna tidak valid. Silakan login kembali.';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppPallete.errorColor,
            action: SnackBarAction(
              label: 'Login',
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              },
            ),
          ),
        );
        return;
      }
      
      // Periksa dulu jika error HTML tapi surat sebetulnya tersimpan
      if (e.toString().contains('HTML') && e.toString().contains('berhasil disimpan')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data surat berhasil disimpan, tetapi ada masalah format respons.'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pop(context, true); // Kembali ke halaman sebelumnya
        return; // Keluar dari metode
      }
      
      // Format pesan error menjadi lebih user-friendly
      if (e.toString().contains('HTML')) {
        errorMessage = 'Server sedang bermasalah. Silakan coba lagi nanti atau hubungi admin.';
      } else if (e.toString().contains('connection')) {
        errorMessage = 'Gagal terhubung ke server. Periksa koneksi internet Anda.';
      } else if (e.toString().contains('401')) {
        errorMessage = 'Session Anda telah berakhir. Silakan login kembali.';
      } else {
        // Ambil bagian pesan error yang penting saja
        final match = RegExp(r'Exception: (Gagal.*?)(?:Exception:|$)').firstMatch(e.toString());
        if (match != null) {
          errorMessage = match.group(1) ?? errorMessage;
        } else {
          errorMessage = e.toString();
        }
      }

      // Tampilkan notifikasi error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppPallete.errorColor,
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
                      'Tambah Surat Masuk',
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

                          // Tambahkan di bagian paling bawah CardForm, sebelum tombol action
                          // if (kDebugMode) ...[
                          //   const Divider(),
                          //   const SizedBox(height: 16),
                          //   Center(
                          //     child: OutlinedButton.icon(
                          //       onPressed: _checkUserSession,
                          //       icon: const Icon(Icons.bug_report),
                          //       label: const Text('Debug: Check User Session'),
                          //     ),
                          //   ),
                          // ],
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
                                onTap: _saveSurat,
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

        // Field Asal Surat
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
            hintText: 'Pilih file lampiran',
            controller: lampiranController,
            onFilePicked: (file) {
              setState(() {
                _selectedFile = file;
              });
              print('File Dipilih: ${file.name}');
            },
          ),
        ),
      ],
    );
  }

  // Build horizontal layout untuk screens yang lebih lebar
  Widget _buildFormFieldsRow() {
    // Implementasi untuk layout horizontal yang lebih sederhana untuk saat ini
    return _buildFormFieldsColumn();
  }

  // Helper methods...
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

  // Tambahkan fungsi ini
  Future<void> _checkUserSession() async {
    try {
      final token = await getToken();
      final userId = await getUserId().catchError((e) => 0);
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('User Session Info'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Token: ${token.isNotEmpty ? "Valid (${token.substring(0, 20)}...)" : "Not available"}'),
              const SizedBox(height: 8),
              Text('User ID: $userId'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking session: ${e.toString()}')),
      );
    }
  }
}