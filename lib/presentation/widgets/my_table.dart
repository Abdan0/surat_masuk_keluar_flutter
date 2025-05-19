import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';

class ResponsiveTable<T> extends StatelessWidget {
  final List<String> columns;
  final List<T> data;
  final List<Widget Function(T item)> cellBuilders;
  final Color headerBackgroundColor;
  final Color rowBackgroundColor;
  final Color borderColor;
  final TextStyle headerStyle;
  final TextStyle cellStyle;
  
  // Ubah parameter onRowTap menjadi onTap untuk konsistensi
  final void Function(T, int)? onTap;

  const ResponsiveTable({
    Key? key,
    required this.columns,
    required this.data,
    required this.cellBuilders,
    this.headerBackgroundColor = Colors.grey,
    this.rowBackgroundColor = Colors.white,
    this.borderColor = Colors.grey,
    required this.headerStyle,
    required this.cellStyle,
    this.onTap, // Parameter yang benar
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Container(
              color: headerBackgroundColor,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Row(
                children: columns.map((column) {
                  return Container(
                    width: _getColumnWidth(column),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      column,
                      style: headerStyle,
                    ),
                  );
                }).toList(),
              ),
            ),
            
            // Data Rows
            ...List.generate(data.length, (index) {
              final item = data[index];
              return InkWell(
                onTap: onTap != null ? () => onTap!(item, index) : null,
                child: Container(
                  color: index % 2 == 0 
                      ? rowBackgroundColor 
                      : rowBackgroundColor.withOpacity(0.7),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Row(
                    children: List.generate(cellBuilders.length, (cellIndex) {
                      return Container(
                        width: _getColumnWidth(columns[cellIndex]),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: DefaultTextStyle(
                          style: cellStyle,
                          child: cellBuilders[cellIndex](item),
                        ),
                      );
                    }),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
  
  double _getColumnWidth(String column) {
    // Definisikan lebar berdasarkan kolom
    switch (column) {
      case 'Nomor Agenda':
      case 'Nomor Surat':
        return 150.0;
      case 'Pengirim':
      case 'Tujuan':
        return 170.0;
      case 'Tanggal Surat':
        return 150.0;
      default:
        return 120.0;
    }
  }
}