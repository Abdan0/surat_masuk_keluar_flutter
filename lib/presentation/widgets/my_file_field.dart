import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class MyFileField extends StatefulWidget {
  final String label;
  final Function(PlatformFile) onFilePicked;

  const MyFileField({
    super.key,
    required this.label,
    required this.onFilePicked,
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
    return InkWell(
      onTap: _pickFile,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: widget.label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: const Icon(Icons.attach_file),
        ),
        child: Text(fileName ?? 'Belum ada file terpilih'),
      ),
    );
  }
}
