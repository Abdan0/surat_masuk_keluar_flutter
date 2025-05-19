import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyDateField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator; // Menambahkan validator

  const MyDateField({
    super.key,
    required this.label,
    required this.controller,
    required this.hintText,
    this.validator, // Menambahkan parameter validator
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField( // Menggunakan TextFormField
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: const Icon(Icons.calendar_today),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
          borderRadius: BorderRadius.circular(12),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      ),
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );

        if (pickedDate != null) {
          final String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
          controller.text = formattedDate;
        }
      },
      validator: validator, // Menggunakan validator
    );
  }
}
