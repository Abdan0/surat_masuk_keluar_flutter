import 'package:flutter/material.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_apppbar2.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';

class DisposisiPage extends StatefulWidget {
  const DisposisiPage({super.key});

  @override
  State<DisposisiPage> createState() => _DisposisiPageState();
}

class _DisposisiPageState extends State<DisposisiPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedPenerimaDropdown;
  String? _penerima;
  DateTime? _tenggatWaktu;
  String? _isiDisposisi;
  String? _selectedSifatStatus;
  String? _catatan;

  final List<String> _penerimaList = [
    '--Pilih Penerima--',
    'Staff Akademik',
    'Wakil Dekann',
    'Dekan'
  ];
  // final List<String> _statusList = [
  //   '--Pilih Status--',
  //   'Segera',
  //   'Penting',
  //   'Biasa'
  // ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
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
                  'Disposisi',
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: AppPallete.textColor,
                      fontWeight: FontWeight.w700),
                  textAlign: TextAlign.left,
                ),
              ),

              // Disposisi Form
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Penerima Dropdown
                      _buildLabel('Penerima'),
                      DropdownButtonFormField<String>(
                        value: _selectedPenerimaDropdown,
                        items: _penerimaList
                            .map(
                                (e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        decoration: _inputDecoration(),
                        onChanged: (val) {
                          setState(() => _selectedPenerimaDropdown = val);
                        },
                        validator: (v) =>
                            v == _penerimaList[0] ? 'Pilih penerima' : null,
                      ),
                      const SizedBox(height: 16),
                      // Penerima Text
                      const SizedBox(height: 16),
                      // Tenggat Waktu
                      _buildLabel('Tenggat Waktu'),
                      GestureDetector(
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _tenggatWaktu ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() => _tenggatWaktu = picked);
                          }
                        },
                        child: AbsorbPointer(
                          child: TextFormField(
                            decoration: _inputDecoration(
                              hint: 'mm/dd/yyyy',
                              suffixIcon:
                                  const Icon(Icons.calendar_today_rounded),
                            ),
                            controller: TextEditingController(
                              text: _tenggatWaktu == null
                                  ? ''
                                  : "${_tenggatWaktu!.month.toString().padLeft(2, '0')}/${_tenggatWaktu!.day.toString().padLeft(2, '0')}/${_tenggatWaktu!.year}",
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Isi Disposisi
                      _buildLabel('Isi Disposisi'),
                      TextFormField(
                        minLines: 4,
                        maxLines: 6,
                        decoration: _inputDecoration(),
                        onChanged: (val) => _isiDisposisi = val,
                      ),
                      const SizedBox(height: 16),
                      const SizedBox(height: 16),
                      // Catatan
                      _buildLabel('Catatan'),
                      TextFormField(
                        decoration: _inputDecoration(),
                        onChanged: (val) => _catatan = val,
                      ),
                      const SizedBox(height: 32),
                      // Simpan Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              // Proses simpan data di sini
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Disposisi disimpan!')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Simpan',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 16),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),

              // Tombol Simpan
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Color(0xFF29314F),
          ),
        ),
      );

  InputDecoration _inputDecoration({
    String? hint, 
    Widget? suffixIcon, 
    EdgeInsetsGeometry? contentPadding,
    double borderRadius = 8.0,
  }) =>
      InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        suffixIcon: suffixIcon,
        contentPadding: contentPadding ?? 
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: AppPallete.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: AppPallete.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: Color(0xFF2563EB)),
        ),
      );
}
