import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';

class MyFileField extends StatefulWidget {
  final String label;
  final Function(PlatformFile) onFilePicked;
  final TextEditingController controller;
  final double width;
  final double height;
  final String hintText;

  const MyFileField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    required this.onFilePicked,
    this.width = double.infinity,
    this.height = 40,
  });

  @override
  State<MyFileField> createState() => _FileInputFieldState();
}

class _FileInputFieldState extends State<MyFileField> {
  String? fileName;

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        fileName = result.files.first.name;
      });
      widget.onFilePicked(result.files.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: GestureDetector(
          onTap: _pickFile,
          child: AbsorbPointer(
            // Agar tidak bisa diedit manual
            child: TextField(
              controller: widget.controller,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: const BorderSide(color: AppPallete.borderColor),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppPallete.secondaryColor),
                ),
                hintText: widget.hintText,
                hintStyle: const TextStyle(color: AppPallete.textColor),
                suffixIcon: const Icon(Icons.attach_file),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
