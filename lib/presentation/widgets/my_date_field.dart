import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';

class MyDateField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String? hintText;
  final String? errorText;
  final bool isRequired;
  final VoidCallback? onDateSelected;
  final String? Function(String?)? validator; // Menambahkan parameter validator

  const MyDateField({
    Key? key,
    required this.controller,
    this.label,
    this.hintText,
    this.errorText,
    this.isRequired = false,
    this.onDateSelected,
    this.validator, // Menambahkan parameter validator ke constructor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Row(
            children: [
              Text(
                label!,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppPallete.textColor,
                ),
              ),
              if (isRequired)
                Text(
                  ' *',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        TextFormField( // Mengubah menjadi TextFormField untuk mendukung validasi
          controller: controller,
          readOnly: true,
          validator: validator, // Menggunakan validator yang dipass
          decoration: InputDecoration(
            hintText: hintText ?? 'Pilih tanggal',
            errorText: errorText,
            suffixIcon: const Icon(Icons.calendar_today),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppPallete.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppPallete.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppPallete.primaryColor),
            ),
          ),
          onTap: () async {
            // Gunakan format tanggal yang konsisten
            final DateFormat formatter = DateFormat('yyyy-MM-dd');
            
            // Parse tanggal awal jika ada
            DateTime initialDate = DateTime.now();
            if (controller.text.isNotEmpty) {
              try {
                initialDate = formatter.parse(controller.text);
                print('✓ Berhasil parse tanggal dari input: ${controller.text} -> $initialDate');
              } catch (e) {
                print('⚠️ Error parsing date input: ${controller.text}');
                print('  Error details: $e');
                initialDate = DateTime.now();
              }
            }
            
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: initialDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
              builder: (context, child) {
                return Theme(
                  data: ThemeData.light().copyWith(
                    primaryColor: AppPallete.primaryColor,
                    colorScheme: const ColorScheme.light(
                      primary: AppPallete.primaryColor,
                    ),
                    buttonTheme: const ButtonThemeData(
                      textTheme: ButtonTextTheme.primary,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            
            if (picked != null) {
              final formattedDate = formatter.format(picked);
              print('📅 Tanggal dipilih: $picked -> format: $formattedDate');
              controller.text = formattedDate;
              
              // Panggil callback jika disediakan
              if (onDateSelected != null) {
                onDateSelected!();
              }
            }
          },
        ),
      ],
    );
  }
}
