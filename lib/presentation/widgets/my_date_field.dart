import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';

class MyDateField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final double width;
  final double height;

  const MyDateField(
      {super.key,
      required this.label,
      required this.controller,
      required this.hintText,
      this.height = 60, // Increased from 40 to 60
      this.width = double.infinity});

  @override
  State<MyDateField> createState() => _MyDateFieldState();
}

class _MyDateFieldState extends State<MyDateField> {
  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('dd MMMM yyyy').format(pickedDate);
      widget.controller.text = formattedDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add label above the field
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
          child: Text(
            widget.label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppPallete.textColor,
            ),
          ),
        ),
        SizedBox(
          width: widget.width,
          height: widget.height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0),
            child: GestureDetector(
              onTap: _selectDate,
              child: AbsorbPointer(
                child: TextField(
                  controller: widget.controller,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: const BorderSide(color: AppPallete.borderColor),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: AppPallete.secondaryColor),
                    ),
                    hintText: widget.hintText,
                    hintStyle: const TextStyle(color: AppPallete.textColor, fontSize: 12),
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
