import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';

class MyFileField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final Function(PlatformFile) onFilePicked; // Mengubah tipe parameter menjadi PlatformFile

  const MyFileField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    required this.onFilePicked,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: IconButton(
          icon: const Icon(Icons.attach_file),
          onPressed: () async {
            try {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['pdf', 'doc', 'docx'],
              );

              if (result != null) {
                final file = result.files.first;
                print('🗂️ File dipilih: ${file.name}, path: ${file.path}, size: ${file.size}');

                // Validasi file path
                if (file.path == null || file.path!.isEmpty) {
                  print('⚠️ File path tidak valid: ${file.path}');
                  return;
                }

                // Periksa apakah file ada
                final fileExists = await File(file.path!).exists();
                print('📄 File exists: $fileExists');

                controller.text = file.name;
                if (onFilePicked != null) {
                  onFilePicked!(file);
                }
              }
            } catch (e) {
              print('❌ Error memilih file: $e');
            }
          },
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      ),
    );
  }
}
